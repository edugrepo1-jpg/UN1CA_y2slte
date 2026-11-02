package com.gmhub.qs;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.Executor;
import java.util.function.Consumer;

/** Native Samsung QSHost adapter for the editable Apple panel.
 *
 * The owner constructs and calls this object on the UI thread. The executor must
 * post back to that same thread. Samsung owns authentication, radio operations,
 * policies and tile state; this class never writes radio settings directly.
 * No Lineage QSFragmentCompose, polling, broadcasts or extra Android service.
 * This source is staged until the complete Samsung panel binding is ready.
 */
public final class SamsungTiles implements AutoCloseable {
    private final Thread owner = Thread.currentThread();
    private final Executor ui;
    private final Runnable changed;
    private final Consumer<Throwable> errors;
    private final Map<String, Entry> entries = new LinkedHashMap<>();
    private final Map<Object, Boolean> owned = new IdentityHashMap<>();
    private Object host, hostCallback;
    private int user = -1, generation;
    private boolean listening, queued, closed;

    private static final class Entry {
        final String spec;
        final Object tile;
        Object callback;
        Entry(String spec, Object tile) { this.spec = spec; this.tile = tile; }
    }

    /** Values are copied from the mutable native state; the icon is a native
     * QSTile.Icon, rendered by the UI using QSHost.getUserContext(). */
    public static final class Tile {
        public final String spec, label, secondaryLabel, description;
        public final int state;
        public final boolean disabledByPolicy;
        public final Object icon;
        private Tile(Entry entry, Object nativeState, boolean connected) throws Exception {
            spec = entry.spec;
            label = text(value(nativeState, "label"));
            secondaryLabel = text(value(nativeState, "secondaryLabel"));
            description = text(value(nativeState, "contentDescription"));
            state = connected ? ((Number) value(nativeState, "state")).intValue() : 0;
            disabledByPolicy = Boolean.TRUE.equals(value(nativeState, "disabledByPolicy"));
            Object iconValue = value(nativeState, "icon");
            if (iconValue == null) {
                Object supplier = value(nativeState, "iconSupplier");
                if (supplier instanceof java.util.function.Supplier)
                    iconValue = ((java.util.function.Supplier<?>) supplier).get();
            }
            icon = iconValue;
        }
    }

    public SamsungTiles(Executor ui, Runnable changed, Consumer<Throwable> errors) {
        this.ui = java.util.Objects.requireNonNull(ui);
        this.changed = java.util.Objects.requireNonNull(changed);
        this.errors = java.util.Objects.requireNonNull(errors);
    }

    private void checkThread() {
        if (Thread.currentThread() != owner) throw new IllegalStateException("QS UI thread required");
    }
    private void report(Throwable error) { errors.accept(error); }
    private static String text(Object v) { return v == null ? "" : v.toString(); }
    private static Object value(Object receiver, String name) throws Exception {
        Field field = receiver.getClass().getField(name);
        field.setAccessible(true);
        return field.get(receiver);
    }
    private static Object call(Object receiver, String name, Object... args) throws Exception {
        Method match = null;
        for (Method method : receiver.getClass().getMethods()) {
            if (!method.getName().equals(name) || method.getParameterCount() != args.length) continue;
            Class<?>[] types = method.getParameterTypes();
            boolean compatible = true;
            for (int i = 0; i < types.length; i++) {
                Class<?> type = types[i] == boolean.class ? Boolean.class : types[i];
                if (args[i] != null && !type.isInstance(args[i])) compatible = false;
            }
            if (!compatible) continue;
            if (match != null) throw new NoSuchMethodException("Ambiguous " + name);
            match = method;
        }
        if (match == null) throw new NoSuchMethodException(name);
        match.setAccessible(true);
        return match.invoke(receiver, args);
    }

    /** Bind explicitly from SecQSPanelControllerBase.mHost; do not discover
     * private FragmentService containers or rely on AOSP class names. */
    public boolean bind(Object newHost) {
        checkThread();
        if (closed || newHost == null) return false;
        try {
            int newUser = ((Number) call(newHost, "getUserId")).intValue();
            if (host == newHost && user == newUser) return true;
            clearBinding();
            host = newHost;
            user = newUser;
            if (listening) startHostCallback();
            reconcile();
            return true;
        } catch (Exception | LinkageError error) {
            report(error);
            clearBinding();
            return false;
        }
    }

