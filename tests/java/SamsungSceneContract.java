import com.gmhub.qs.*;
import java.util.*;

public class SamsungSceneContract {
    static int checks;
    static void check(boolean value) { checks++; if(!value)throw new AssertionError("check "+checks); }
    public interface HostCallback { void onTilesChanged(); }
    public static class Host {
        public int user;
        public int getUserId(){return user;}
        public Object getUserContext(){return "user"+user;}
        public Collection<Object> getTiles(){return Collections.emptyList();}
        public void addCallback(HostCallback c){}
        public void removeCallback(HostCallback c){}
    }
    public static class Flow {
        public final List<Object> value=new ArrayList<>();
        public Object getValue(){return value;}
    }
    public static class Store { public final Flow qsPanelItems=new Flow(); }
    public static class Available { public final Flow allTiles=new Flow(); }
    public static class Keyguard {
        public boolean unlocked=true,visible;
        public boolean isUnlocked(){return unlocked;}
        public boolean isVisible(){return visible;}
    }
    public static class Model {
        public final Host qsHost=new Host();
        public final Store $$delegate_2=new Store();
        public final Available $$delegate_3=new Available();
        public final Keyguard keyguardStateController=new Keyguard();
        public int edits,collapses,powers,settings;
        public boolean dragging;
        public void launchEditMode(){edits++;}
        public void collapse(){collapses++;}
        public void launchPowerMenu(){powers++;}
        public void launchSettings(){settings++;}
        public void setOtherComponentDragging(boolean active){dragging=active;}
    }
    public static class Scene { public final Model viewModel=new Model();public final Object qsAdapter=new Object(); }
    public static class Constraints { public long min=(2L<<32)|2, max=(4L<<32)|4; }
    public static class Item {
        public final Object viewModel=new Object(); // original media ViewModel identity.
        public int lastColumns,lastRows;public boolean lastScreen,lastDevice;
        public String getUniqueKey(){return "NativeMediaPlayer";}
        public String getType(){return "MediaPlayer";}
        public boolean isResizeEnabled(){return true;}
        public Constraints resizeConstraints(int columns,int rows,boolean screen,boolean device){
            lastColumns=columns;lastRows=rows;lastScreen=screen;lastDevice=device;return new Constraints();
        }
    }
    public static class Slot {
        public final Item gridTileItem=new Item();
        public int getSpanX(){return 2;}public int getSpanY(){return 0;}
        public int getSpanWidth(){return 2;}public int getSpanHeight(){return 2;}
    }
    public static void main(String[] args)throws Exception {
        Scene original=new Scene();Slot nativeSlot=new Slot();
        original.viewModel.$$delegate_2.qsPanelItems.value.add(nativeSlot);
        original.viewModel.$$delegate_3.allTiles.value.add(nativeSlot.gridTileItem);
        List<Throwable> errors=new ArrayList<>();SamsungTiles tiles=new SamsungTiles(Runnable::run,()->{},errors::add);
        SamsungScene scene=new SamsungScene(original,tiles);
        check(scene.nativeModel()==original.viewModel && scene.nativeAdapter()==original.qsAdapter);
        check(scene.palette().get(0)==nativeSlot.gridTileItem);
        SamsungScene.Slot slot=scene.slots().get(0);
        check(slot.nativeItem==nativeSlot.gridTileItem && slot.nativeSlot==nativeSlot);
        check(slot.type.equals("MediaPlayer") && slot.width==2 && slot.resizable);
        SamsungScene.Bounds bounds=scene.bounds(slot,8,12,true,false);
        check(bounds.allows(2,2) && bounds.allows(4,4) && !bounds.allows(1,1) && !bounds.allows(5,4));
        check(nativeSlot.gridTileItem.lastColumns==8 && nativeSlot.gridTileItem.lastRows==12
            && nativeSlot.gridTileItem.lastScreen && !nativeSlot.gridTileItem.lastDevice);
        check(scene.edit() && original.viewModel.edits==1);
        original.viewModel.keyguardStateController.visible=true;
        check(!scene.edit() && original.viewModel.edits==1);
        original.viewModel.keyguardStateController.visible=false;original.viewModel.keyguardStateController.unlocked=false;
        check(!scene.edit() && original.viewModel.edits==1);
        scene.powerMenu();scene.settings();scene.collapse();
        check(original.viewModel.powers==1 && original.viewModel.settings==1 && original.viewModel.collapses==1);
        scene.dragging(true);check(original.viewModel.dragging);scene.close();
        check(!original.viewModel.dragging && errors.isEmpty());
        boolean closed=false;try{scene.palette();}catch(IllegalStateException e){closed=true;}check(closed);
        scene.close();
        SamsungScene switched=new SamsungScene(original,tiles);switched.dragging(true);
        original.viewModel.qsHost.user=10;
        boolean invalid=false;try{switched.powerMenu();}catch(IllegalStateException e){invalid=true;}
        check(invalid && !original.viewModel.dragging && original.viewModel.powers==1);
        tiles.close();
        System.out.println("Samsung Compose scene/native item/security checks passed: "+checks);
    }
}
