import android.view.*;
import com.gmhub.qs.NativeViewLease;
import java.util.*;

public class NativeViewLeaseContract {
    static int checks;
    static void check(boolean ok) { checks++; if(!ok)throw new AssertionError("check "+checks); }
    static ViewGroup.LayoutParams lp() { return new ViewGroup.LayoutParams(300,200); }
    static class Tree {
        final ViewGroup root=new ViewGroup(), original=new ViewGroup(), destination=new ViewGroup(), other=new ViewGroup();
        final View player=new View(), before=new View(), after=new View();
        final ViewGroup.LayoutParams params=lp();
        Tree() {
            root.addView(original,lp());root.addView(destination,lp());root.addView(other,lp());
            original.addView(before,lp());original.addView(player,params);original.addView(after,lp());player.setId(27);
        }
    }
    static void reject(Runnable action) {
        boolean threw=false;try { action.run(); } catch(IllegalArgumentException|IllegalStateException e) { threw=true; }
        check(threw);
    }
    public static void main(String[] args)throws Exception {
        Tree t=new Tree();NativeViewLease lease=NativeViewLease.take(t.player,t.destination,lp());
        check(lease.view()==t.player && lease.active() && t.player.getParent()==t.destination);
        check(t.original.getChildCount()==2 && t.destination.getChildCount()==1);
        check(t.params.width==300 && t.params.height==200);
        reject(()->NativeViewLease.take(t.player,t.other,lp()));
        check(lease.resize(new ViewGroup.LayoutParams(400,250)));
        check(t.player.getLayoutParams().width==400 && t.params.width==300);
        check(lease.release(true));
        check(t.player.getParent()==t.original && t.original.indexOfChild(t.player)==1);
        check(t.player.getLayoutParams()==t.params && t.destination.getChildCount()==0);
        check(!lease.active() && !lease.release(true));
        Tree cross=new Tree();reject(()->NativeViewLease.take(cross.player,new ViewGroup(),lp()));
        check(cross.player.getParent()==cross.original);
        reject(()->NativeViewLease.take(cross.player,cross.destination,cross.params));
        Tree adopted=new Tree();NativeViewLease borrowed=NativeViewLease.take(adopted.player,adopted.destination,lp());
        adopted.destination.removeView(adopted.player);adopted.other.addView(adopted.player,lp());
        check(!borrowed.release(true) && adopted.player.getParent()==adopted.other);
        Tree replaced=new Tree();NativeViewLease old=NativeViewLease.take(replaced.player,replaced.destination,lp());
        View newer=new View();newer.setId(27);replaced.original.addView(newer,lp());
        check(!old.release(true) && replaced.player.getParent()==null && newer.getParent()==replaced.original);
        check(replaced.original.getChildCount()==3);
        for(boolean after:new boolean[]{false,true}) {
            Tree fail=new Tree();fail.destination.failBefore=!after;fail.destination.failAfter=after;
            reject(()->NativeViewLease.take(fail.player,fail.destination,lp()));
            check(fail.player.getParent()==fail.original && fail.original.indexOfChild(fail.player)==1);
            check(fail.player.getLayoutParams()==fail.params && fail.destination.getChildCount()==0);
            NativeViewLease retry=NativeViewLease.take(fail.player,fail.destination,lp());check(retry.release(true));
        }
        Tree memory=new Tree();memory.destination.failMemory=true;boolean failed=false;
        try { NativeViewLease.take(memory.player,memory.destination,lp()); }
        catch(OutOfMemoryError error) { failed=true; }
        check(failed && memory.player.getParent()==memory.original && memory.player.getLayoutParams()==memory.params);
        check(NativeViewLease.take(memory.player,memory.destination,lp()).release(true));
        Tree cycle=new Tree();ViewGroup nativeGroup=new ViewGroup(), descendant=new ViewGroup();
        cycle.original.addView(nativeGroup,lp());nativeGroup.addView(descendant,lp());
        reject(()->NativeViewLease.take(nativeGroup,descendant,lp()));check(nativeGroup.getParent()==cycle.original);
        Tree obsolete=new Tree();NativeViewLease stale=NativeViewLease.take(obsolete.player,obsolete.destination,lp());
        check(!stale.release(false) && obsolete.player.getParent()==null);
        Tree thread=new Tree();List<Throwable> errors=new ArrayList<>();
        Thread worker=new Thread(()->{try { NativeViewLease.take(thread.player,thread.destination,lp()); }
            catch(Throwable e) { errors.add(e); }});worker.start();worker.join();
        check(errors.size()==1 && errors.get(0) instanceof IllegalStateException);
        check(thread.player.getParent()==thread.original);
        System.out.println("Native view loan/rollback/ownership checks passed: "+checks+"; host fixtures only");
    }
}
