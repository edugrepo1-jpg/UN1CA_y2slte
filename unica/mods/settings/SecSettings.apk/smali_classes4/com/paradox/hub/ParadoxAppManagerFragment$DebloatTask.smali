.class public Lcom/paradox/hub/ParadoxAppManagerFragment$DebloatTask;
.super Ljava/lang/Thread;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

.field val$action:Ljava/lang/String;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxAppManagerFragment;Ljava/lang/String;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$DebloatTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iput-object p2, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$DebloatTask;->val$action:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 6

    :try_start_0
    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v0

    const/4 v1, 0x5

    new-array v2, v1, [Ljava/lang/String;

    const/4 v3, 0x0

    const-string v4, "com.samsung.android.bixby.agent"

    aput-object v4, v2, v3

    const/4 v3, 0x1

    const-string v4, "com.samsung.android.app.spage"

    aput-object v4, v2, v3

    const/4 v3, 0x2

    const-string v4, "com.sec.android.app.sbrowser"

    aput-object v4, v2, v3

    const/4 v3, 0x3

    const-string v4, "com.samsung.android.game.gametools"

    aput-object v4, v2, v3

    const/4 v3, 0x4

    const-string v4, "com.samsung.android.kidsinstaller"

    aput-object v4, v2, v3

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v1, :cond_0

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$DebloatTask;->val$action:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    aget-object v5, v2, v3

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v4}, Ljava/lang/Runtime;->exec(Ljava/lang/String;)Ljava/lang/Process;

    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    :cond_0
    new-instance v0, Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$DebloatTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {v0, v1}, Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;-><init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$DebloatTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iget-object v1, v1, Lcom/paradox/hub/ParadoxAppManagerFragment;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    return-void
.end method
