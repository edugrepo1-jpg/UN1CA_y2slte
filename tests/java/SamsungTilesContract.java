import com.gmhub.qs.SamsungTiles;
import java.util.*;
import java.util.concurrent.Executor;

/** Host behavioral contract, not an Android emulator or shipped API stub. */
public class SamsungTilesContract {
    public interface HostCallback { void onTilesChanged(); }
    public interface TileCallback { void onStateChanged(State state); }
    public static class State {
        public CharSequence label = "Wi-Fi", secondaryLabel = "Connected", contentDescription = "Wi-Fi connected";
        public int state = 2;
        public boolean disabledByPolicy;
        public Object icon;
        public java.util.function.Supplier<Object> iconSupplier = () -> "icon";
    }
    public static class Tile {
        public String spec;
        public final State state = new State();
        public final Set<TileCallback> callbacks = Collections.newSetFromMap(new IdentityHashMap<>());
        public final Set<Object> listening = Collections.newSetFromMap(new IdentityHashMap<>());
        public int clicks, longClicks, destroyed, refreshes;
        public boolean available = true, failListen, failRefresh, failAdd;
        Tile(String spec) { this.spec = spec; }
        public String getTileSpec() { return spec; }
        public void setTileSpec(String value) { spec = value; }
        public State getState() { return state; }
        public boolean isAvailable() { return available; }
        public boolean isDestroyed() { return destroyed > 0; }
        public void addCallback(TileCallback c) { callbacks.add(c); if (failAdd) throw new IllegalStateException("add"); }
        public void removeCallback(TileCallback c) { callbacks.remove(c); }
        public void setListening(Object owner, boolean on) {
            if (on) { listening.add(owner); if (failListen) throw new IllegalStateException("listen"); }
            else listening.remove(owner);
        }
        public void click(Object expandable) { clicks++; }
        public void longClick(Object expandable) { longClicks++; }
        public void refreshState() { if (failRefresh) throw new IllegalStateException("refresh"); refreshes++; }
        public void destroy() { destroyed++; }
        public void changed() { for (TileCallback c : new ArrayList<>(callbacks)) c.onStateChanged(state); }
    }
    public static class Host {
        public int user;
        public final List<Tile> tiles = new ArrayList<>();
        public final List<String> specs = new ArrayList<>(Arrays.asList("Wifi", "Bluetooth", "SoundMode"));
        public final List<String> defaults = new ArrayList<>(Arrays.asList("Wifi", "Nfc", "custom(package/.Tile)"));
        public final Set<String> unsupported = new HashSet<>(), hidden = new HashSet<>(), unavailable = new HashSet<>();
        public final Set<HostCallback> callbacks = Collections.newSetFromMap(new IdentityHashMap<>());
        public final Map<String,Tile> created = new HashMap<>();
        public boolean failHostAdd, customAvailable;
        public int getUserId() { return user; }
        public Object getUserContext() { return "context-" + user; }
        public Collection<Tile> getTiles() { return tiles; }
        public List<String> getSpecs() { return specs; }
        public List<String> getDefaultTileList() { return defaults; }
        public boolean isUnsupportedTile(String s) { return unsupported.contains(s); }
        public boolean shouldBeHiddenByKnox(String s) { return hidden.contains(s); }
        public boolean shouldUnavailableByKnox(String s) { return unavailable.contains(s); }
        public boolean isAvailableCustomTile(String s) { return customAvailable; }
        public Tile createTile(String s) { return created.computeIfAbsent(s, Tile::new); }
        public void addCallback(HostCallback c) { callbacks.add(c); if (failHostAdd) throw new IllegalStateException("host add"); }
        public void removeCallback(HostCallback c) { callbacks.remove(c); }
        public void changed() { for (HostCallback c : new ArrayList<>(callbacks)) c.onTilesChanged(); }
    }
    public static class Queue implements Executor {
        final Deque<Runnable> work = new ArrayDeque<>();
        public synchronized void execute(Runnable r) { work.add(r); }
        public void drain() { while (!work.isEmpty()) work.remove().run(); }
    }
    static int checks;
    static void check(boolean value) { checks++; if (!value) throw new AssertionError("check " + checks); }
    static class Fixture {
        final Host host = new Host(); final Queue ui = new Queue();
        final List<Throwable> errors = new ArrayList<>(); int updates;
        final SamsungTiles bridge = new SamsungTiles(ui, () -> updates++, errors::add);
        final Tile wifi = new Tile("Wifi");
        Fixture() { host.tiles.add(wifi); check(bridge.bind(host)); }
        void open() { bridge.setListening(true); ui.drain(); }
    }
    static void actionsAndState() throws Exception {
        Fixture f = new Fixture();
        check(f.wifi.callbacks.isEmpty() && f.host.callbacks.isEmpty());
        f.open();
        check(f.wifi.callbacks.size() == 1 && f.host.callbacks.size() == 1);
        check(f.wifi.listening.size() == 1 && f.bridge.userContext().equals("context-0"));
        SamsungTiles.Tile old = f.bridge.snapshot().get(0);
        check(old.spec.equals("Wifi") && old.label.equals("Wi-Fi") && old.icon.equals("icon"));
        f.wifi.state.label = "New network";
        check(old.label.equals("Wi-Fi"));
        check(f.bridge.click("Wifi", false, null) && f.bridge.click("Wifi", true, null));
        check(f.wifi.clicks == 1 && f.wifi.longClicks == 1);
        f.wifi.state.state = 0; check(!f.bridge.click("Wifi", false, null));
        f.wifi.state.state = 2; f.wifi.state.disabledByPolicy = true;
        check(!f.bridge.click("Wifi", false, null));
        f.wifi.state.disabledByPolicy = false;
        int before = f.updates;
        Thread tileThread = new Thread(() -> { for (int i = 0; i < 30; i++) f.wifi.changed(); });
        tileThread.start(); tileThread.join(); f.ui.drain();
        check(f.updates == before + 1);
        check(f.errors.isEmpty());
        f.bridge.close();
        check(f.wifi.callbacks.isEmpty() && f.wifi.listening.isEmpty() && f.host.callbacks.isEmpty());
        check(f.wifi.destroyed == 0);
    }
    static void replacementAndStaleCallbacks() {
        Fixture f = new Fixture(); f.open();
        TileCallback oldCallback = f.wifi.callbacks.iterator().next();
        Tile replacement = new Tile("Wifi");
        f.host.tiles.set(0, replacement); f.host.changed(); f.ui.drain();
        check(f.wifi.callbacks.isEmpty() && f.wifi.listening.isEmpty());
        check(replacement.callbacks.size() == 1 && replacement.listening.size() == 1);
        check(f.wifi.destroyed == 0);
        oldCallback.onStateChanged(f.wifi.state);
        f.bridge.setListening(false); f.ui.drain();
        int before = f.updates; oldCallback.onStateChanged(f.wifi.state); f.ui.drain();
        check(f.updates == before);
        check(!f.bridge.click("Wifi", false, null));
        for (int i = 0; i < 20; i++) { f.bridge.setListening(true); f.bridge.setListening(false); }
        check(replacement.callbacks.isEmpty() && replacement.listening.isEmpty() && f.host.callbacks.isEmpty());
        f.ui.drain(); f.bridge.close(); check(f.errors.isEmpty());
    }
    static void catalogAndOwnership() {
        Fixture f = new Fixture(); f.open();
        List<String> catalog = f.bridge.catalog();
        check(catalog.equals(Arrays.asList("Wifi", "Bluetooth", "SoundMode", "Nfc", "custom(package/.Tile)")));
        check(f.host.created.isEmpty());
        check(!f.bridge.ensure("vpn") && !f.bridge.ensure("custom(package/.Tile)"));
        check(!f.host.created.containsKey("custom(package/.Tile)"));
        check(f.bridge.ensure("Nfc"));
        Tile nfc = f.host.created.get("Nfc"); check(nfc.listening.size() == 1 && nfc.refreshes == 1);
        check(f.bridge.ensure("Nfc") && nfc.callbacks.size() == 1);
        check(f.host.specs.equals(Arrays.asList("Wifi", "Bluetooth", "SoundMode")));
        f.host.created.put("Bluetooth", new Tile("Bluetooth"));
        f.host.created.get("Bluetooth").available = false;
        check(!f.bridge.ensure("Bluetooth") && f.host.created.get("Bluetooth").destroyed == 1);
        f.bridge.close();
        check(nfc.destroyed == 1 && nfc.callbacks.isEmpty() && nfc.listening.isEmpty());
        check(f.wifi.destroyed == 0);
        Fixture adoption = new Fixture(); adoption.open(); check(adoption.bridge.ensure("Nfc"));
        Tile adopted = adoption.host.created.get("Nfc");
        adoption.host.tiles.add(adopted); adoption.host.changed(); adoption.ui.drain(); adoption.bridge.close();
        check(adopted.destroyed == 0 && adopted.callbacks.isEmpty());
    }
    static void policiesAndUsers() {
        Fixture f = new Fixture(); f.open();
        f.host.hidden.add("Wifi");
        check(f.bridge.snapshot().isEmpty() && !f.bridge.click("Wifi", false, null));
        check(!f.bridge.catalog().contains("Wifi") && !f.bridge.ensure("Wifi"));
        f.host.hidden.clear(); f.host.unavailable.add("Nfc");
        check(!f.bridge.ensure("Nfc")); f.host.unavailable.clear(); f.host.unsupported.add("Nfc");
        check(!f.bridge.catalog().contains("Nfc"));
        f.host.user = 10;
        check(!f.bridge.click("Wifi", false, null) && !f.bridge.isBound());
        check(f.wifi.callbacks.isEmpty() && f.host.callbacks.isEmpty());
        check(f.bridge.bind(f.host) && f.bridge.userContext().equals("context-10"));
        check(f.wifi.callbacks.size() == 1); f.bridge.close();
    }
    static void cleanupFailures() {
        Fixture f = new Fixture(); f.wifi.failListen = true; f.open();
        check(!f.errors.isEmpty() && f.wifi.callbacks.isEmpty() && f.wifi.listening.isEmpty());
        check(!f.bridge.click("Wifi", false, null) && f.bridge.snapshot().get(0).state == 0);
        f.bridge.close();
        Fixture add = new Fixture(); add.wifi.failAdd = true; add.open();
        check(add.wifi.callbacks.isEmpty() && !add.errors.isEmpty()); add.bridge.close();
        Fixture host = new Fixture(); host.host.failHostAdd = true; host.open();
        check(host.host.callbacks.isEmpty() && !host.errors.isEmpty());
        check(!host.bridge.click("Wifi", false, null)); host.bridge.close();
        Fixture created = new Fixture(); created.open();
        Tile failed = new Tile("Nfc"); failed.failRefresh = true; created.host.created.put("Nfc", failed);
        check(!created.bridge.ensure("Nfc"));
        check(failed.destroyed == 1 && failed.callbacks.isEmpty() && failed.listening.isEmpty());
        check(created.bridge.snapshot().size() == 1); created.bridge.close();
        Fixture listener = new Fixture(); listener.open();
        Tile unconnected = new Tile("Nfc"); unconnected.failListen = true;
        listener.host.created.put("Nfc", unconnected);
        check(!listener.bridge.ensure("Nfc"));
        check(unconnected.destroyed == 1 && unconnected.callbacks.isEmpty() && unconnected.listening.isEmpty());
        listener.bridge.close();
    }
    static void wrongThreadAndClose() throws Exception {
        Fixture f = new Fixture(); f.open();
        List<Throwable> rejected = new ArrayList<>();
        Thread thread = new Thread(() -> {
            try { f.bridge.click("Wifi", false, null); } catch (Throwable e) { rejected.add(e); }
        });
        thread.start(); thread.join();
        check(rejected.size() == 1 && rejected.get(0) instanceof IllegalStateException);
        f.bridge.close(); f.ui.drain();
        check(!f.bridge.bind(f.host) && f.bridge.catalog().isEmpty() && f.bridge.snapshot().isEmpty());
        f.bridge.close(); check(f.wifi.destroyed == 0);
    }
    public static void main(String[] args) throws Exception {
        actionsAndState(); replacementAndStaleCallbacks(); catalogAndOwnership();
        policiesAndUsers(); cleanupFailures(); wrongThreadAndClose();
        System.out.println("Samsung QS behavioral checks passed: " + checks);
    }
}
