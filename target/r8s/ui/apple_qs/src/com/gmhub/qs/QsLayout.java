package com.gmhub.qs;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** Bounded, immutable replacement for the recovered editor's in-place pack.
 * Called on gesture completion/preview change, never from draw(). Pixel insets,
 * touch slop and native view measurements belong to the Samsung view binding.
 * Portrait and landscape keep separate snapshots: deriving the second one does
 * not overwrite the dimensions or placement of the first one.
 */
public final class QsLayout {
    public static final int MAX_CARDS = 100;
    public enum Kind { TILE, ACTION, GROUP, MEDIA, BRIGHTNESS, VOLUME }

    public static final class Board {
        public final int columns, rows, pages;
        public Board(int columns, int rows, int pages) {
            if (columns < 1 || columns > 8 || rows < 1 || rows > 64 || pages < 1 || pages > 10)
                throw new IllegalArgumentException("Invalid QS board");
            this.columns = columns; this.rows = rows; this.pages = pages;
        }
    }
    public static final class Card {
        public final String key, spec, label;
        public final Kind kind;
        public final List<String> children;
        public final int x, y, width, height, page;
        public Card(String key, String spec, Kind kind, int x, int y, int width, int height, int page) {
            this(key, spec, kind, x, y, width, height, page, "", Collections.emptyList());
        }
        public Card(String key, String spec, Kind kind, int x, int y, int width, int height, int page,
                    String label, List<String> children) {
            if (key == null || key.isEmpty() || key.length() > 128 || spec == null
                    || spec.isEmpty() || spec.length() > 512 || kind == null || label == null
                    || label.length() > 256 || children == null || children.size() > 24
                    || (kind != Kind.GROUP && !children.isEmpty()))
                throw new IllegalArgumentException("Invalid control identity");
            Set<String> unique = new HashSet<>();
            for (String child : children)
                if (child == null || child.isEmpty() || child.length() > 512 || !unique.add(child))
                    throw new IllegalArgumentException("Invalid group control");
            this.key = key; this.spec = spec; this.kind = kind; this.label = label;
            this.children = Collections.unmodifiableList(new ArrayList<>(children));
            this.x = x; this.y = y; this.width = width; this.height = height; this.page = page;
        }
        public Card at(int x, int y, int page) {
            return new Card(key, spec, kind, x, y, width, height, page, label, children);
        }
        public Card resize(int width, int height) {
            return new Card(key, spec, kind, x, y, width, height, page, label, children);
        }
    }
    public static final class Snapshot {
        public final Board board;
        public final List<Card> cards;
        private Snapshot(Board board, List<Card> cards) {
            this.board = board;
            this.cards = Collections.unmodifiableList(new ArrayList<>(cards));
        }
        public Card find(String key) {
            for (Card card : cards) if (card.key.equals(key)) return card;
            return null;
        }
    }
    /** Native media minimums can be stricter than the editor's default. This
     * prevents resizing Samsung's player into an unusable one-cell button. */
    public interface SizePolicy { boolean allows(Card card, Board board); }
    public static final SizePolicy DEFAULT_SIZES = (card, board) ->
        card.kind != Kind.MEDIA || (card.width >= 2 && card.height >= 2);

    private QsLayout() { }
    private static boolean sizeFits(Card card, Board board, SizePolicy sizes) {
        return card.width >= 1 && card.width <= board.columns
            && card.height >= 1 && card.height <= board.rows && sizes.allows(card, board);
    }
    private static boolean identityValid(List<Card> cards) {
        if (cards == null || cards.size() > MAX_CARDS) return false;
        Set<String> keys = new HashSet<>();
        int media = 0;
        for (Card card : cards) {
            if (card == null || !keys.add(card.key)) return false;
            // A single native player view cannot be attached to two parents.
            if (card.kind == Kind.MEDIA && ++media > 1) return false;
        }
        return true;
    }
    private static int clamp(int value, int high) { return Math.max(0, Math.min(high, value)); }
    private static Card bounded(Card card, Board board) {
        return card.at(clamp(card.x, board.columns - card.width),
            clamp(card.y, board.rows - card.height), clamp(card.page, board.pages - 1));
    }
    private static boolean fits(Card card, int x, int y, int page, Board board, int[][] occupied) {
        if (page < 0 || page >= board.pages || x < 0 || y < 0
                || x > board.columns - card.width || y > board.rows - card.height)
            return false;
        int mask = ((1 << card.width) - 1) << x;
        for (int row = y; row < y + card.height; row++)
            if ((occupied[page][row] & mask) != 0) return false;
        return true;
    }
    private static void mark(Card card, int[][] occupied) {
        int mask = ((1 << card.width) - 1) << card.x;
        for (int y = card.y; y < card.y + card.height; y++) occupied[card.page][y] |= mask;
    }
    private static Card nearest(Card requested, Board board, int[][] occupied) {
        if (fits(requested, requested.x, requested.y, requested.page, board, occupied)) return requested;
        Card best = null;
        int bestScore = Integer.MAX_VALUE;
        // Prefer the same page, then the nearest page. Deterministic row/column
        // tie-breaking makes restart and rotation stable, without random jumps.
        int pageWeight = board.columns + board.rows;
        for (int page = 0; page < board.pages; page++)
            for (int y = 0; y <= board.rows - requested.height; y++)
                for (int x = 0; x <= board.columns - requested.width; x++) {
                    int score = Math.abs(page - requested.page) * pageWeight
                        + Math.abs(x - requested.x) + Math.abs(y - requested.y);
                    if (score >= bestScore) continue;
                    if (fits(requested, x, y, page, board, occupied)) {
                        best = requested.at(x, y, page); bestScore = score;
                    }
                }
        return best;
    }
    private static Snapshot pack(Board board, List<Card> input, String priority, SizePolicy sizes) {
        if (board == null || sizes == null || !identityValid(input)) return null;
        int[][] occupied = new int[board.pages][board.rows];
        List<Card> result = new ArrayList<>(input);
        int priorityIndex = -1;
        for (int i = 0; i < input.size(); i++) {
            if (!sizeFits(input.get(i), board, sizes)) return null;
            if (input.get(i).key.equals(priority)) priorityIndex = i;
        }
        if (priority != null && priorityIndex < 0) return null;
        // Place the edited control first; neighboring cards can move only in
        // the returned candidate. A failed pack never modifies the old layout.
        for (int turn = -1; turn < input.size(); turn++) {
            int i = turn < 0 ? priorityIndex : turn;
            if (i < 0 || (turn >= 0 && i == priorityIndex)) continue;
            Card positioned = nearest(bounded(input.get(i), board), board, occupied);
            if (positioned == null) return null;
            result.set(i, positioned);
            mark(positioned, occupied);
        }
        return new Snapshot(board, result);
    }

