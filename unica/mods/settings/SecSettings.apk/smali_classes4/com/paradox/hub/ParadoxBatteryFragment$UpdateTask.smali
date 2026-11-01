.class public Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxBatteryFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxBatteryFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    const-string v0, "/sys/class/power_supply/battery/current_now"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const/4 v2, 0x0

    :try_start_0
    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v1

    if-ltz v1, :cond_0

    const-string v3, "paradox_bat_charging"

    goto :goto_0

    :cond_0
    const-string v3, "paradox_bat_discharging"

    :goto_0
    iget-object v2, p0, Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    invoke-virtual {v2}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-static {v2, v3}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v4, " mA"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    const-string v3, "bat_current"

    invoke-virtual {v1, v3}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_2

    if-eqz v2, :cond_1

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setTitle(Ljava/lang/CharSequence;)V

    :cond_1
    invoke-virtual {v1, v0}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_2
    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    iget-object v2, v1, Lcom/paradox/hub/ParadoxBatteryFragment;->mHandler:Landroid/os/Handler;

    iget-object v1, v1, Lcom/paradox/hub/ParadoxBatteryFragment;->mUpdateTask:Ljava/lang/Runnable;

    const-wide/16 v3, 0x3e8

    invoke-virtual {v2, v1, v3, v4}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method
