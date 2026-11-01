.class public Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxThermalFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxThermalFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxThermalFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    const-string v0, "/sys/class/thermal/thermal_zone2/temp"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->formatTemp(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iget-object v1, p0, Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxThermalFragment;

    const-string/jumbo v2, "therm_a55"

    invoke-virtual {v1, v2}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_0

    invoke-virtual {v1, v0}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_0
    const-string v0, "/sys/class/thermal/thermal_zone1/temp"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->formatTemp(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iget-object v1, p0, Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxThermalFragment;

    const-string/jumbo v2, "therm_a78"

    invoke-virtual {v1, v2}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_1

    invoke-virtual {v1, v0}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_1
    const-string v0, "/sys/class/thermal/thermal_zone0/temp"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->formatTemp(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iget-object v1, p0, Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxThermalFragment;

    const-string/jumbo v2, "therm_x1"

    invoke-virtual {v1, v2}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_2

    invoke-virtual {v1, v0}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_2
    const-string v0, "/sys/class/thermal/thermal_zone3/temp"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->formatTemp(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iget-object v1, p0, Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxThermalFragment;

    const-string/jumbo v2, "therm_gpu"

    invoke-virtual {v1, v2}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_3

    invoke-virtual {v1, v0}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_3
    iget-object v1, p0, Lcom/paradox/hub/ParadoxThermalFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxThermalFragment;

    iget-object v2, v1, Lcom/paradox/hub/ParadoxThermalFragment;->mHandler:Landroid/os/Handler;

    iget-object v1, v1, Lcom/paradox/hub/ParadoxThermalFragment;->mUpdateTask:Ljava/lang/Runnable;

    const-wide/16 v3, 0x3e8

    invoke-virtual {v2, v1, v3, p0}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method
