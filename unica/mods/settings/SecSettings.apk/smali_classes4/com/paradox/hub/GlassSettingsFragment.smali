.class public Lcom/paradox/hub/GlassSettingsFragment;
.super Lcom/android/settings/SettingsPreferenceFragment;
.implements Landroidx/preference/Preference$OnPreferenceChangeListener;

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
    const-string v1, "gm_glass_preferences"
    invoke-static {v0, v1}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I
    move-result v0
    invoke-virtual {p0, v0}, Lcom/android/settings/SettingsPreferenceFragment;->addPreferencesFromResource(I)V
    const-string v0, "gmhub_liquid_glass_engine"
    invoke-virtual {p0, v0}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;
    move-result-object v0
    const/4 v1, 0x0
    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setPersistent(Z)V
    invoke-virtual {v0, p0}, Landroidx/preference/Preference;->setOnPreferenceChangeListener(Landroidx/preference/Preference$OnPreferenceChangeListener;)V
    return-void
.end method

.method public onPreferenceChange(Landroidx/preference/Preference;Ljava/lang/Object;)Z
    .locals 4
    const/4 v0, 0x0
    instance-of v1, p2, Ljava/lang/String;
    if-eqz v1, :done
    instance-of v1, p1, Landroidx/preference/ListPreference;
    if-eqz v1, :done
    check-cast p2, Ljava/lang/String;
    check-cast p1, Landroidx/preference/ListPreference;
    invoke-virtual {p1, p2}, Landroidx/preference/ListPreference;->findIndexOfValue(Ljava/lang/String;)I
    move-result v1
    if-ltz v1, :done
    const/4 v2, 0x3
    if-gt v1, v2, :done
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;
    move-result-object v2
    if-eqz v2, :done
    :try_start_save
    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    const-string v3, "gmhub_liquid_glass_engine"
    invoke-static {v2, v3, v1}, Landroid/provider/Settings$Global;->putInt(Landroid/content/ContentResolver;Ljava/lang/String;I)Z
    move-result v0
    :try_end_save
    .catch Ljava/lang/RuntimeException; {:try_start_save .. :try_end_save} :save_failed
    if-eqz v0, :notify_failed
    return v0
    :save_failed
    move-exception v1
    :notify_failed
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;
    move-result-object v1
    if-eqz v1, :done
    const-string v2, "string"
    const-string v3, "gm_glass_save_error"
    invoke-static {v2, v3}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I
    move-result v2
    invoke-static {v1, v2, v0}, Landroid/widget/Toast;->makeText(Landroid/content/Context;II)Landroid/widget/Toast;
    move-result-object v1
    invoke-virtual {v1}, Landroid/widget/Toast;->show()V
    :done
    return v0
.end method

.method public onResume()V
    .locals 5
    invoke-super {p0}, Lcom/android/settings/SettingsPreferenceFragment;->onResume()V
    const-string v0, "gmhub_liquid_glass_engine"
    invoke-virtual {p0, v0}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;
    move-result-object v1
    check-cast v1, Landroidx/preference/ListPreference;
    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;
    move-result-object v2
    if-eqz v2, :done
    const/4 v3, 0x0
    :try_start_read
    invoke-virtual {v2}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v2
    invoke-static {v2, v0, v3}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I
    move-result v3
    :try_end_read
    .catch Ljava/lang/RuntimeException; {:try_start_read .. :try_end_read} :read_failed
    goto :value
    :read_failed
    move-exception v2
    :value
    if-ltz v3, :reset
    const/4 v4, 0x3
    if-le v3, v4, :set_value
    :reset
    const/4 v3, 0x0
    :set_value
    invoke-static {v3}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v1, v0}, Landroidx/preference/ListPreference;->setValue(Ljava/lang/String;)V
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I
    const/16 v2, 0x21
    const/4 v3, 0x0
    if-lt v0, v2, :enabled
    const-string v0, "ro.gmhub.glass.renderers"
    invoke-static {v0, v3}, Landroid/os/SystemProperties;->getInt(Ljava/lang/String;I)I
    move-result v0
    const/4 v2, 0x3
    if-ne v0, v2, :enabled
    const/4 v3, 0x1
    :enabled
    invoke-virtual {v1, v3}, Landroidx/preference/Preference;->setEnabled(Z)V
    if-nez v3, :done
    const-string v0, "string"
    const-string v2, "gm_glass_unsupported"
    invoke-static {v0, v2}, Lio/mesalabs/unica/utils/Utils;->getResourceId(Ljava/lang/String;Ljava/lang/String;)I
    move-result v0
    invoke-virtual {v1, v0}, Landroidx/preference/Preference;->setSummary(I)V
    :done
    return-void
.end method
