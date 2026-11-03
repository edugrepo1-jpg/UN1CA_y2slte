package android.view;
import java.util.*;
public class ViewGroup extends View implements ViewParent {
    private final List<View> children = new ArrayList<>();
    public boolean failBefore, failAfter, failMemory;
    public static class LayoutParams {
        public int width,height;
        public LayoutParams(int w,int h) { width=w;height=h; }
    }
    public void addView(View v,LayoutParams p) { addView(v,children.size(),p); }
    public void addView(View v,int index,LayoutParams p) {
        if(failBefore) { failBefore=false;throw new IllegalStateException("before add"); }
        if(v.parent!=null)throw new IllegalStateException("already has a parent");
        children.add(index,v);v.parent=this;v.setLayoutParams(p);
        if(failMemory) { failMemory=false;throw new OutOfMemoryError("simulated view attach allocation"); }
        if(failAfter) { failAfter=false;throw new IllegalStateException("after add"); }
    }
    public void removeView(View v) { if(children.remove(v))v.parent=null; }
    public int indexOfChild(View v) { return children.indexOf(v); }
    public int getChildCount() { return children.size(); }
    @Override public <T extends View> T findViewById(int id) {
        T self=super.findViewById(id);if(self!=null)return self;
        for(View v:children) { T found=v.findViewById(id);if(found!=null)return found; }
        return null;
    }
}
