.class public Lcom/paradox/hub/UndervoltFragment;
.super Lcom/android/settings/SettingsPreferenceFragment;

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Lcom/android/settings/SettingsPreferenceFragment;-><init>()V
    return-void
.end method

.method public getMetricsCategory()I
    .locals 1
    const/4 v0, 0x0
    return v0
.end method

.method public onCreatePreferences(Landroid/os/Bundle;Ljava/lang/String;)V
    .locals 2
    const-string v0, "xml"
    const-string v1, "gm_undervolt_preferences"
    invoke-static {v0, v1}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I
    move-result v0
    invoke-virtual {p0, v0}, Lcom/android/settings/SettingsPreferenceFragment;->addPreferencesFromResource(I)V
    return-void
.end method