    public boolean isBound() { checkThread(); return !closed && host != null; }
    public Object userContext() {
        checkThread();
        try { return validUser() ? call(host, "getUserContext") : null; }
        catch (Exception error) { report(error); return null; }
    }
    private boolean validUser() throws Exception {
        if (host == null || closed) return false;
        if (((Number) call(host, "getUserId")).intValue() == user) return true;
        // Do not run previous-user tile actions, including custom TileService.
        clearBinding();
        notifySoon();
        return false;
    }
    private boolean permitted(String spec) throws Exception {
        return !Boolean.TRUE.equals(call(host, "isUnsupportedTile", spec))
            && !Boolean.TRUE.equals(call(host, "shouldBeHiddenByKnox", spec))
            && !Boolean.TRUE.equals(call(host, "shouldUnavailableByKnox", spec));
    }

    public void setListening(boolean enable) {
        checkThread();
        if (closed || listening == enable) return;
        listening = enable;
        if (!enable) {
            generation++;
            queued = false;
            stopHostCallback();
            for (Entry entry : entries.values()) detach(entry);
        } else if (host != null) {
            try { if (validUser()) { startHostCallback(); reconcile(); } }
            catch (Exception error) {
                listening = false;
                generation++;
                queued = false;
                stopHostCallback();
                for (Entry entry : entries.values()) detach(entry);
                report(error);
            }
        }
    }

    private Object callback(Object receiver, String method, String event, Runnable action) throws Exception {
        Method found = null;
        for (Method candidate : receiver.getClass().getMethods())
            if (candidate.getName().equals(method) && candidate.getParameterCount() == 1) {
                if (found != null) throw new NoSuchMethodException("Ambiguous " + method);
                found = candidate;
            }
        if (found == null) throw new NoSuchMethodException(method);
        Class<?> contract = found.getParameterTypes()[0];
        if (!contract.isInterface()) throw new IllegalArgumentException("Not a callback interface");
        int epoch = generation;
        Object proxy = Proxy.newProxyInstance(contract.getClassLoader(), new Class<?>[]{contract},
            (self, called, args) -> {
                switch (called.getName()) {
                    case "hashCode": return System.identityHashCode(self);
                    case "equals": return self == args[0];
                    case "toString": return "GMHubSamsungQSCallback";
                    default:
                        if (called.getName().equals(event)) ui.execute(() -> {
                            checkThread();
                            if (!closed && listening && generation == epoch) action.run();
                        });
                        return null;
                }
            });
        found.setAccessible(true);
        try { found.invoke(receiver, proxy); }
        catch (Exception error) {
            // An implementation may register before throwing. Release only our
            // callback; never removeCallbacks(), which belongs to native QS too.
            try { call(receiver, "removeCallback", proxy); } catch (Exception ignored) { }
            throw error;
        }
        return proxy;
    }
    private void startHostCallback() throws Exception {
        if (hostCallback == null)
            hostCallback = callback(host, "addCallback", "onTilesChanged", () -> {
                try { if (validUser()) reconcile(); }
                catch (Exception error) { report(error); }
            });
    }
    private void stopHostCallback() {
        Object previous = hostCallback;
        hostCallback = null;
        if (host != null && previous != null)
            try { call(host, "removeCallback", previous); } catch (Exception error) { report(error); }
    }
    private void attach(Entry entry) {
        if (!listening || entry.callback != null) return;
        try {
            entry.callback = callback(entry.tile, "addCallback", "onStateChanged", this::notifySoon);
            call(entry.tile, "setListening", this, true);
        } catch (Exception error) { detach(entry); report(error); }
    }
    private void detach(Entry entry) {
        Object previous = entry.callback;
        entry.callback = null;
        if (previous == null) return;
        try { call(entry.tile, "setListening", this, false); } catch (Exception error) { report(error); }
        try { call(entry.tile, "removeCallback", previous); } catch (Exception error) { report(error); }
    }
    private void destroyOwned(Object tile) {
        if (owned.remove(tile) != null)
            try { call(tile, "destroy"); } catch (Exception error) { report(error); }
    }
    private void reconcile() throws Exception {
        Collection<?> nativeTiles = (Collection<?>) call(host, "getTiles");
        Map<String, Entry> next = new LinkedHashMap<>();
        for (Object tile : nativeTiles) {
            if (tile == null || Boolean.TRUE.equals(call(tile, "isDestroyed"))) continue;
            // The host can adopt a previously preview-only instance. From this
            // point its lifetime belongs to Samsung, including after closing.
            owned.remove(tile);
            String spec = (String) call(tile, "getTileSpec");
            if (spec == null || spec.isEmpty() || !permitted(spec)) continue;
            Entry previous = entries.get(spec);
            next.put(spec, previous != null && previous.tile == tile ? previous : new Entry(spec, tile));
        }
        for (Entry previous : entries.values()) {
            if (next.containsKey(previous.spec)) {
                if (next.get(previous.spec) != previous) {
                    detach(previous);
                    destroyOwned(previous.tile);
                }
            } else if (owned.containsKey(previous.tile) && permitted(previous.spec)
                    && !Boolean.TRUE.equals(call(previous.tile, "isDestroyed"))) {
                next.put(previous.spec, previous);
            } else {
                detach(previous);
                destroyOwned(previous.tile);
            }
        }
        entries.clear();
        entries.putAll(next);
        for (Entry entry : entries.values()) attach(entry);
        notifySoon();
    }

