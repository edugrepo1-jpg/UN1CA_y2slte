import com.gmhub.qs.EditPointer;
import com.gmhub.qs.EditPointer.End;

public class EditPointerContract {
    static int checks;
    static void check(boolean ok) { checks++; if (!ok) throw new AssertionError("check " + checks); }
    public static void main(String[] args) {
        EditPointer p = new EditPointer();
        check(p.begin(7, 20, 20, 8));
        check(!p.move(7, 23, 24)); check(p.end(7, 23, 24, false) == End.TAP);
        check(!p.active());
        check(p.begin(3, 50, 50, 8)); check(p.move(3, 60, 50));
        check(p.deltaX() == 10 && p.deltaY() == 0);
        check(p.end(3, 65, 50, false) == End.DRAG);
        // Pointer ID 11 can become index 0; the owner must remain the same ID.
        check(p.begin(11, 0, 0, 8)); check(p.move(11, 100, 30));
        p.additionalPointer(); check(!p.active());
        check(p.end(11, 100, 30, false) == End.CANCEL);
        check(p.begin(0, 0, 0, 8)); check(!p.move(1, 1000, 1000));
        check(p.end(1, 1000, 1000, false) == End.CANCEL);
        check(p.begin(4, 0, 0, 8)); p.move(4, 100, 100);
        check(p.end(4, 100, 100, true) == End.CANCEL);
        check(p.deltaX() == 0 && p.deltaY() == 0);
        check(p.begin(8, 0, 0, 8)); p.hold();
        check(p.end(8, 0, 0, false) == End.NONE); // long press must not also toggle.
        check(!p.begin(-1, 0, 0, 8));
        check(!p.begin(0, Float.NaN, 0, 8));
        check(!p.begin(0, 0, 0, Float.POSITIVE_INFINITY));
        check(p.begin(2, 0, 0, 8)); check(!p.move(2, Float.POSITIVE_INFINITY, 0));
        check(p.end(2, 1, 1, false) == End.CANCEL);
        check(EditPointer.cells(14, 30) == 0 && EditPointer.cells(16, 30) == 1);
        check(EditPointer.cells(-16, 30) == -1);
        check(EditPointer.cells(Double.MAX_VALUE, 1) == Integer.MAX_VALUE);
        check(EditPointer.cells(-Double.MAX_VALUE, 1) == Integer.MIN_VALUE);
        for (float step : new float[]{0, -1, Float.NaN, Float.POSITIVE_INFINITY}) {
            boolean rejected = false;
            try { EditPointer.cells(5, step); } catch (IllegalArgumentException e) { rejected = true; }
            check(rejected);
        }
        for (int i = 0; i < 20; i++) {
            check(p.begin(i, 0, 0, 8)); p.move(i, 100, 100); p.cancel();
            check(!p.active() && !p.dragging() && p.deltaX() == 0);
            check(p.end(i, 100, 100, false) == End.CANCEL);
        }
        System.out.println("QS pointer ownership/cancel checks passed: " + checks);
    }
}
