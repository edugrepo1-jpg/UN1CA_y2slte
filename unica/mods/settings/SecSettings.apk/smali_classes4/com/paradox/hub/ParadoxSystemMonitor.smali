.class public Lcom/paradox/hub/ParadoxSystemMonitor;
.super Ljava/lang/Object;


# static fields
.field private static sLastTime:J

.field private static sScanCount:I


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    .locals 2

    invoke-static {p0, p2}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, " | "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    return-void
.end method

.method private static getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I
    .locals 1

    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    invoke-static {v0, p1, p2}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v0

    return v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    return p2
.end method

.method private static getGlobalLong(Landroid/content/Context;Ljava/lang/String;J)J
    .locals 2

    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    invoke-static {v0, p1}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-static {v0}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v0

    return-wide v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    :cond_0
    return-wide p2
.end method

.method private static getGlobalString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;
    .locals 1

    :try_start_0
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    invoke-static {v0, p1}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    const/4 v0, 0x0

    return-object v0
.end method

.method public static updateMonitorText(Landroid/content/Context;Landroidx/preference/Preference;)V
    .locals 10

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    sget-wide v2, Lcom/paradox/hub/ParadoxSystemMonitor;->sLastTime:J

    sub-long v2, v0, v2

    const-wide/16 v4, 0x7d0

    cmp-long v6, v2, v4

    if-lez v6, :cond_0

    const/4 v2, 0x0

    sput v2, Lcom/paradox/hub/ParadoxSystemMonitor;->sScanCount:I

    :cond_0
    sput-wide v0, Lcom/paradox/hub/ParadoxSystemMonitor;->sLastTime:J

    sget v0, Lcom/paradox/hub/ParadoxSystemMonitor;->sScanCount:I

    const/4 v1, 0x3

    if-ge v0, v1, :cond_2

    add-int/lit8 v0, v0, 0x1

    sput v0, Lcom/paradox/hub/ParadoxSystemMonitor;->sScanCount:I

    const-string v1, "paradox_sysmon_loading"

    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v0, :cond_1

    const-string v4, "."

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    :cond_1
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p1, v0}, Landroidx/preference/Preference;->setTitle(Ljava/lang/CharSequence;)V

    return-void

    :cond_2
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v9, -0x1

    :try_start_0
    const-string v0, "/sys/class/power_supply/battery/temp"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_temp"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    const/16 v1, 0x1c2

    if-lt v0, v1, :cond_3

    const-string v0, "paradox_sysmon_temp_critical"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V

    goto :goto_1

    :cond_3
    const/16 v1, 0x17c

    if-le v0, v1, :cond_4

    const-string v0, "paradox_sysmon_temp_high"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V

    goto :goto_1

    :cond_4
    const/16 v1, 0x78

    if-gt v0, v1, :cond_5

    const-string v0, "paradox_sysmon_temp_cold"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    :cond_5
    :goto_1
    :try_start_1
    const-string v0, "/sys/class/thermal/cooling_device2/cur_state"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_throttle"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    if-lez v0, :cond_6

    const-string v0, "paradox_sysmon_thermal_throttle"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    :catch_1
    :cond_6
    :try_start_2
    const-string v0, "/sys/class/power_supply/battery/capacity"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v9

    const-string v0, "paradox_sysmon_test_capacity"

    invoke-static {p0, v0, v9}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v9
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    :catch_2
    if-ltz v9, :cond_9

    const/16 v0, 0x19

    if-gt v9, v0, :cond_7

    const-string v0, "paradox_sysmon_bat_low"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_2

    :cond_7
    const/16 v0, 0x23

    if-le v9, v0, :cond_8

    goto :goto_2

    :cond_8
    const-string v0, "paradox_sysmon_bat_warn"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    :cond_9
    :goto_2
    :try_start_3
    const-string v0, "/sys/class/power_supply/battery/health"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    const-string v1, "paradox_sysmon_test_health"

    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_a

    move-object v0, v1

    :cond_a
    const-string v1, "Good"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_b

    const-string v1, "Unknown"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_b

    const-string v1, "--"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_b

    const-string v0, "paradox_sysmon_battery_health"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_3

    :catch_3
    :cond_b
    :try_start_4
    const-string v0, "/sys/class/power_supply/battery/battery_cycle"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_battery_cycle"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    const/16 v1, 0x1f4

    if-lt v0, v1, :cond_c

    const-string v0, "paradox_sysmon_battery_cycles_high"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_4

    :catch_4
    :cond_c
    :try_start_5
    const-string v0, "/sys/class/power_supply/battery/fg_asoc"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_battery_asoc"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    const/16 v1, 0x55

    if-gt v0, v1, :cond_d

    const-string v0, "paradox_sysmon_battery_wear"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_5

    :catch_5
    :cond_d
    :try_start_6
    const-string v0, "/sys/class/power_supply/battery/voltage_now"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_battery_voltage"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    const v1, 0x3567e0

    if-gt v0, v1, :cond_e

    const-string v0, "paradox_sysmon_battery_voltage_low"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_6

    :catch_6
    :cond_e
    :try_start_7
    const-string v0, "/sys/class/power_supply/battery/siop_level"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_siop"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    if-lez v0, :cond_f

    const/16 v1, 0x64

    if-ge v0, v1, :cond_f

    const-string v0, "paradox_sysmon_siop_limited"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_7

    :catch_7
    :cond_f
    :try_start_8
    const-string v0, "/sys/class/power_supply/battery/status"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    const-string v1, "paradox_sysmon_test_status"

    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_10

    move-object v0, v1

    :cond_10
    const-string v1, "Charging"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_12

    const/16 v0, 0x5a

    if-le v9, v0, :cond_11

    const-string v0, "paradox_sysmon_charging_protect"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_3

    :cond_11
    const-string v0, "paradox_sysmon_charging"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :try_end_8
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_8} :catch_8

    :catch_8
    :cond_12
    :goto_3
    :try_start_9
    const-string v0, "/sys/class/power_supply/battery/status"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    const-string v1, "paradox_sysmon_test_status"

    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_13

    move-object v0, v1

    :cond_13
    const-string v1, "Charging"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_14

    const-string v0, "/sys/class/power_supply/battery/time_to_full_now"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_time_to_full"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    const/16 v1, 0x1c20

    if-lt v0, v1, :cond_14

    const-string v0, "paradox_sysmon_slow_charging"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_9
    .catch Ljava/lang/Exception; {:try_start_9 .. :try_end_9} :catch_9

    :catch_9
    :cond_14
    :try_start_a
    const-string v0, "/sys/class/power_supply/wireless/online"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v0

    const-string v1, "paradox_sysmon_test_wireless_online"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    if-lez v0, :cond_15

    const-string v0, "paradox_sysmon_wireless_charging"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_a
    .catch Ljava/lang/Exception; {:try_start_a .. :try_end_a} :catch_a

    :catch_a
    :cond_15
    :try_start_b
    const-string v0, "activity"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/ActivityManager;

    if-eqz v0, :cond_16

    new-instance v1, Landroid/app/ActivityManager$MemoryInfo;

    invoke-direct {v1}, Landroid/app/ActivityManager$MemoryInfo;-><init>()V

    invoke-virtual {v0, v1}, Landroid/app/ActivityManager;->getMemoryInfo(Landroid/app/ActivityManager$MemoryInfo;)V

    iget-wide v0, v1, Landroid/app/ActivityManager$MemoryInfo;->availMem:J

    const-string v4, "paradox_sysmon_test_availmem"

    invoke-static {p0, v4, v0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalLong(Landroid/content/Context;Ljava/lang/String;J)J

    move-result-wide v0

    const-wide/32 v2, 0x66666666

    cmp-long v4, v0, v2

    if-gtz v4, :cond_16

    const-string v0, "paradox_sysmon_ram_low"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :try_end_b
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_b} :catch_b

    :catch_b
    :cond_16
    :try_start_c
    invoke-static {}, Landroid/os/Environment;->getDataDirectory()Ljava/io/File;

    move-result-object v0

    invoke-virtual {v0}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    new-instance v1, Landroid/os/StatFs;

    invoke-direct {v1, v0}, Landroid/os/StatFs;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Landroid/os/StatFs;->getAvailableBytes()J

    move-result-wide v0

    const-string v4, "paradox_sysmon_test_storage_avail"

    invoke-static {p0, v4, v0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalLong(Landroid/content/Context;Ljava/lang/String;J)J

    move-result-wide v0

    const-wide/32 v2, 0x40000000

    cmp-long v4, v0, v2

    if-gtz v4, :cond_17

    const-string v0, "paradox_sysmon_storage_critical"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V

    goto :goto_4

    :cond_17
    const-wide v2, 0xc0000000L

    cmp-long v4, v0, v2

    if-gtz v4, :cond_18

    const-string v0, "paradox_sysmon_storage_low"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :try_end_c
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_c} :catch_c

    :catch_c
    :cond_18
    :goto_4
    :try_start_d
    const-string v0, "power"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/os/PowerManager;

    if-eqz v0, :cond_1a

    invoke-virtual {v0}, Landroid/os/PowerManager;->isPowerSaveMode()Z

    move-result v0

    const-string v1, "low_power"

    const/4 v2, 0x0

    invoke-static {p0, v1, v2}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v1

    if-nez v1, :cond_19

    if-eqz v0, :cond_1a

    :cond_19
    const-string v0, "paradox_sysmon_power_saving"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_d
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_d} :catch_d

    :catch_d
    :cond_1a
    :try_start_e
    const-string v0, "connectivity"

    invoke-virtual {p0, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/net/ConnectivityManager;

    if-eqz v0, :cond_1b

    invoke-virtual {v0}, Landroid/net/ConnectivityManager;->getRestrictBackgroundStatus()I

    move-result v0

    const-string v1, "paradox_sysmon_test_restrict_background"

    invoke-static {p0, v1, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    const/4 v1, 0x3

    if-ne v0, v1, :cond_1b

    const-string v0, "paradox_sysmon_data_saver"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_e
    .catch Ljava/lang/Exception; {:try_start_e .. :try_end_e} :catch_e

    :catch_e
    :cond_1b
    :try_start_f
    const-string v0, "airplane_mode_on"

    const/4 v1, 0x0

    invoke-static {p0, v0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalInt(Landroid/content/Context;Ljava/lang/String;I)I

    move-result v0

    if-eqz v0, :cond_1c

    const-string v0, "paradox_sysmon_airplane_mode"

    invoke-static {p0, v8, v0}, Lcom/paradox/hub/ParadoxSystemMonitor;->appendMonitorString(Landroid/content/Context;Ljava/lang/StringBuilder;Ljava/lang/String;)V
    :try_end_f
    .catch Ljava/lang/Exception; {:try_start_f .. :try_end_f} :catch_f

    :catch_f
    :cond_1c
    :try_start_10
    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v0

    const-string v4, "paradox_sysmon_test_uptime_ms"

    invoke-static {p0, v4, v0, v1}, Lcom/paradox/hub/ParadoxSystemMonitor;->getGlobalLong(Landroid/content/Context;Ljava/lang/String;J)J

    move-result-wide v0

    const-wide/32 v2, 0xf731400

    cmp-long v4, v0, v2

    if-ltz v4, :cond_1d

    const-string v0, "paradox_sysmon_uptime_high"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, " | "

    invoke-virtual {v8, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    :try_end_10
    .catch Ljava/lang/Exception; {:try_start_10 .. :try_end_10} :catch_10

    :catch_10
    :cond_1d
    invoke-virtual {v8}, Ljava/lang/StringBuilder;->length()I

    move-result v0

    if-lez v0, :cond_1f

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x0

    const-string v3, " | "

    invoke-virtual {v1, v3}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v4

    if-ltz v4, :cond_1e

    add-int/lit8 v5, v4, 0x3

    invoke-virtual {v1, v3, v5}, Ljava/lang/String;->indexOf(Ljava/lang/String;I)I

    move-result v4

    if-ltz v4, :cond_1e

    invoke-virtual {v1, v2, v4}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    goto :goto_5

    :cond_1e
    add-int/lit8 v0, v0, -0x3

    invoke-virtual {v1, v2, v0}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v0

    const-string v1, "paradox_sysmon_charging"

    invoke-static {p0, v1}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_21

    const-string v2, "paradox_sysmon_default"

    invoke-static {p0, v2}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, " | "

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    goto :goto_5

    :cond_1f
    :try_start_11
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    const-string v1, "paradox_core_mode"

    invoke-static {v0, v1}, Landroid/provider/Settings$Global;->getString(Landroid/content/ContentResolver;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_20

    const-string/jumbo v1, "stock"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_20

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCoreModesFragment;->getModeLabel(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "paradox_core_banner_mode"

    invoke-static {p0, v2}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    const/4 v3, 0x1

    new-array v3, v3, [Ljava/lang/Object;

    const/4 v4, 0x0

    aput-object v1, v3, v4

    invoke-static {v2, v3}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    goto :goto_5
    :try_end_11
    .catch Ljava/lang/Exception; {:try_start_11 .. :try_end_11} :catch_11

    :catch_11
    :cond_20
    const-string v0, "paradox_sysmon_default"

    invoke-static {p0, v0}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    :cond_21
    :goto_5
    const-string v1, "ParadoxMonitor"

    invoke-static {v1, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    invoke-virtual {p1, v0}, Landroidx/preference/Preference;->setTitle(Ljava/lang/CharSequence;)V

    return-void
.end method
