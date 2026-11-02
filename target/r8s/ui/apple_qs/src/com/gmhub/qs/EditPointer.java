package com.gmhub.qs;

/** Pointer ownership for edit gestures. The Android binding supplies pointer IDs
 * (never MotionEvent indices), raw screen coordinates and ViewConfiguration's
 * scaled touch slop. Cancellation never returns a commit/tap result.
 */
public final class EditPointer {
    public enum End { NONE, TAP, DRAG, CANCEL }
    private int pointer = -1;
    private double startX, startY, dx, dy, slop;
    private boolean dragging, held, cancelled;

    public boolean begin(int id, float x, float y, float touchSlop) {
        cancel();
        if (id < 0 || !finite(x, y) || !Float.isFinite(touchSlop) || touchSlop < 0) return false;
        pointer = id;
        startX = x; startY = y; dx = dy = 0; slop = touchSlop;
        dragging = held = cancelled = false;
        return true;
    }
    private static boolean finite(float x, float y) {
        return Float.isFinite(x) && Float.isFinite(y);
    }
    public boolean move(int id, float x, float y) {
        if (pointer < 0 || cancelled) return false;
        // Missing/replaced pointer or broken coordinates: restore the preview.
        if (id != pointer || !finite(x, y)) { cancel(); return false; }
        dx = (double) x - startX;
        dy = (double) y - startY;
        if (Math.hypot(dx, dy) > slop) dragging = true;
        return dragging;
    }
    public void hold() { if (pointer >= 0) held = true; }
    public void additionalPointer() { cancel(); }
    public End end(int id, float x, float y, boolean systemCancelled) {
        if (pointer < 0) return cancelled ? End.CANCEL : End.NONE;
        if (systemCancelled || id != pointer || !finite(x, y)) { cancel(); return End.CANCEL; }
        move(id, x, y);
        End result = dragging ? End.DRAG : held ? End.NONE : End.TAP;
        pointer = -1;
        return result;
    }
    public void cancel() {
        pointer = -1;
        dx = dy = 0;
        dragging = held = false;
        cancelled = true;
    }
    public boolean active() { return pointer >= 0 && !cancelled; }
    public boolean dragging() { return active() && dragging; }
    public double deltaX() { return dx; }
    public double deltaY() { return dy; }

    /** Saturating conversion avoids overflow from malformed coordinates. Cell
     * snapping is done only when the result changes, not on every drawn frame. */
    public static int cells(double pixels, float step) {
        if (!Double.isFinite(pixels) || !Float.isFinite(step) || step <= 0)
            throw new IllegalArgumentException("Invalid grid movement");
        double value = Math.floor(pixels / step + 0.5d);
        return (int) Math.max(Integer.MIN_VALUE, Math.min(Integer.MAX_VALUE, value));
    }
}
