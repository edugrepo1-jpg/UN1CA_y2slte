package android.view;
public class View {
    public static final int NO_ID = -1;
    ViewParent parent;
    private int id = NO_ID;
    private ViewGroup.LayoutParams params;
    public ViewParent getParent() { return parent; }
    public View getRootView() { View v=this; while(v.parent instanceof View) v=(View)v.parent; return v; }
    public ViewGroup.LayoutParams getLayoutParams() { return params; }
    public void setLayoutParams(ViewGroup.LayoutParams p) { params=p; }
    public int getId() { return id; }
    public void setId(int id) { this.id=id; }
    @SuppressWarnings("unchecked") public <T extends View> T findViewById(int id) { return this.id == id ? (T)this : null; }
}