    /** Catalog uses Samsung's real specs verbatim. Names/icons come from native
     * tile state, not a hard-coded Lineage catalog (VPN must not become Wallet).
     * No tile/service is created just to list the catalog. */
    public List<String> catalog() {
        checkThread();
        if (closed) return Collections.emptyList();
        try {
            if (!validUser()) return Collections.emptyList();
            Set<String> specs = new LinkedHashSet<>();
            for (String method : new String[]{"getSpecs", "getDefaultTileList"})
                for (Object value : (Collection<?>) call(host, method))
                    if (value instanceof String && !((String) value).isEmpty() && permitted((String) value))
                        specs.add((String) value);
            return Collections.unmodifiableList(new ArrayList<>(specs));
        } catch (Exception error) { report(error); return Collections.emptyList(); }
    }

    /** Additional controls do not alter Samsung's native QS layout. Owned tiles
     * are destroyed when the panel unbinds; native tiles are never destroyed. */
    public boolean ensure(String spec) {
        checkThread();
        Object created = null;
        try {
            if (!validUser() || spec == null || !permitted(spec)) return false;
            reconcile();
            if (entries.containsKey(spec)) return true;
            if (!catalog().contains(spec)) return false;
            if (spec.startsWith("custom(") && !Boolean.TRUE.equals(call(host, "isAvailableCustomTile", spec)))
                return false;
            created = call(host, "createTile", spec);
            if (created == null) return false;
            owned.put(created, true);
            call(created, "setTileSpec", spec);
            if (!Boolean.TRUE.equals(call(created, "isAvailable"))) { destroyOwned(created); return false; }
            Entry entry = new Entry(spec, created);
            entries.put(spec, entry);
            attach(entry);
            if (listening && entry.callback == null)
                throw new IllegalStateException("Tile listener did not attach: " + spec);
            call(created, "refreshState");
            notifySoon();
            return true;
        } catch (Exception error) {
            if (created != null) {
                Entry entry = entries.get(spec);
                if (entry != null && entry.tile == created) { detach(entry); entries.remove(spec); }
                destroyOwned(created);
            }
            report(error);
            return false;
        }
    }

    public List<Tile> snapshot() {
        checkThread();
        List<Tile> result = new ArrayList<>();
        try {
            if (!validUser()) return Collections.emptyList();
            for (Entry entry : entries.values()) {
                if (!permitted(entry.spec) || Boolean.TRUE.equals(call(entry.tile, "isDestroyed"))) continue;
                Object state = call(entry.tile, "getState");
                if (state != null) result.add(new Tile(entry, state, listening && entry.callback != null));
            }
        } catch (Exception error) { report(error); }
        return Collections.unmodifiableList(result);
    }
    public boolean click(String spec, boolean longClick, Object expandable) {
        checkThread();
        try {
            if (!listening || !validUser() || !permitted(spec)) return false;
            Entry entry = entries.get(spec);
            if (entry == null || entry.callback == null || Boolean.TRUE.equals(call(entry.tile, "isDestroyed"))) return false;
            Object state = call(entry.tile, "getState");
            if (state == null || ((Number) value(state, "state")).intValue() == 0
                    || Boolean.TRUE.equals(value(state, "disabledByPolicy"))) return false;
            call(entry.tile, longClick ? "longClick" : "click", expandable);
            return true;
        } catch (Exception error) { report(error); return false; }
    }
    private void notifySoon() {
        if (!listening || queued || closed) return;
        queued = true;
        int epoch = generation;
        ui.execute(() -> {
            checkThread();
            if (generation != epoch) return;
            queued = false;
            if (!closed && listening) changed.run();
        });
    }
    private void clearBinding() {
        generation++;
        queued = false;
        stopHostCallback();
        for (Entry entry : entries.values()) detach(entry);
        for (Object tile : new ArrayList<>(owned.keySet())) destroyOwned(tile);
        entries.clear();
        host = null;
        user = -1;
    }
    @Override public void close() {
        checkThread();
        clearBinding();
        listening = false;
        closed = true;
    }
}
