.class public Lcom/paradox/hub/ParadoxMemoryFragment$UpdateTask;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxMemoryFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxMemoryFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxMemoryFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxMemoryFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 12

    iget-object v0, p0, Lcom/paradox/hub/ParadoxMemoryFragment$UpdateTask;->this$0:Lcom/paradox/hub/ParadoxMemoryFragment;

    invoke-virtual {v0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v1

    const-string v8, "MemTotal:"

    invoke-static {v8}, Lcom/paradox/hub/ParadoxMemoryFragment;->readMemInfoVal(Ljava/lang/String;)J

    move-result-wide v2

    const-string v8, "MemAvailable:"

    invoke-static {v8}, Lcom/paradox/hub/ParadoxMemoryFragment;->readMemInfoVal(Ljava/lang/String;)J

    move-result-wide v4

    move-wide v6, v2

    sub-long/2addr v6, v4

    invoke-static {v1, v6, v7, v2, v3}, Lcom/paradox/hub/ParadoxMemoryFragment;->formatRamPair(Landroid/content/Context;JJ)Ljava/lang/String;

    move-result-object v8

    const-string v9, "ram_monitor"

    invoke-virtual {v0, v9}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v9

    if-eqz v9, :cond_0

    invoke-virtual {v9, v8}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_0
    const-string v8, "SwapTotal:"

    invoke-static {v8}, Lcom/paradox/hub/ParadoxMemoryFragment;->readMemInfoVal(Ljava/lang/String;)J

    move-result-wide v2

    const-string v8, "SwapFree:"

    invoke-static {v8}, Lcom/paradox/hub/ParadoxMemoryFragment;->readMemInfoVal(Ljava/lang/String;)J

    move-result-wide v4

    move-wide v6, v2

    sub-long/2addr v6, v4

    invoke-static {v1, v6, v7, v2, v3}, Lcom/paradox/hub/ParadoxMemoryFragment;->formatRamPair(Landroid/content/Context;JJ)Ljava/lang/String;

    move-result-object v8

    const-string/jumbo v9, "zram_monitor"

    invoke-virtual {v0, v9}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v9

    if-eqz v9, :cond_1

    invoke-virtual {v9, v8}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_1
    const-string v8, "Cached:"

    invoke-static {v8}, Lcom/paradox/hub/ParadoxMemoryFragment;->readMemInfoVal(Ljava/lang/String;)J

    move-result-wide v2

    const-wide/16 v4, 0x400

    mul-long/2addr v2, v4

    invoke-static {v1, v2, v3}, Landroid/text/format/Formatter;->formatFileSize(Landroid/content/Context;J)Ljava/lang/String;

    move-result-object v8

    const-string v9, "paradox_cached_in_use"

    invoke-static {v1, v9}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    const-string v9, "cached_monitor"

    invoke-virtual {v0, v9}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v9

    if-eqz v9, :cond_2

    invoke-virtual {v9, v8}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_2
    const-string v8, "Active:"

    invoke-static {v8}, Lcom/paradox/hub/ParadoxMemoryFragment;->readMemInfoVal(Ljava/lang/String;)J

    move-result-wide v2

    const-wide/16 v4, 0x400

    mul-long/2addr v2, v4

    invoke-static {v1, v2, v3}, Landroid/text/format/Formatter;->formatFileSize(Landroid/content/Context;J)Ljava/lang/String;

    move-result-object v8

    const-string v9, "paradox_active_in_use"

    invoke-static {v1, v9}, Lcom/paradox/hub/ParadoxCenterFragment;->getParadoxString(Landroid/content/Context;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v9

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    const-string v9, "active_monitor"

    invoke-virtual {v0, v9}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v9

    if-eqz v9, :cond_3

    invoke-virtual {v9, v8}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    :cond_3
    iget-object v1, v0, Lcom/paradox/hub/ParadoxMemoryFragment;->mHandler:Landroid/os/Handler;

    iget-object v0, v0, Lcom/paradox/hub/ParadoxMemoryFragment;->mUpdateTask:Ljava/lang/Runnable;

    const-wide/16 v2, 0x3e8

    invoke-virtual {v1, v0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    return-void
.end method
