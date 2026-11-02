package com.gmhub.qs;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

/** API37 Samsung Compose scene binding. Keeps native grid items/view models for
 * media, brightness, volume, gallery and native edit actions. In particular a
 * Compose MediaPlayer must not be treated as a legacy SecMediaHost View.
 * No native coroutine/ViewModel/controller is created or cleared by this class.
 */
public final class SamsungScene implements AutoCloseable {
    private final Thread owner = Thread.currentThread();
    private final Object model, adapter, host, store, available;
    private final int user;
    private final SamsungTiles tiles;
    private final Method collapse, edit, power, settings, dragging;
    private boolean closed, ownsDrag;

    public static final class Slot {
        public final Object nativeSlot, nativeItem;
        public final String key, type;
        public final int x, y, width, height;
        public final boolean resizable;
        private Slot(Object slot) throws Exception {
            nativeSlot = slot;
            nativeItem = field(slot, "gridTileItem");
            key = (String) invoke(nativeItem, "getUniqueKey");
            type = (String) invoke(nativeItem, "getType");
            x = number(invoke(slot, "getSpanX")); y = number(invoke(slot, "getSpanY"));
            width = number(invoke(slot, "getSpanWidth")); height = number(invoke(slot, "getSpanHeight"));
            resizable = Boolean.TRUE.equals(invoke(nativeItem, "isResizeEnabled"));
            if (key == null || type == null || key.isEmpty() || x < 0 || y < 0 || width <= 0 || height <= 0)
                throw new IllegalArgumentException("Invalid Samsung grid slot");
        }
    }
    public static final class Bounds {
        public final int minWidth, minHeight, maxWidth, maxHeight;
        private Bounds(Object nativeConstraints) throws Exception {
            long min = ((Number) field(nativeConstraints, "min")).longValue();
            long max = ((Number) field(nativeConstraints, "max")).longValue();
            // The exact Samsung implementation uses Compose IntSize packing.
            minWidth = (int) (min >> 32); minHeight = (int) min;
            maxWidth = (int) (max >> 32); maxHeight = (int) max;
            if (minWidth < 1 || minHeight < 1 || maxWidth < minWidth || maxHeight < minHeight)
                throw new IllegalArgumentException("Invalid native resize constraints");
        }
        public boolean allows(int width, int height) {
            return width >= minWidth && width <= maxWidth && height >= minHeight && height <= maxHeight;
        }
    }
    public SamsungScene(Object nativeScene, SamsungTiles tiles) throws Exception {
        model = field(nativeScene, "viewModel");
        adapter = field(nativeScene, "qsAdapter");
        host = field(model, "qsHost");
        store = field(model, "$$delegate_2");
        available = field(model, "$$delegate_3");
        user = number(invoke(host, "getUserId"));
        collapse = method(model, "collapse"); edit = method(model, "launchEditMode");
        power = method(model, "launchPowerMenu"); settings = method(model, "launchSettings");
        dragging = method(model, "setOtherComponentDragging", boolean.class);
        // Validate the modern palette/slot contracts before binding callbacks.
        field(available, "allTiles"); field(store, "qsPanelItems");
        this.tiles = java.util.Objects.requireNonNull(tiles);
        if (!tiles.bind(host)) throw new IllegalArgumentException("Samsung QSHost binding failed");
    }
    private static int number(Object object) { return ((Number) object).intValue(); }
    private static Object field(Object object, String name) throws Exception {
        Field field = object.getClass().getField(name); field.setAccessible(true); return field.get(object);
    }
    private static Method method(Object object, String name, Class<?>... types) throws Exception {
        Method method = object.getClass().getMethod(name, types); method.setAccessible(true); return method;
    }
    private static Object invoke(Object object, String name) throws Exception {
        return method(object, name).invoke(object);
    }
    private void check() throws Exception {
        if (Thread.currentThread() != owner) throw new IllegalStateException("QS UI thread required");
        if (closed) throw new IllegalStateException("Samsung scene is closed");
        if (number(invoke(host, "getUserId")) != user) {
            close();
            throw new IllegalStateException("QS user changed; rebind the scene");
        }
    }
    public Object nativeModel() throws Exception { check(); return model; }
    public Object nativeAdapter() throws Exception { check(); return adapter; }
    /** Compose continues to collect the original flows; no replacement polling
     * loop or independent Bluetooth/brightness/media service is started. */
    public List<Object> palette() throws Exception {
        check();
        Object values = invoke(field(available, "allTiles"), "getValue");
        if (!(values instanceof Collection)) throw new IllegalArgumentException("Changed native gallery contract");
        return Collections.unmodifiableList(new ArrayList<>((Collection<?>) values));
    }
    public List<Slot> slots() throws Exception {
        check();
        Object values = invoke(field(store, "qsPanelItems"), "getValue");
        if (!(values instanceof Collection)) throw new IllegalArgumentException("Changed native panel item contract");
        List<Slot> result = new ArrayList<>();
        for (Object slot : (Collection<?>) values) result.add(new Slot(slot));
        return Collections.unmodifiableList(result);
    }
    /** The caller supplies the exact native screen flags, not assumptions based
     * on orientation or device name. Native media limits can differ per mode. */
    public Bounds bounds(Slot slot, int columns, int rows, boolean screenFlag, boolean deviceFlag) throws Exception {
        check();
        if (slot == null || columns < 1 || rows < 1) throw new IllegalArgumentException("Invalid native resize request");
        Object result = method(slot.nativeItem, "resizeConstraints", int.class, int.class, boolean.class, boolean.class)
            .invoke(slot.nativeItem, columns, rows, screenFlag, deviceFlag);
        return new Bounds(result);
    }
    public boolean edit() throws Exception {
        check();
        Object keyguard = field(model, "keyguardStateController");
        if (!Boolean.TRUE.equals(invoke(keyguard, "isUnlocked"))
                || Boolean.TRUE.equals(invoke(keyguard, "isVisible"))) return false;
        edit.invoke(model); return true;
    }
    public void collapse() throws Exception { check(); collapse.invoke(model); }
    public void powerMenu() throws Exception { check(); power.invoke(model); }
    public void settings() throws Exception { check(); settings.invoke(model); }
    public void dragging(boolean active) throws Exception {
        check();
        if (ownsDrag == active) return;
        dragging.invoke(model, active); ownsDrag = active;
    }
    @Override public void close() {
        if (Thread.currentThread() != owner) throw new IllegalStateException("QS UI thread required");
        if (closed) return;
        try {
            if (ownsDrag) dragging.invoke(model, false);
        } catch (ReflectiveOperationException ignored) {
            // The native owner may have been destroyed during a user switch.
        } finally {
            ownsDrag = false; closed = true;
            tiles.setListening(false);
        }
    }
}