    /** Loading repairs positions/collisions but rejects malformed identities,
     * dimensions and impossible layouts. Caller retains its last good snapshot. */
    public static Snapshot restore(Board board, List<Card> saved, SizePolicy sizes) {
        return pack(board, saved, null, sizes);
    }
    public static Snapshot move(Snapshot base, String key, int x, int y, int page, SizePolicy sizes) {
        if (base == null || base.find(key) == null) return null;
        List<Card> changed = new ArrayList<>(base.cards);
        for (int i = 0; i < changed.size(); i++)
            if (changed.get(i).key.equals(key)) changed.set(i, changed.get(i).at(x, y, page));
        return pack(base.board, changed, key, sizes);
    }
    public static Snapshot resize(Snapshot base, String key, int width, int height, SizePolicy sizes) {
        if (base == null || base.find(key) == null) return null;
        List<Card> changed = new ArrayList<>(base.cards);
        for (int i = 0; i < changed.size(); i++)
            if (changed.get(i).key.equals(key)) changed.set(i, changed.get(i).resize(width, height));
        return pack(base.board, changed, key, sizes);
    }
    public static Snapshot add(Snapshot base, Card card, boolean nativeControlReady, SizePolicy sizes) {
        if (base == null || card == null || !nativeControlReady || base.find(card.key) != null) return null;
        List<Card> changed = new ArrayList<>(base.cards);
        changed.add(card);
        return pack(base.board, changed, card.key, sizes);
    }
    public static Snapshot remove(Snapshot base, String key) {
        if (base == null || base.find(key) == null) return null;
        List<Card> changed = new ArrayList<>(base.cards);
        changed.removeIf(card -> card.key.equals(key));
        return new Snapshot(base.board, changed);
    }
    /** One edit transaction for name/order/membership, rather than disk writes
     * for every key stroke. Availability is checked when adding group controls;
     * restore keeps existing controls even if a provider is temporarily absent. */
    public static Snapshot editGroup(Snapshot base, String key, String label, List<String> children,
                                     boolean newControlsReady) {
        if (base == null || !newControlsReady) return null;
        Card group = base.find(key);
        if (group == null || group.kind != Kind.GROUP) return null;
        try {
            Card edited = new Card(group.key, group.spec, group.kind, group.x, group.y, group.width,
                group.height, group.page, label, children);
            List<Card> changed = new ArrayList<>(base.cards);
            for (int i = 0; i < changed.size(); i++) if (changed.get(i) == group) changed.set(i, edited);
            return new Snapshot(base.board, changed);
        } catch (IllegalArgumentException error) { return null; }
    }
    public static Snapshot deriveOrientation(Snapshot base, Board other, SizePolicy sizes) {
        if (base == null || other == null) return null;
        List<Card> adapted = new ArrayList<>();
        for (Card card : base.cards)
            adapted.add(card.resize(Math.min(card.width, other.columns), Math.min(card.height, other.rows)));
        return pack(other, adapted, null, sizes);
    }

    /** A gesture previews without saving. Cancel/rotation/disconnect restores
     * the original; an edit from a stale screen cannot overwrite newer changes. */
    public static final class Edit {
        private final Snapshot original;
        private Snapshot preview;
        private boolean finished;
        public Edit(Snapshot original) {
            this.original = java.util.Objects.requireNonNull(original);
            preview = original;
        }
        public Snapshot preview() { return preview; }
        public boolean offer(Snapshot candidate) {
            if (finished || candidate == null || candidate.board != original.board) return false;
            preview = candidate;
            return true;
        }
        public Snapshot cancel() { finished = true; preview = original; return original; }
        public Snapshot commit(Snapshot current) {
            if (finished || current != original) return null;
            finished = true;
            return preview;
        }
    }
}
