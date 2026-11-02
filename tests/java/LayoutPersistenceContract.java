import com.gmhub.qs.LayoutPersistence;
import com.gmhub.qs.LayoutPersistence.Saved;
import com.gmhub.qs.QsLayout;
import com.gmhub.qs.QsLayout.*;
import java.io.*;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;

public class LayoutPersistenceContract {
    static int checks;
    static void check(boolean ok) { checks++; if (!ok) throw new AssertionError("check " + checks); }
    static Snapshot snapshot(String label) {
        return QsLayout.restore(new Board(4, 7, 10), Arrays.asList(
            new Card("connections", "group", Kind.GROUP, 0, 0, 2, 2, 0, label,
                Arrays.asList("Wifi", "Bluetooth", "MobileData")),
            new Card("media", "samsung-media", Kind.MEDIA, 2, 0, 2, 2, 0)), QsLayout.DEFAULT_SIZES);
    }
    static Saved state(long revision, String label) {
        Snapshot p = snapshot(label);
        return new Saved(revision, p, QsLayout.deriveOrientation(p, new Board(8, 3, 10), QsLayout.DEFAULT_SIZES), 0);
    }
    static LayoutPersistence store(Path directory, int user) {
        return new LayoutPersistence(directory, user, QsLayout.DEFAULT_SIZES);
    }
    static void atomic(Path a, Path b) throws IOException {
        Files.move(a, b, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
    }
    static void expectIo(RunnableIo action) throws Exception {
        boolean failed = false; try { action.run(); } catch (IOException e) { failed = true; } check(failed);
    }
    interface RunnableIo { void run() throws Exception; }
    static void roundTrip(Path directory) throws Exception {
        LayoutPersistence s = store(directory, 0); check(s.load() == null);
        Saved saved = s.save(0, state(0, "Conexões")); check(saved != null && saved.revision == 1);
        Saved loaded = store(directory, 0).load();
        check(loaded.revision == 1 && loaded.portrait.find("connections").label.equals("Conexões"));
        check(loaded.landscape.find("connections").children.equals(Arrays.asList("Wifi", "Bluetooth", "MobileData")));
        check(loaded.landscape.board.columns == 8 && loaded.portrait.board.columns == 4);
        byte[] original = Files.readAllBytes(directory.resolve("layout.bin"));
        check(s.save(0, state(0, "stale")) == null);
        check(Arrays.equals(original, Files.readAllBytes(directory.resolve("layout.bin"))));
        expectIo(() -> store(directory, 10).load()); // per-user data must not leak.
        check(s.save(1, state(1, "Changed")).revision == 2);
        check(store(directory, 0).load().portrait.find("connections").label.equals("Changed"));
    }
    static void corruptionAndBackup(Path directory) throws Exception {
        LayoutPersistence s = store(directory, 0);
        s.save(0, state(0, "First")); s.save(1, state(1, "Second"));
        Path main = directory.resolve("layout.bin"), backup = directory.resolve("layout.backup");
        byte[] damaged = Files.readAllBytes(main); damaged[30] ^= 0x40; Files.write(main, damaged);
        check(s.load().revision == 1 && s.load().portrait.find("connections").label.equals("First"));
        // Recovery must not copy the corrupt main over the good backup.
        check(s.save(1, state(1, "Recovered")).revision == 2);
        check(s.load().portrait.find("connections").label.equals("Recovered"));
        Files.write(main, new byte[]{1,2,3});
        check(s.load().revision == 1);
        Files.write(backup, new byte[]{4,5});
        expectIo(s::load); byte[] before = Files.readAllBytes(main);
        expectIo(() -> s.save(0, state(0, "Do not erase")));
        check(Arrays.equals(before, Files.readAllBytes(main)));
    }
    static void failuresPreserveMain(Path directory) throws Exception {
        LayoutPersistence good = store(directory, 0); good.save(0, state(0, "Original"));
        byte[] original = Files.readAllBytes(directory.resolve("layout.bin"));
        for (int failureAt : new int[]{1,2}) {
            final int[] calls = {0};
            LayoutPersistence failing = new LayoutPersistence(directory, 0, QsLayout.DEFAULT_SIZES, (a,b) -> {
                if (++calls[0] == failureAt) throw new IOException("Injected atomic move failure");
                atomic(a,b);
            });
            expectIo(() -> failing.save(1, state(1, "Must not replace")));
            check(calls[0] == failureAt);
            check(Arrays.equals(original, Files.readAllBytes(directory.resolve("layout.bin"))));
            check(good.load().revision == 1);
            check(!Files.exists(directory.resolve("layout.pending")));
            check(!Files.exists(directory.resolve("layout.backup.pending")));
        }
        check(good.save(1, state(1, "Success")).revision == 2);
    }
    static void formatAndBounds(Path directory) throws Exception {
        LayoutPersistence s = store(directory, 0); s.save(0, state(0, "Initial"));
        Path main = directory.resolve("layout.bin"); byte[] original = Files.readAllBytes(main);
        byte[] wrongVersion = original.clone(); wrongVersion[7] = 99;
        byte[] payload = Arrays.copyOf(wrongVersion, wrongVersion.length-32);
        System.arraycopy(MessageDigest.getInstance("SHA-256").digest(payload),0,wrongVersion,payload.length,32);
        Files.write(main,wrongVersion); expectIo(s::load); Files.write(main,original);
        try (java.nio.channels.FileChannel channel = java.nio.channels.FileChannel.open(main, StandardOpenOption.WRITE)) {
            channel.position(1024*1024); channel.write(java.nio.ByteBuffer.wrap(new byte[]{0}));
        }
        expectIo(s::load); Files.write(main,original);
        boolean rejected = false;
        try { s.save(Long.MAX_VALUE, state(Long.MAX_VALUE, "No rollover")); }
        catch (IllegalArgumentException e) { rejected = true; }
        check(rejected && Arrays.equals(original,Files.readAllBytes(main)));
        List<Card> huge = new ArrayList<>();
        StringBuilder text = new StringBuilder(); for(int i=0;i<500;i++) text.append('\u6f22');
        for(int i=0;i<100;i++) {
            List<String> members = new ArrayList<>();
            for(int j=0;j<24;j++) members.add(text.toString()+j);
            huge.add(new Card("g"+i,"group",Kind.GROUP,0,0,1,1,0,"",members));
        }
        Snapshot enormous = QsLayout.restore(new Board(4,7,10),huge,QsLayout.DEFAULT_SIZES);
        check(enormous != null);
        expectIo(() -> s.save(1,new Saved(1,enormous,null,0)));
        check(Arrays.equals(original,Files.readAllBytes(main)));
    }
    public static void main(String[] args) throws Exception {
        Path base = Paths.get(System.getProperty("qs.contract.tmp")).resolve("persistence");
        Files.createDirectories(base);
        roundTrip(base.resolve("roundtrip")); corruptionAndBackup(base.resolve("recovery"));
        failuresPreserveMain(base.resolve("failures")); formatAndBounds(base.resolve("bounds"));
        System.out.println("QS persistence/restart/atomic-save checks passed: " + checks);
    }
}
