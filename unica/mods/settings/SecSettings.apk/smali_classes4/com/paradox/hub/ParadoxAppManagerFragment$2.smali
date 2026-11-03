.class public Lcom/paradox/hub/ParadoxAppManagerFragment$2;
.super Ljava/lang/Object;

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field final synthetic this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

.field val$enabled:Z

.field val$icon:Landroid/graphics/drawable/Drawable;

.field val$pkg:Ljava/lang/String;

.field val$title:Ljava/lang/String;


# direct methods
.method public constructor <init>(Lcom/paradox/hub/ParadoxAppManagerFragment;Ljava/lang/String;Ljava/lang/String;ZLandroid/graphics/drawable/Drawable;)V
    .locals 0

    iput-object p1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    iput-object p2, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$title:Ljava/lang/String;

    iput-object p3, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$pkg:Ljava/lang/String;

    iput-boolean p4, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$enabled:Z

    iput-object p5, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$icon:Landroid/graphics/drawable/Drawable;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-virtual {v1}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v1

    if-nez v1, :cond_0

    return-void

    :cond_0
    new-instance v0, Landroidx/preference/SwitchPreferenceCompat;

    invoke-direct {v0, v1}, Landroidx/preference/SwitchPreferenceCompat;-><init>(Landroid/content/Context;)V

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$title:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setTitle(Ljava/lang/CharSequence;)V

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$pkg:Ljava/lang/String;

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setSummary(Ljava/lang/CharSequence;)V

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setKey(Ljava/lang/String;)V

    iget-boolean v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$enabled:Z

    invoke-virtual {v0, v1}, Landroidx/preference/TwoStatePreference;->setChecked(Z)V

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->val$icon:Landroid/graphics/drawable/Drawable;

    if-eqz v1, :cond_1

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setIcon(Landroid/graphics/drawable/Drawable;)V

    :cond_1
    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    invoke-virtual {v0, v1}, Landroidx/preference/Preference;->setOnPreferenceChangeListener(Landroidx/preference/Preference$OnPreferenceChangeListener;)V

    iget-object v1, p0, Lcom/paradox/hub/ParadoxAppManagerFragment$2;->this$0:Lcom/paradox/hub/ParadoxAppManagerFragment;

    const-string v2, "apps_category"

    invoke-virtual {v1, v2}, Landroidx/preference/PreferenceFragmentCompat;->findPreference(Ljava/lang/CharSequence;)Landroidx/preference/Preference;

    move-result-object v1

    if-eqz v1, :cond_2

    check-cast v1, Landroidx/preference/PreferenceGroup;

    invoke-virtual {v1, v0}, Landroidx/preference/PreferenceGroup;->addPreference(Landroidx/preference/Preference;)Z

    :cond_2
    return-void
.end method
