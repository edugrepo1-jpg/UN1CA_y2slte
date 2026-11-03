.class public Lcom/paradox/hub/ParadoxCenterFragment$UpdateTask;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxCenterFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxCenterFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxCenterFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxCenterFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 8

    iget-object v0, p0, Lcom/paradox/hub/ParadoxCenterFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxCenterFragment;

    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->isAdded()Z

    move-result v1

    if-nez v1, :cond_0

    return-void

    :cond_0
    const-string v1, "cpu_temp"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_1

    const-string v2, "/sys/class/thermal/thermal_zone0/temp"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->formatTemp(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_1
    const-string v1, "bat_temp"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_2

    const-string v2, "/sys/class/thermal/thermal_zone8/temp"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->formatTemp(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_2
    const-string v1, "ram_usage"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_3

    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->getRamString(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_3
    const-string v1, "bat_capacity"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_4

    const-string v2, "/sys/class/power_supply/battery/fg_fullcapnom"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->formatMah(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_4
    const-string v1, "bat_cycles"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_5

    const-string v2, "/sys/class/power_supply/battery/battery_cycle"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_5
    const-string v1, "bat_health"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_6

    const-string v2, "/sys/class/power_supply/battery/fg_asoc"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->formatPercentage(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_6
    const-string v1, "gpu_overclock"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_7

    const-string v2, "/sys/kernel/gpu/gpu_unlock"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    const-string v3, "1"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    move-object v3, v1

    check-cast v3, Landroidx/preference/TwoStatePreference;

    invoke-virtual {v3, v2}, Landroidx/preference/TwoStatePreference;->setChecked(Z)V

    :cond_7
    iget-object v0, p0, Lcom/paradox/hub/ParadoxCenterFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxCenterFragment;

    const-string v1, "paradox_header_banner"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_8

    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    if-eqz v0, :cond_8

    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->updateMonitorText(Landroid/content/Context;Landroidx/preference/Preference;)V

    :cond_8
    iget-object v0, p0, Lcom/paradox/hub/ParadoxCenterFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxCenterFragment;

    iget-object v0, v0, Lcom/paradox/hub/ParadoxCenterFragment;->mHandler:Landroid/os/Handler;

    const-wide/16 v1, 0x3e8

    invoke-virtual {v0, p0, v1, v2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method
