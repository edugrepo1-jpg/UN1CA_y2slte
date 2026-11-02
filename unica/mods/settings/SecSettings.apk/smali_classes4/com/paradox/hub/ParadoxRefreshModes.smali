.class public final Lcom/paradox/hub/ParadoxRefreshModes;
.super Ljava/lang/Object;

# Read modes from the active display instead of assuming every r8s panel
# supports 96 Hz. EA8079 can expose it; S6E3FC3 remains at 60/120 Hz.
.method public static configure(Landroidx/preference/ListPreference;Landroid/content/Context;)V
    .locals 9

    const/4 v0, 0x0
    invoke-virtual {p0, v0}, Landroidx/preference/Preference;->setPersistent(Z)V
    const-string v1, "display"
    invoke-virtual {p1, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;
    move-result-object v1
    check-cast v1, Landroid/hardware/display/DisplayManager;
    if-eqz v1, :unavailable
    invoke-virtual {v1, v0}, Landroid/hardware/display/DisplayManager;->getDisplay(I)Landroid/view/Display;
    move-result-object v1
    if-eqz v1, :unavailable
    invoke-virtual {v1}, Landroid/view/Display;->getMode()Landroid/view/Display$Mode;
    move-result-object v2
    invoke-virtual {v2}, Landroid/view/Display$Mode;->getPhysicalWidth()I
    move-result v3
    invoke-virtual {v2}, Landroid/view/Display$Mode;->getPhysicalHeight()I
    move-result v4
    invoke-virtual {v1}, Landroid/view/Display;->getSupportedModes()[Landroid/view/Display$Mode;
    move-result-object v1
    new-instance v2, Ljava/util/TreeSet;
    invoke-direct {v2}, Ljava/util/TreeSet;-><init>()V
    array-length v5, v1

    :modes
    if-ge v0, v5, :entries
    aget-object v6, v1, v0
    invoke-virtual {v6}, Landroid/view/Display$Mode;->getPhysicalWidth()I
    move-result v7
    if-ne v7, v3, :next
    invoke-virtual {v6}, Landroid/view/Display$Mode;->getPhysicalHeight()I
    move-result v7
    if-ne v7, v4, :next
    invoke-virtual {v6}, Landroid/view/Display$Mode;->getRefreshRate()F
    move-result v7
    invoke-static {v7}, Ljava/lang/Math;->round(F)I
    move-result v7
    if-lez v7, :next
    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;
    move-result-object v7
    invoke-virtual {v2, v7}, Ljava/util/TreeSet;->add(Ljava/lang/Object;)Z

    :next
    add-int/lit8 v0, v0, 0x1
    goto :modes

    :entries
    invoke-virtual {v2}, Ljava/util/TreeSet;->size()I
    move-result v0
    if-eqz v0, :unavailable
    new-array v1, v0, [Ljava/lang/CharSequence;
    invoke-virtual {v2}, Ljava/util/TreeSet;->iterator()Ljava/util/Iterator;
    move-result-object v2
    const/4 v3, 0x0

    :entry
    if-ge v3, v0, :ready
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;
    move-result-object v4
    invoke-virtual {v4}, Ljava/lang/Object;->toString()Ljava/lang/String;
    move-result-object v4
    aput-object v4, v1, v3
    add-int/lit8 v3, v3, 0x1
    goto :entry

    :ready
    invoke-virtual {p0, v1}, Landroidx/preference/ListPreference;->setEntries([Ljava/lang/CharSequence;)V
    iput-object v1, p0, Landroidx/preference/ListPreference;->mEntryValues:[Ljava/lang/CharSequence;
    const/4 v0, 0x1
    invoke-virtual {p0, v0}, Landroidx/preference/Preference;->setEnabled(Z)V
    return-void

    :unavailable
    const/4 v0, 0x0
    new-array v1, v0, [Ljava/lang/CharSequence;
    invoke-virtual {p0, v1}, Landroidx/preference/ListPreference;->setEntries([Ljava/lang/CharSequence;)V
    iput-object v1, p0, Landroidx/preference/ListPreference;->mEntryValues:[Ljava/lang/CharSequence;
    invoke-virtual {p0, v0}, Landroidx/preference/Preference;->setEnabled(Z)V
    return-void
.end method

# Reject values absent from the current panel and keep minimum <= maximum.
# Provider values are the authority; do not save a second SharedPreferences copy.
.method public static apply(Landroid/content/Context;Landroidx/preference/ListPreference;Landroidx/preference/ListPreference;Ljava/lang/String;)Z
    .locals 7

    invoke-virtual {p1, p3}, Landroidx/preference/ListPreference;->findIndexOfValue(Ljava/lang/String;)I
    move-result v0
    if-ltz v0, :reject
    :try_start
    invoke-static {p3}, Ljava/lang/Float;->parseFloat(Ljava/lang/String;)F
    move-result v0
    :try_end
    .catch Ljava/lang/NumberFormatException; {:try_start .. :try_end} :reject_exception
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;
    move-result-object v1
    invoke-virtual {p1}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;
    move-result-object v2
    const-string v3, "min_refresh_rate"
    const-string v4, "peak_refresh_rate"
    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v5
    if-eqz v5, :maximum
    invoke-static {v1, v4, v0}, Landroid/provider/Settings$System;->getFloat(Landroid/content/ContentResolver;Ljava/lang/String;F)F
    move-result v6
    cmpg-float v6, v0, v6
    if-lez v6, :write
    goto :adjust

    :maximum
    move-object v3, v4
    const-string v4, "min_refresh_rate"
    invoke-static {v1, v4, v0}, Landroid/provider/Settings$System;->getFloat(Landroid/content/ContentResolver;Ljava/lang/String;F)F
    move-result v6
    cmpl-float v6, v0, v6
    if-gez v6, :write

    :adjust
    invoke-static {v1, v4, v0}, Landroid/provider/Settings$System;->putFloat(Landroid/content/ContentResolver;Ljava/lang/String;F)Z
    move-result v6
    if-eqz v6, :reject
    if-eqz p2, :write
    invoke-virtual {p2, p3}, Landroidx/preference/ListPreference;->setValue(Ljava/lang/String;)V

    :write
    invoke-static {v1, v3, v0}, Landroid/provider/Settings$System;->putFloat(Landroid/content/ContentResolver;Ljava/lang/String;F)Z
    move-result v0
    return v0

    :reject_exception
    move-exception v0
    :reject
    const/4 v0, 0x0
    return v0
.end method
