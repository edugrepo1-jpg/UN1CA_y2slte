.class public Lcom/paradox/hub/ParadoxAppManagerFragment$RestoreTask;
.super Ljava/lang/Thread;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$RestoreTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 7

    :try_start_0
    iget-object v0, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$RestoreTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    const/16 v1, 0x200

    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstalledApplications(I)Ljava/util/List;

    move-result-object v1

    invoke-static {}, Ljava/lang/Runtime;->getRuntime()Ljava/lang/Runtime;

    move-result-object v2

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Landroid/content/pm/ApplicationInfo;

    iget-boolean v5, v4, Landroid/content/pm/ApplicationInfo;->enabled:Z

    if-nez v5, :cond_0

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "pm enable "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v6, v4, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v2, v5}, Ljava/lang/Runtime;->exec(Ljava/lang/String;)Ljava/lang/Process;

    :cond_0
    goto :goto_0

    :cond_1
    new-instance v0, Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$RestoreTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {v0, v1}, Lcom/paradox/hub/ParadoxAppManagerFragment$ReloadTask;-><init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$RestoreTask;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iget-object v1, v1, Lcom/paradox/hub/ParadoxAppManagerFragment;->mHandler:Landroid/os/Handler;

    invoke-virtual {v1, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    return-void
.end method
