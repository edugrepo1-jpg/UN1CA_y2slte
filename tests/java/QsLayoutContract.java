import com.gmhub.qs.QsLayout;
import com.gmhub.qs.QsLayout.*;
import java.util.*;

public class QsLayoutContract {
    static int checks;
    static final SizePolicy SIZES = QsLayout.DEFAULT_SIZES;
    static final Board PORTRAIT = new Board(4, 7, 10), WIDE = new Board(8, 3, 10);
    static void check(boolean ok) { checks++; if (!ok) throw new AssertionError("check " + checks); }
    static Card tile(String id, int x, int y, int w, int h, int page) {
        return new Card(id, "native-" + id, Kind.TILE, x, y, w, h, page);
    }
    static Snapshot defaults() {
        List<Card> c = new ArrayList<>();
        c.add(new Card("group", "connectivity", Kind.GROUP, 0, 0, 2, 2, 0,
            "Conectividade", Arrays.asList("Wifi", "Bluetooth", "MobileData")));
        c.add(new Card("media", "samsung-media", Kind.MEDIA, 2, 0, 2, 2, 0));
        c.add(tile("rotation", 0, 2, 1, 1, 0)); c.add(tile("sound", 1, 2, 1, 1, 0));
        c.add(new Card("brightness", "brightness", Kind.BRIGHTNESS, 2, 2, 1, 2, 0));
        c.add(new Card("volume", "volume", Kind.VOLUME, 3, 2, 1, 2, 0));
        c.add(new Card("focus", "focus", Kind.GROUP, 0, 3, 2, 1, 0));
        for (int i = 0; i < 4; i++) c.add(tile("bottom" + i, i, 4, 1, 1, 0));
        Snapshot s = QsLayout.restore(PORTRAIT, c, SIZES); check(s != null); return s;
    }
    static String digest(Snapshot s) {
        StringBuilder b = new StringBuilder();
        for (Card c : s.cards) b.append(c.key).append(':').append(c.spec).append(':')
            .append(c.x).append(',').append(c.y).append(',').append(c.width).append(',')
            .append(c.height).append(',').append(c.page).append(':').append(c.label)
            .append(':').append(c.children).append(';');
        return b.toString();
    }
    // Independent pairwise geometry assertions, rather than the packer's mask.
    static void valid(Snapshot s) {
        check(s != null); Set<String> keys = new HashSet<>();
        for (int i = 0; i < s.cards.size(); i++) {
            Card a = s.cards.get(i);
            check(keys.add(a.key));
            check(a.x >= 0 && a.y >= 0 && a.page >= 0 && a.page < s.board.pages);
            check(a.width > 0 && a.height > 0 && a.x + a.width <= s.board.columns
                && a.y + a.height <= s.board.rows);
            for (int j = 0; j < i; j++) {
                Card b = s.cards.get(j);
                check(a.page != b.page || a.x >= b.x + b.width || a.x + a.width <= b.x
                    || a.y >= b.y + b.height || a.y + a.height <= b.y);
            }
        }
    }
    static void restoreAndReject() {
        Snapshot repaired = QsLayout.restore(PORTRAIT, Arrays.asList(
            tile("a", 3, 9, 4, 2, 99), tile("b", 3, 9, 4, 2, 99)), SIZES);
        valid(repaired); check(repaired.find("a").x == 0 && repaired.find("a").page == 9);
        check(QsLayout.restore(PORTRAIT, Arrays.asList(tile("same", 0, 0, 1, 1, 0),
            tile("same", 1, 0, 1, 1, 0)), SIZES) == null);
        for (int bad : new int[]{Integer.MIN_VALUE, -1, 0, 5, Integer.MAX_VALUE})
            check(QsLayout.restore(PORTRAIT, Arrays.asList(tile("bad", 0, 0, bad, 1, 0)), SIZES) == null);
        check(QsLayout.restore(PORTRAIT, Arrays.asList((Card) null), SIZES) == null);
        check(QsLayout.restore(PORTRAIT, null, SIZES) == null);
        List<Card> tooMany = new ArrayList<>();
        for (int i = 0; i <= QsLayout.MAX_CARDS; i++) tooMany.add(tile("c"+i, 0, 0, 1, 1, 0));
        check(QsLayout.restore(PORTRAIT, tooMany, SIZES) == null);
        boolean rejected = false;
        try { new Board(8, Integer.MAX_VALUE, 1); } catch (IllegalArgumentException e) { rejected = true; }
        check(rejected);
    }
    static void moveResizeCancelAndStale() {
        Snapshot base = defaults(); String old = digest(base);
        Snapshot moved = QsLayout.move(base, "media", 0, 0, 0, SIZES); valid(moved);
        check(moved.find("media").x == 0 && moved.find("media").y == 0);
        check(digest(base).equals(old));
        check(QsLayout.resize(base, "media", 1, 1, SIZES) == null);
        Snapshot resized = QsLayout.resize(base, "media", 4, 2, SIZES); valid(resized);
        check(resized.find("media").width == 4 && digest(base).equals(old));
        Edit edit = new Edit(base); check(edit.offer(resized));
        check(edit.cancel() == base && edit.preview() == base);
        check(!edit.offer(moved) && edit.commit(base) == null);
        Edit stale = new Edit(base); check(stale.offer(resized));
        check(stale.commit(moved) == null);
        Edit accepted = new Edit(base); check(accepted.offer(resized));
        check(accepted.commit(base) == resized && accepted.commit(base) == null);
        check(QsLayout.move(base, "missing", 0, 0, 0, SIZES) == null);
        Snapshot clamped = QsLayout.move(base, "media", Integer.MAX_VALUE, Integer.MIN_VALUE,
            Integer.MAX_VALUE, SIZES); valid(clamped);
        check(clamped.find("media").page == 9 && clamped.find("media").x == 2);
        boolean immutable = false;
        try { base.cards.clear(); } catch (UnsupportedOperationException e) { immutable = true; }
        check(immutable);
    }
    static void fullAndUnavailable() {
        Board board = new Board(2, 2, 1);
        List<Card> all = Arrays.asList(tile("a", 0, 0, 1, 1, 0), tile("b", 1, 0, 1, 1, 0),
            tile("c", 0, 1, 1, 1, 0), tile("d", 1, 1, 1, 1, 0));
        Snapshot full = QsLayout.restore(board, all, SIZES); String old = digest(full);
        check(QsLayout.add(full, tile("e", 0, 0, 1, 1, 0), true, SIZES) == null);
        check(QsLayout.resize(full, "a", 2, 2, SIZES) == null);
        check(digest(full).equals(old));
        Snapshot removed = QsLayout.remove(full, "a"); valid(removed);
        check(QsLayout.add(removed, tile("e", 0, 0, 1, 1, 0), false, SIZES) == null);
        Snapshot added = QsLayout.add(removed, tile("e", 0, 0, 1, 1, 0), true, SIZES); valid(added);
        check(added.find("e") != null && removed.find("e") == null);
        check(QsLayout.remove(full, "unknown") == null);
    }
    static void orientationAndPolicies() {
        Snapshot base = defaults(); String old = digest(base);
        Snapshot wide = QsLayout.deriveOrientation(base, WIDE, SIZES); valid(wide);
        check(digest(base).equals(old) && wide.cards.size() == base.cards.size());
        Snapshot tall = QsLayout.resize(base, "brightness", 1, 4, SIZES); valid(tall);
        Snapshot fitted = QsLayout.deriveOrientation(tall, WIDE, SIZES); valid(fitted);
        check(tall.find("brightness").height == 4 && fitted.find("brightness").height == 3);
        Edit portraitEdit = new Edit(base); check(!portraitEdit.offer(wide));
        SizePolicy stricter = (c, b) -> c.kind != Kind.MEDIA || (c.width >= 3 && c.height >= 2);
        check(QsLayout.restore(PORTRAIT, base.cards, stricter) == null);
        check(QsLayout.restore(PORTRAIT, QsLayout.resize(base, "media", 3, 2, SIZES).cards, stricter) != null);
    }
    static void groupsAndNativePlayer() {
        Snapshot base = defaults(); String old = digest(base);
        Snapshot edited = QsLayout.editGroup(base, "group", "Conexões", Arrays.asList("Bluetooth", "Wifi"), true);
        check(edited != null && edited.find("group").label.equals("Conexões"));
        Snapshot moved = QsLayout.move(edited, "group", 0, 4, 2, SIZES); valid(moved);
        check(moved.find("group").children.equals(Arrays.asList("Bluetooth", "Wifi")));
        check(moved.find("group").label.equals("Conexões") && digest(base).equals(old));
        Snapshot wide = QsLayout.deriveOrientation(moved, WIDE, SIZES); valid(wide);
        check(wide.find("group").children.equals(moved.find("group").children));
        check(QsLayout.editGroup(base, "group", "bad", Arrays.asList("Wifi", "Wifi"), true) == null);
        check(QsLayout.editGroup(base, "group", "bad", Arrays.asList(""), true) == null);
        check(QsLayout.editGroup(base, "group", "bad", Arrays.asList("MissingTile"), false) == null);
        check(QsLayout.editGroup(base, "media", "bad", Collections.emptyList(), true) == null);
        check(QsLayout.add(base, new Card("second-media", "samsung-media", Kind.MEDIA,
            0, 0, 2, 2, 3), true, SIZES) == null);
        boolean immutable = false;
        try { edited.find("group").children.clear(); } catch (UnsupportedOperationException e) { immutable = true; }
        check(immutable);
    }
    static void seededEdits() {
        Random random = new Random(0x473780fL);
        Snapshot current = defaults();
        for (int i = 0; i < 400; i++) {
            String before = digest(current);
            Card chosen = current.cards.get(random.nextInt(current.cards.size()));
            Snapshot next;
            if ((i & 1) == 0) next = QsLayout.move(current, chosen.key, random.nextInt(8)-2,
                random.nextInt(11)-2, random.nextInt(12)-1, SIZES);
            else next = QsLayout.resize(current, chosen.key, random.nextInt(6), random.nextInt(6), SIZES);
            check(digest(current).equals(before));
            if (next == null) continue;
            valid(next);
            check(next.cards.size() == current.cards.size());
            for (Card c : current.cards) {
                Card n = next.find(c.key); check(n != null && n.spec.equals(c.spec) && n.kind == c.kind);
                check(n.label.equals(c.label) && n.children.equals(c.children));
            }
            Snapshot again = (i & 1) == 0
                ? QsLayout.move(current, chosen.key, next.find(chosen.key).x, next.find(chosen.key).y,
                    next.find(chosen.key).page, SIZES)
                : QsLayout.resize(current, chosen.key, next.find(chosen.key).width, next.find(chosen.key).height, SIZES);
            check(again != null && digest(again).equals(digest(next)));
            current = next;
        }
    }
    public static void main(String[] args) {
        restoreAndReject(); moveResizeCancelAndStale(); fullAndUnavailable();
        orientationAndPolicies(); groupsAndNativePlayer(); seededEdits();
        System.out.println("QS layout invariants passed: " + checks + "; seeded edits: 400");
    }
}
