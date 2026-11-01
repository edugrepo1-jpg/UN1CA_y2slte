.class public Lcom/paradox/hub/ParadoxBatteryFragment$BatteryAsync;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxBatteryFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxBatteryFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatteryAsync;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 5

    const-string v0, "/sys/class/power_supply/battery/fg_fullcapnom"

    invoke-static {v0}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "/sys/class/power_supply/battery/battery_cycle"

    invoke-static {v1}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "/sys/class/power_supply/battery/fg_asoc"

    invoke-static {v2}, Lcom/paradox/hub/ParadoxCenterFragment;->readSysfs(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    new-instance v3, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;

    iget-object v4, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatteryAsync;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    invoke-direct {v3, v4, v0, v1, v2}, Lcom/paradox/hub/ParadoxBatteryFragment$BatterySyncUI;-><init>(Lcom/paradox/hub/ParadoxBatteryFragment;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    iget-object v4, p0, Lcom/paradox/hub/ParadoxBatteryFragment$BatteryAsync;->this$0:Lcom/paradox/hub/ParadoxBatteryFragment;

    iget-object v4, v4, Lcom/paradox/hub/ParadoxBatteryFragment;->mHandler:Landroid/os/Handler;

    invoke-virtual {v4, v3}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method
