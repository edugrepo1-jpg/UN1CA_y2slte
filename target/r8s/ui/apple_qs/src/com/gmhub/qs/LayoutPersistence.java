package com.gmhub.qs;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

/** Versioned per-user layout storage. All I/O belongs on the panel's serial
 * background executor, never a touch/draw callback. The directory must come
 * from QSHost.getUserContext() device-protected private files, not a root path.
 *
 * Fixed filenames, bounded input, checksum, last-good backup, atomic promotion
 * and revision checking prevent a failed/stale save from replacing good data.
 * Portrait and landscape plus all group metadata are saved in one transaction.
 */
public final class LayoutPersistence {
    private static final int MAGIC = 0x4751534c, VERSION = 1, MAX_BYTES = 1024 * 1024;
    private final Path directory, main, backup, lock;
    private final int userId;
    private final QsLayout.SizePolicy sizes;
    private final AtomicMove move;

    public interface AtomicMove { void replace(Path source, Path destination) throws IOException; }
    public static final class Saved {
        public final long revision;
        public final QsLayout.Snapshot portrait, landscape;
        public final int page;
        public Saved(long revision, QsLayout.Snapshot portrait, QsLayout.Snapshot landscape, int page) {
            if (revision < 0 || portrait == null || page < 0 || page >= portrait.board.pages)
                throw new IllegalArgumentException("Invalid saved layout");
            this.revision = revision; this.portrait = portrait; this.landscape = landscape; this.page = page;
        }
    }
    public LayoutPersistence(Path privateDirectory, int userId, QsLayout.SizePolicy sizes) {
        this(privateDirectory, userId, sizes, (source, destination) -> Files.move(source, destination,
            StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING));
    }
    public LayoutPersistence(Path privateDirectory, int userId, QsLayout.SizePolicy sizes, AtomicMove move) {
        if (userId < 0 || privateDirectory == null || sizes == null || move == null)
            throw new IllegalArgumentException("Invalid layout storage");
        directory = privateDirectory.toAbsolutePath().normalize();
        main = directory.resolve("layout.bin"); backup = directory.resolve("layout.backup");
        lock = directory.resolve("layout.lock"); this.userId = userId; this.sizes = sizes; this.move = move;
    }
    private static byte[] hash(byte[] data) {
        try { return MessageDigest.getInstance("SHA-256").digest(data); }
        catch (NoSuchAlgorithmException error) { throw new IllegalStateException(error); }
    }
    private byte[] encode(Saved state) throws IOException {
        ByteArrayOutputStream data = new ByteArrayOutputStream();
        java.io.OutputStream bounded = new java.io.OutputStream() {
            @Override public void write(int value) throws IOException {
                if (data.size() >= MAX_BYTES - 32) throw new IOException("Layout exceeds storage limit");
                data.write(value);
            }
            @Override public void write(byte[] bytes, int offset, int length) throws IOException {
                if (length > MAX_BYTES - 32 - data.size()) throw new IOException("Layout exceeds storage limit");
                data.write(bytes, offset, length);
            }
        };
        try (DataOutputStream out = new DataOutputStream(bounded)) {
            out.writeInt(MAGIC); out.writeInt(VERSION); out.writeInt(userId);
            out.writeLong(state.revision); out.writeInt(state.page);
            writeSnapshot(out, state.portrait); out.writeBoolean(state.landscape != null);
            if (state.landscape != null) writeSnapshot(out, state.landscape);
        }
        byte[] payload = data.toByteArray();
        if (payload.length > MAX_BYTES - 32) throw new IOException("Layout exceeds storage limit");
        byte[] checksum = hash(payload);
        byte[] complete = new byte[payload.length + checksum.length];
        System.arraycopy(payload, 0, complete, 0, payload.length);
        System.arraycopy(checksum, 0, complete, payload.length, checksum.length);
        return complete;
    }
    private static void writeSnapshot(DataOutputStream out, QsLayout.Snapshot snapshot) throws IOException {
        out.writeInt(snapshot.board.columns); out.writeInt(snapshot.board.rows); out.writeInt(snapshot.board.pages);
        out.writeInt(snapshot.cards.size());
        for (QsLayout.Card card : snapshot.cards) {
            out.writeUTF(card.key); out.writeUTF(card.spec); out.writeUTF(card.kind.name());
            out.writeInt(card.x); out.writeInt(card.y); out.writeInt(card.width);
            out.writeInt(card.height); out.writeInt(card.page); out.writeUTF(card.label);
            out.writeInt(card.children.size());
            for (String child : card.children) out.writeUTF(child);
        }
    }
    private Saved decode(byte[] complete) throws IOException {
        if (complete.length < 64 || complete.length > MAX_BYTES) throw new IOException("Invalid layout length");
        int count = complete.length - 32;
        byte[] payload = java.util.Arrays.copyOf(complete, count);
        if (!MessageDigest.isEqual(hash(payload), java.util.Arrays.copyOfRange(complete, count, complete.length)))
            throw new IOException("Layout checksum mismatch");
        try (DataInputStream in = new DataInputStream(new ByteArrayInputStream(payload))) {
            if (in.readInt() != MAGIC || in.readInt() != VERSION || in.readInt() != userId)
                throw new IOException("Unsupported layout version or user");
            long revision = in.readLong(); int page = in.readInt();
            QsLayout.Snapshot portrait = readSnapshot(in);
            QsLayout.Snapshot landscape = in.readBoolean() ? readSnapshot(in) : null;
            if (in.available() != 0) throw new IOException("Trailing layout data");
            return new Saved(revision, portrait, landscape, page);
        } catch (IllegalArgumentException error) { throw new IOException("Invalid layout content", error); }
    }
    private QsLayout.Snapshot readSnapshot(DataInputStream in) throws IOException {
        QsLayout.Board board = new QsLayout.Board(in.readInt(), in.readInt(), in.readInt());
        int count = in.readInt();
        if (count < 0 || count > QsLayout.MAX_CARDS) throw new IOException("Invalid control count");
        List<QsLayout.Card> cards = new ArrayList<>();
        for (int i = 0; i < count; i++) {
            String key = in.readUTF(), spec = in.readUTF();
            QsLayout.Kind kind = QsLayout.Kind.valueOf(in.readUTF());
            int x = in.readInt(), y = in.readInt(), width = in.readInt(), height = in.readInt(), page = in.readInt();
            String label = in.readUTF(); int children = in.readInt();
            if (children < 0 || children > 24) throw new IOException("Invalid group count");
            List<String> members = new ArrayList<>();
            for (int j = 0; j < children; j++) members.add(in.readUTF());
            cards.add(new QsLayout.Card(key, spec, kind, x, y, width, height, page, label, members));
        }
        QsLayout.Snapshot snapshot = QsLayout.restore(board, cards, sizes);
        if (snapshot == null) throw new IOException("Layout cannot fit its board");
        return snapshot;
    }
    private Saved read(Path path) throws IOException {
        long length = Files.size(path);
        if (length < 64 || length > MAX_BYTES) throw new IOException("Invalid layout file size");
        // Bound the allocation even if another process changes the file after
        // the size check. Do not use an unbounded readAllBytes() on private data.
        byte[] bytes = new byte[(int) length];
        try (java.io.InputStream in = Files.newInputStream(path)) {
            int offset = 0;
            while (offset < bytes.length) {
                int n = in.read(bytes, offset, bytes.length - offset);
                if (n < 0) throw new IOException("Truncated layout");
                offset += n;
            }
            if (in.read() != -1) throw new IOException("Layout grew while reading");
        }
        return decode(bytes);
    }
    /** Missing first-run data returns null. Corrupt main falls back to backup;
     * corrupt existing data is reported, never silently overwritten by defaults. */
    public synchronized Saved load() throws IOException {
        if (!Files.exists(main) && !Files.exists(backup)) return null;
        IOException failure;
        try { return read(main); } catch (IOException error) { failure = error; }
        try { return read(backup); } catch (IOException error) { failure.addSuppressed(error); throw failure; }
    }
    private static void writeSynced(Path path, byte[] content) throws IOException {
        try (FileChannel channel = FileChannel.open(path, StandardOpenOption.CREATE,
                StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING)) {
            ByteBuffer buffer = ByteBuffer.wrap(content);
            while (buffer.hasRemaining()) channel.write(buffer);
            channel.force(true);
        }
    }
    /** Returns the saved revision, or null on a stale edit. Any I/O failure is
     * reported to the UI caller; it must keep its previous accepted snapshot. */
    public synchronized Saved save(long expectedRevision, Saved candidate) throws IOException {
        if (candidate == null || expectedRevision < 0 || expectedRevision == Long.MAX_VALUE
                || candidate.revision != expectedRevision)
            throw new IllegalArgumentException("Invalid layout revision");
        Saved proposed = new Saved(expectedRevision + 1, candidate.portrait, candidate.landscape, candidate.page);
        byte[] encoded = encode(proposed);
        // Validate the complete candidate before touching any persisted file.
        decode(encoded);
        Files.createDirectories(directory);
        try (FileChannel channel = FileChannel.open(lock, StandardOpenOption.CREATE, StandardOpenOption.WRITE);
             FileLock held = channel.lock()) {
            Saved current = load();
            if ((current == null ? 0 : current.revision) != expectedRevision) return null;
            Path pending = directory.resolve("layout.pending"), old = directory.resolve("layout.backup.pending");
            try {
                writeSynced(pending, encoded);
                if (current != null) {
                    // Re-encode the validated last-good state, including when
                    // it was recovered from backup. Never back up corrupt main.
                    writeSynced(old, encode(current));
                    move.replace(old, backup);
                }
                move.replace(pending, main);
                return proposed;
            } finally {
                Files.deleteIfExists(pending); Files.deleteIfExists(old);
            }
        } catch (java.nio.channels.OverlappingFileLockException error) {
            throw new IOException("Another QS editor is saving this user's layout", error);
        }
    }
}
