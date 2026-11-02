package android.os;
/** Narrow host fixture; never packaged in the ROM or Android DEX. */
public final class Looper {
    private static final Thread OWNER = Thread.currentThread();
    private static final Looper MAIN = new Looper();
    public static Looper getMainLooper() { return MAIN; }
    public static Looper myLooper() { return Thread.currentThread() == OWNER ? MAIN : null; }
}
