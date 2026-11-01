.class public Lcom/paradox/hub/ParadoxAppManagerFragment$1;
.super Ljava/lang/Thread;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {p0}, Ljava/lang/Thread;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 10

    iget-object v0, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    :cond_0
    invoke-virtual {v0}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    const/16 v2, 0x80

    invoke-virtual {v1, v2}, Landroid/content/pm/PackageManager;->getInstalledApplications(I)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :goto_0
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_3

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Landroid/content/pm/ApplicationInfo;

    iget v5, v4, Landroid/content/pm/ApplicationInfo;->flags:I

    and-int/lit8 v5, v5, 0x1

    if-eqz v5, :cond_1

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iget-boolean v5, v5, Lcom/paradox/hub/ParadoxAppManagerFragment;->mShowSystem:Z

    if-nez v5, :cond_1

    goto :goto_0

    :cond_1
    invoke-virtual {v4, v1}, Landroid/content/pm/ApplicationInfo;->loadLabel(Landroid/content/pm/PackageManager;)Ljava/lang/CharSequence;

    move-result-object v5

    invoke-interface {v5}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;

    move-result-object v6

    iget-object v7, v4, Landroid/content/pm/ApplicationInfo;->packageName:Ljava/lang/String;

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iget-object v5, v5, Lcom/paradox/hub/ParadoxAppManagerFragment;->mQuery:Ljava/lang/String;

    invoke-virtual {v5}, Ljava/lang/String;->isEmpty()Z

    move-result v8

    if-nez v8, :cond_2

    invoke-virtual {v6}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v5}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v8

    if-nez v8, :cond_2

    invoke-virtual {v7}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v5}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z

    move-result v8

    if-nez v8, :cond_2

    goto :goto_0

    :cond_2
    iget-boolean v8, v4, Landroid/content/pm/ApplicationInfo;->enabled:Z

    invoke-virtual {v4, v1}, Landroid/content/pm/ApplicationInfo;->loadIcon(Landroid/content/pm/PackageManager;)Landroid/graphics/drawable/Drawable;

    move-result-object v9

    new-instance v4, Lcom/paradox/hub/ParadoxAppManagerFragment$2;

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct/range {v4 .. v9}, Lcom/paradox/hub/ParadoxAppManagerFragment$2;-><init>(Lcom/paradox/hub/ParadoxAppManagerFragment;Ljava/lang/String;Ljava/lang/String;ZLandroid/graphics/drawable/Drawable;)V

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iget-object v5, v5, Lcom/paradox/hub/ParadoxAppManagerFragment;->mHandler:Landroid/os/Handler;

    invoke-virtual {v5, v4}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    goto :goto_0

    :cond_3
    new-instance v4, Lcom/paradox/hub/ParadoxAppManagerFragment$3;

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {v4, v5}, Lcom/paradox/hub/ParadoxAppManagerFragment$3;-><init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V

    iget-object v5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$1;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iget-object v5, v5, Lcom/paradox/hub/ParadoxAppManagerFragment;->mHandler:Landroid/os/Handler;

    invoke-virtual {v5, v4}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method
