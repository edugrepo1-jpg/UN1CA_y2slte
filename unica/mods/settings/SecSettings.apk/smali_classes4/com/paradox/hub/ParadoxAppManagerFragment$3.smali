.class public Lcom/paradox/hub/ParadoxAppManagerFragment$3;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxAppManagerFragment;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$3;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 2

    iget-object v0, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$3;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    const-string v1, "apps_category"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v0

    if-eqz v0, :cond_0

    check-cast v0, Landroidx/preference/PreferenceGroup;

    const-string v1, "loading_pref"

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceGroup;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_0

    invoke-virtual {v0, v1}, Landroidx/preference/PreferenceGroup;->removePreference(Landroidx/preference/Preference;)Z

    :cond_0
    return-void
.end method
