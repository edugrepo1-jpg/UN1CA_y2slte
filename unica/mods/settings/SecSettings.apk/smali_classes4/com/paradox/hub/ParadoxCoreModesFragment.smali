.class public Lcom/paradox/hub/ParadoxCoreModesFragment;
.super Lcom/android/settings/SettingsPreferenceFragment;

# interfaces
.implements Landroidx/preference/Preference$OnPreferenceChangeListener;


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lcom/android/settings/SettingsPreferenceFragment;-><init>()V

    return-void
.end method

.method private static applyCoreMode(Landroid/content/Context;Ljava/lang/String;)V
    .locals 4

    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v1, "paradox_core_mode"

    invoke-static {v0, v1, p1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "gaming"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const-string v1, "battery"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    goto/16 :goto_1

    :cond_1
    const-string/jumbo v1, "refresh_rate_mode"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "min_refresh_rate"

    const-string v2, "60.0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "peak_refresh_rate"

    const-string v2, "120.0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "touch_sensitivity_enabled"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "low_power"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "enhanced_processing"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "sem_enhanced_cpu_responsiveness"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "wifi_scan_throttling"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "cached_apps_freezer"

    const-string v2, "enabled"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "window_animation_scale"

    const-string v2, "0.85"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "transition_animation_scale"

    const-string v2, "0.85"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "animator_duration_scale"

    const-string v2, "0.85"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :goto_0
    const-string/jumbo v1, "refresh_rate_mode"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "min_refresh_rate"

    const-string v2, "120.0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "peak_refresh_rate"

    const-string v2, "120.0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "touch_sensitivity_enabled"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "low_power"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "enhanced_processing"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "sem_enhanced_cpu_responsiveness"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "wifi_scan_throttling"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "cached_apps_freezer"

    const-string v2, "enabled"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "window_animation_scale"

    const-string v2, "0.75"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "transition_animation_scale"

    const-string v2, "0.75"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "animator_duration_scale"

    const-string v2, "0.75"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :goto_1
    const-string/jumbo v1, "refresh_rate_mode"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "min_refresh_rate"

    const-string v2, "60.0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "peak_refresh_rate"

    const-string v2, "60.0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "touch_sensitivity_enabled"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "low_power"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "screen_off_timeout"

    const-string v2, "30000"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "aod_mode"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "enhanced_processing"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "sem_enhanced_cpu_responsiveness"

    const-string v2, "0"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "wifi_scan_throttling"

    const-string v2, "1"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "cached_apps_freezer"

    const-string v2, "enabled"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method private static backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    invoke-static {p0, p1}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    const-string v0, "__paradox_null__"

    :goto_0
    invoke-static {p0, p2, v0}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    return-void
.end method

.method private static backupIfNeeded(Landroid/content/Context;)V
    .locals 4

    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v1, "paradox_core_backup_done"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v1

    if-eqz v1, :cond_0

    return-void

    :cond_0
    const-string v1, "min_refresh_rate"

    const-string v2, "paradox_core_backup_system_min_refresh_rate"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "peak_refresh_rate"

    const-string v2, "paradox_core_backup_system_peak_refresh_rate"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "screen_off_timeout"

    const-string v2, "paradox_core_backup_system_screen_off_timeout"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "touch_sensitivity_enabled"

    const-string v2, "paradox_core_backup_system_touch_sensitivity_enabled"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "aod_mode"

    const-string v2, "paradox_core_backup_system_aod_mode"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "low_power"

    const-string v2, "paradox_core_backup_global_low_power"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "wifi_scan_throttling"

    const-string v2, "paradox_core_backup_global_wifi_scan_throttling"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "cached_apps_freezer"

    const-string v2, "paradox_core_backup_global_cached_apps_freezer"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "enhanced_processing"

    const-string v2, "paradox_core_backup_global_enhanced_processing"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "sem_enhanced_cpu_responsiveness"

    const-string v2, "paradox_core_backup_global_sem_enhanced_cpu_responsiveness"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "window_animation_scale"

    const-string v2, "paradox_core_backup_global_window_animation_scale"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "transition_animation_scale"

    const-string v2, "paradox_core_backup_global_transition_animation_scale"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "animator_duration_scale"

    const-string v2, "paradox_core_backup_global_animator_duration_scale"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "refresh_rate_mode"

    const-string v2, "paradox_core_backup_secure_refresh_rate_mode"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "paradox_core_backup_done"

    const/4 v2, 0x1

    invoke-static {v0, v1, v2}, Landroid/provider/Settings$Global;->putInt(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

    return-void
.end method

.method private static backupSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    invoke-static {p0, p1}, Landroid/provider/Settings$Secure;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    const-string v0, "__paradox_null__"

    :goto_0
    invoke-static {p0, p2, v0}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    return-void
.end method

.method private static backupSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    invoke-static {p0, p1}, Landroid/provider/Settings$System;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    const-string v0, "__paradox_null__"

    :goto_0
    invoke-static {p0, p2, v0}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    return-void
.end method

.method public static getModeDesc(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    const-string v0, "gaming"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v1, "paradox_core_mode_gaming_desc"

    goto :goto_0

    :cond_0
    const-string v0, "battery"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v1, "paradox_core_mode_battery_desc"

    goto :goto_0

    :cond_1
    const-string/jumbo v0, "stock"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v1, "paradox_core_mode_stock_desc"

    goto :goto_0

    :cond_2
    const-string v1, "paradox_core_mode_smooth_desc"

    :goto_0
    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public static getModeLabel(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;
    .locals 2

    const-string v0, "gaming"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v1, "paradox_core_mode_gaming"

    goto :goto_0

    :cond_0
    const-string v0, "battery"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v1, "paradox_core_mode_battery"

    goto :goto_0

    :cond_1
    const-string/jumbo v0, "stock"

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    const-string v1, "paradox_core_mode_stock"

    goto :goto_0

    :cond_2
    const-string v1, "paradox_core_mode_smooth"

    :goto_0
    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private static putGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    return-void
.end method

.method private static putSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Landroid/provider/Settings$Secure;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    return-void
.end method

.method private static putSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-static {p0, p1, p2}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    return-void
.end method

.method private static restoreBackup(Landroid/content/Context;)Z
    .locals 4

    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v1, "paradox_core_backup_done"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "min_refresh_rate"

    const-string v2, "paradox_core_backup_system_min_refresh_rate"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "peak_refresh_rate"

    const-string v2, "paradox_core_backup_system_peak_refresh_rate"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "screen_off_timeout"

    const-string v2, "paradox_core_backup_system_screen_off_timeout"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "touch_sensitivity_enabled"

    const-string v2, "paradox_core_backup_system_touch_sensitivity_enabled"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "aod_mode"

    const-string v2, "paradox_core_backup_system_aod_mode"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "low_power"

    const-string v2, "paradox_core_backup_global_low_power"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "wifi_scan_throttling"

    const-string v2, "paradox_core_backup_global_wifi_scan_throttling"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "cached_apps_freezer"

    const-string v2, "paradox_core_backup_global_cached_apps_freezer"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "enhanced_processing"

    const-string v2, "paradox_core_backup_global_enhanced_processing"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "sem_enhanced_cpu_responsiveness"

    const-string v2, "paradox_core_backup_global_sem_enhanced_cpu_responsiveness"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "window_animation_scale"

    const-string v2, "paradox_core_backup_global_window_animation_scale"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "transition_animation_scale"

    const-string v2, "paradox_core_backup_global_transition_animation_scale"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "animator_duration_scale"

    const-string v2, "paradox_core_backup_global_animator_duration_scale"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string/jumbo v1, "refresh_rate_mode"

    const-string v2, "paradox_core_backup_secure_refresh_rate_mode"

    invoke-static {v0, v1, v2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "paradox_core_mode"

    const-string/jumbo v2, "stock"

    invoke-static {v0, v1, v2}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    const-string v1, "paradox_core_backup_done"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Landroid/provider/Settings$Global;->putInt(Landroid/content/ContentResolver;Ljava/lang/String;I)Z

    const/4 v0, 0x1

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method private static restoreGlobal(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 2

    invoke-static {p0, p2}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_1

    const-string v1, "__paradox_null__"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v0, 0x0

    :cond_0
    invoke-static {p0, p1, v0}, Landroid/provider/Settings$Global;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    :cond_1
    return-void
.end method

.method private static restoreSecure(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 2

    invoke-static {p0, p2}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_1

    const-string v1, "__paradox_null__"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v0, 0x0

    :cond_0
    invoke-static {p0, p1, v0}, Landroid/provider/Settings$Secure;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    :cond_1
    return-void
.end method

.method private static restoreSystem(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)V
    .locals 2

    invoke-static {p0, p2}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_1

    const-string v1, "__paradox_null__"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v0, 0x0

    :cond_0
    invoke-static {p0, p1, v0}, Landroid/provider/Settings$System;->putString(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;)Z

    :cond_1
    return-void
.end method

.method private static showModeToast(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V
    .locals 5

    invoke-static {p0, p1}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x1

    new-array v1, v1, [Ljava/lang/Object;

    const/4 v2, 0x0

    aput-object p2, v1, v2

    invoke-static {v0, v1}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-static {p0, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

    return-void
.end method

.method private static showToast(Landroid/content/Context;Ljava/lang/String;)V
    .locals 2

    invoke-static {p0, p1}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v0

    invoke-virtual {v0}, Landroid/widget/Toast;->show()V

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

    const-string v2, "paradox_core_modes"

    const-string/jumbo v3, "xml"

    invoke-virtual {v0}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v2, v3, v0}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    invoke-virtual {p0, v0}, Lcom/android/settings/SettingsPreferenceFragment;->addPreferencesFromResource(I)V

    const-string v0, "paradox_core_mode"

    invoke-virtual {p0, v0}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-virtual {v0, p0}, Landroidx/preference/Preference;->setOnPreferenceChangeListener(Landroidx/preference/Preference$OnPreferenceChangeListener;)V

    :cond_0
    invoke-virtual {p0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->refreshState()V

    return-void
.end method

.method public onPreferenceChange(Landroidx/preference/Preference;Ljava/lang/Object;)Z
    .locals 6

    invoke-virtual {p1}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;

    move-result-object v0

    const-string v1, "paradox_core_mode"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_2

    check-cast p2, Ljava/lang/String;

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    const-string/jumbo v1, "stock"

    invoke-virtual {v1, p2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreBackup(Landroid/content/Context;)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "paradox_core_restored"

    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->showToast(Landroid/content/Context;Ljava/lang/String;)V

    goto :goto_0

    :cond_0
    const-string v1, "paradox_core_no_backup"

    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->showToast(Landroid/content/Context;Ljava/lang/String;)V

    goto :goto_0

    :cond_1
    invoke-static {v0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->backupIfNeeded(Landroid/content/Context;)V

    invoke-static {v0, p2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->applyCoreMode(Landroid/content/Context;Ljava/lang/String;)V

    invoke-static {v0, p2}, Lcom/paradox/hub/ParadoxCoreModesFragment;->getModeLabel(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "paradox_core_applied"

    invoke-static {v0, v2, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->showModeToast(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V

    :goto_0
    invoke-virtual {p0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->refreshState()V

    :cond_2
    const/4 v0, 0x1

    return v0
.end method

.method public onPreferenceTreeClick(Landroidx/preference/Preference;)Z
    .locals 3

    invoke-virtual {p1}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;

    move-result-object v0

    const-string v1, "paradox_core_restore"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->restoreBackup(Landroid/content/Context;)Z

    move-result v1

    if-eqz v1, :cond_0

    const-string v1, "paradox_core_restored"

    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->showToast(Landroid/content/Context;Ljava/lang/String;)V

    goto :goto_0

    :cond_0
    const-string v1, "paradox_core_no_backup"

    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->showToast(Landroid/content/Context;Ljava/lang/String;)V

    :goto_0
    invoke-virtual {p0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->refreshState()V

    const/4 v0, 0x1

    return v0

    :cond_1
    invoke-super {p0, p1}, Lcom/android/settings/SettingsPreferenceFragment;->onPreferenceTreeClick(Landroidx/preference/Preference;)Z

    move-result p1

    return p1
.end method

.method public onResume()V
    .locals 0

    invoke-super {p0}, Lcom/android/settings/SettingsPreferenceFragment;->onResume()V

    invoke-virtual {p0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->refreshState()V

    return-void
.end method

.method public refreshState()V
    .locals 8

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v0

    if-eqz v0, :cond_2

    invoke-virtual {v0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string v2, "paradox_core_mode"

    invoke-static {v1, v2}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const-string/jumbo v1, "stock"

    :goto_0
    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->getModeLabel(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v1}, Lcom/paradox/hub/ParadoxCoreModesFragment;->getModeDesc(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "paradox_core_mode"

    invoke-virtual {p0, v4}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v4

    if-eqz v4, :cond_1

    check-cast v4, Landroidx/preference/ListPreference;

    invoke-virtual {v4, v1}, Landroidx/preference/ListPreference;->setValue(Ljava/lang/String;)V

    const-string v5, "paradox_core_mode_summary"

    invoke-static {v0, v5}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    const/4 v6, 0x1

    new-array v6, v6, [Ljava/lang/Object;

    const/4 v7, 0x0

    aput-object v2, v6, v7

    invoke-static {v5, v6}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Landroidx/preference/ListPreference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_1
    const-string v4, "paradox_core_mode_desc"

    invoke-virtual {p0, v4}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v4

    if-eqz v4, :cond_2

    invoke-virtual {v4, v2}, Landroidx/preference/Preference;->setTitle(Ljava/lang/CharSequence;)V

    invoke-virtual {v4, v3}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_2
    return-void
.end method
