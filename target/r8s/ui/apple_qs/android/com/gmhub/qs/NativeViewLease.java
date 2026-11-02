package com.gmhub.qs;

import android.os.Looper;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import java.util.WeakHashMap;

/** Moves an existing View-backed legacy player/slider, preserving its controller,
 * contents, listeners and appearance. No cloning or second MediaSession host.
 * Only borrow inside the same SystemUI window; the UI owner closes the lease
 * before switching user/window, leaving QS or rebuilding on configuration.
 * The API37 Compose MediaPlayer uses SamsungScene's native slot instead; it
 * must never be replaced with or mistaken for a legacy SecMediaHost View.
 */
public final class NativeViewLease implements AutoCloseable {
    // Values do not retain keys/views/leases: no WeakHashMap reference cycle.
    private static final WeakHashMap<View, Object> ACTIVE = new WeakHashMap<>();
    private final View view, window;
    private final ViewGroup original, destination;
    private final ViewGroup.LayoutParams originalParams;
    private final int originalIndex;
    private final Object marker = new Object();
    private boolean active;

    private NativeViewLease(View view, ViewGroup original, ViewGroup destination) {
        this.view = view; this.original = original; this.destination = destination;
        window = original.getRootView(); originalIndex = original.indexOfChild(view);
        originalParams = view.getLayoutParams();
    }
    private static void mainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) throw new IllegalStateException("QS UI thread required");
    }
    public static NativeViewLease take(View view, ViewGroup destination, ViewGroup.LayoutParams params) {
        mainThread();
        if (view == null || destination == null || params == null || !(view.getParent() instanceof ViewGroup))
            throw new IllegalArgumentException("Native view must have an owner");
        ViewGroup original = (ViewGroup) view.getParent();
        if (original == destination || original.getRootView() != destination.getRootView())
            throw new IllegalArgumentException("Native view cannot cross SystemUI windows");
        for (ViewParent parent = destination; parent != null; parent = parent.getParent())
            if (parent == view) throw new IllegalArgumentException("Native view hierarchy cycle");
        if (ACTIVE.containsKey(view)) throw new IllegalStateException("Native view already borrowed");
        NativeViewLease lease = new NativeViewLease(view, original, destination);
        if (lease.originalIndex < 0 || lease.originalParams == null || params == lease.originalParams)
            throw new IllegalArgumentException("Native layout ownership changed");
        ACTIVE.put(view, lease.marker);
        try {
            original.removeView(view);
            destination.addView(view, params);
            lease.active = true;
            return lease;
        } catch (RuntimeException | LinkageError | OutOfMemoryError error) {
            // addView/onAttached callbacks may fail after attaching the child.
            // Undo only our reparenting; don't steal a view adopted elsewhere.
            try {
                if (view.getParent() == destination) destination.removeView(view);
                if (view.getParent() == null)
                    original.addView(view, Math.min(lease.originalIndex, original.getChildCount()), lease.originalParams);
            } catch (RuntimeException | LinkageError | OutOfMemoryError rollback) { error.addSuppressed(rollback); }
            finally { ACTIVE.remove(view); }
            throw error;
        }
    }
    public View view() { return view; }
    public boolean active() { mainThread(); return active && view.getParent() == destination; }
    public boolean resize(ViewGroup.LayoutParams params) {
        mainThread();
        if (!active() || params == null || params == originalParams) return false;
        view.setLayoutParams(params);
        return true;
    }
    /** restore=false is for an obsolete native controller/window. Its owner
     * performs native teardown; this adapter never destroys native controllers. */
    public boolean release(boolean restore) {
        mainThread();
        if (!active) return false;
        active = false;
        try {
            if (view.getParent() != destination) return false;
            destination.removeView(view);
            if (!restore || original.getRootView() != window) return false;
            int id = view.getId();
            View replacement = id == View.NO_ID ? null : original.findViewById(id);
            // Configuration can create a new native view while a lease closes.
            if (replacement != null && replacement != view) return false;
            original.addView(view, Math.min(originalIndex, original.getChildCount()), originalParams);
            return true;
        } finally {
            if (ACTIVE.get(view) == marker) ACTIVE.remove(view);
        }
    }
    @Override public void close() { release(true); }
}
