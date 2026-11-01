.class public Lcom/paradox/hub/ParadoxBatteryFragment;
.super Lcom/android/settings/SettingsPreferenceFragment;


# instance fields
.field public mHandler:Landroid/os/Handler;

.field public mUpdateTask:Ljava/lang/Runnable;


# direct methods
.method public constructor <init>()V
    .locals 2

    invoke-direct {p0}, Lcom/android/settings/SettingsPreferenceFragment;-><init>()V

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment;->mHandler:Landroid/os/Handler;

    new-instance v0, Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;

    invoke-direct {v0, p0}, Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;-><init>(Lcom/paradox/hub/ParadoxBatteryFragment;)V

    iput-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment;->mUpdateTask:Ljava/lang/Runnable;

    return-void
.end method


# virtual methods
.method public getMetricsCategory()I
    .locals 1

    const/4 v0, 0x0

    return v0
.end method

.method public onCreatePreferences(Landroid/os/Bundle;Ljava/lang/String;)V
    .locals 4

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    const-string v2, "paradox_battery_preferences"

    const-string/jumbo v3, "xml"

    invoke-virtual {v0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v2, v3, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    invoke-virtual {p0, v0}, Lcom/android/settings/SettingsPreferenceFragment;->addPreferencesFromResource(I)V

    return-void
.end method

.method public onPause()V
    .locals 2

    invoke-super {p0}, Lcom/android/settings/SettingsPreferenceFragment;->onPause()V

    iget-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment;->mUpdateTask:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    return-void
.end method

.method public onResume()V
    .locals 4

    invoke-super {p0}, Lcom/android/settings/SettingsPreferenceFragment;->onResume()V

    new-instance v0, Ljava/lang/Thread;

    new-instance v1, Lcom/paradox/hub/ParadoxBatteryFragment$BatteryAsync;

    invoke-direct {v1, p0}, Lcom/paradox/hub/ParadoxBatteryFragment$BatteryAsync;-><init>(Lcom/paradox/hub/ParadoxBatteryFragment;)V

    invoke-direct {v0, v1}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    iget-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment;->mHandler:Landroid/os/Handler;

    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment;->mUpdateTask:Ljava/lang/Runnable;

    const-wide/16 v2, 0x3e8

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method
