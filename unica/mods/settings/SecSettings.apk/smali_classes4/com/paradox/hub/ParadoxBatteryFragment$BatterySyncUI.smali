.class public Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

.field val$cap:Ljava/lang/String;

.field val$cyc:Ljava/lang/String;

.field val$hlth:Ljava/lang/String;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxBatteryFragment;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    iput-object p2, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->val$cap:Ljava/lang/String;

    iput-object p3, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->val$cyc:Ljava/lang/String;

    iput-object p4, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->val$hlth:Ljava/lang/String;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    iget-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    const-string v1, "bat_capacity"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    if-eqz v0, :cond_0

    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->val$cap:Ljava/lang/String;

    invoke-static {v1}, Lcom/paradox/hub/ParadoxCenterFragment;->formatMah(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_0
    iget-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    const-string v1, "bat_cycles"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    if-eqz v0, :cond_1

    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->val$cyc:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_1
    iget-object v0, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    const-string v1, "bat_health"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    if-eqz v0, :cond_2

    iget-object v1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;->val$hlth:Ljava/lang/String;

    invoke-static {v1}, Lcom/paradox/hub/ParadoxCenterFragment;->formatPercentage(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_2
    return-void
.end method
