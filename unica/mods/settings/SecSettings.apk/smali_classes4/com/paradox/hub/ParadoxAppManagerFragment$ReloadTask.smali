.class public Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    iget-object v0, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-virtual {v0}, Lcom/paradox/hub/ParadoxAppManagerFragment;->loadApps()V

    return-void
.end method
