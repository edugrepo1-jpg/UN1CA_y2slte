.class public final Lcom/gmhub/uv/UndervoltPanel;
.super Landroid/widget/LinearLayout;
.source "UndervoltPanel.java"


# instance fields
.field private busy:Z

.field private final controls:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Landroid/widget/Button;",
            ">;"
        }
    .end annotation
.end field

.field private dialog:Landroid/app/AlertDialog;

.field private generation:I

.field private lastResult:Ljava/lang/String;

.field private final main:Landroid/os/Handler;

.field private final refresh:Landroid/widget/Button;

.field private final rows:Landroid/widget/LinearLayout;

.field private final status:Landroid/widget/TextView;

.field private worker:Ljava/util/concurrent/ExecutorService;


# direct methods
.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 2

    .line 32
    invoke-direct {p0, p1, p2}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    .line 20
    new-instance p2, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v0

    invoke-direct {p2, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object p2, p0, Lcom/gmhub/uv/UndervoltPanel;->main:Landroid/os/Handler;

    .line 24
    new-instance p2, Ljava/util/ArrayList;

    invoke-direct {p2}, Ljava/util/ArrayList;-><init>()V

    iput-object p2, p0, Lcom/gmhub/uv/UndervoltPanel;->controls:Ljava/util/List;

    const/4 p2, 0x1

    .line 33
    invoke-virtual {p0, p2}, Lcom/gmhub/uv/UndervoltPanel;->setOrientation(I)V

    const/16 v0, 0x10

    .line 34
    invoke-direct {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->dp(I)I

    move-result v0

    invoke-virtual {p0, v0, v0, v0, v0}, Lcom/gmhub/uv/UndervoltPanel;->setPadding(IIII)V

    .line 35
    const-string v0, "Undervolt"

    const/16 v1, 0x16

    invoke-direct {p0, v0, v1}, Lcom/gmhub/uv/UndervoltPanel;->text(Ljava/lang/String;I)Landroid/widget/TextView;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->addView(Landroid/view/View;)V

    .line 36
    const-string v0, "Redu\u00e7\u00e3o percentual da tens\u00e3o solicitada ao firmware. N\u00e3o altera frequ\u00eancia nem governador. Os valores s\u00e3o individuais e voltam ao padr\u00e3o ap\u00f3s reiniciar."

    const/16 v1, 0xf

    invoke-direct {p0, v0, v1}, Lcom/gmhub/uv/UndervoltPanel;->text(Ljava/lang/String;I)Landroid/widget/TextView;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->addView(Landroid/view/View;)V

    .line 38
    const-string v0, "Aguardando leitura do GMKernel\u2026"

    invoke-direct {p0, v0, v1}, Lcom/gmhub/uv/UndervoltPanel;->text(Ljava/lang/String;I)Landroid/widget/TextView;

    move-result-object v0

    iput-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->status:Landroid/widget/TextView;

    invoke-virtual {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->addView(Landroid/view/View;)V

    .line 39
    new-instance v0, Landroid/widget/Button;

    invoke-direct {v0, p1}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->refresh:Landroid/widget/Button;

    const-string v1, "Atualizar valores"

    invoke-virtual {v0, v1}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V

    .line 40
    new-instance v1, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda1;

    invoke-direct {v1, p0}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda1;-><init>(Lcom/gmhub/uv/UndervoltPanel;)V

    invoke-virtual {v0, v1}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    invoke-virtual {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->addView(Landroid/view/View;)V

    .line 41
    new-instance v0, Landroid/widget/LinearLayout;

    invoke-direct {v0, p1}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->rows:Landroid/widget/LinearLayout;

    invoke-virtual {v0, p2}, Landroid/widget/LinearLayout;->setOrientation(I)V

    invoke-virtual {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->addView(Landroid/view/View;)V

    return-void
.end method

.method private apply(Ljava/lang/String;I)V
    .locals 3

    .line 120
    iget-boolean v0, p0, Lcom/gmhub/uv/UndervoltPanel;->busy:Z

    if-nez v0, :cond_20

    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    if-nez v0, :cond_9

    goto :goto_20

    :cond_9
    const/4 v0, 0x0

    .line 121
    invoke-direct {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->enabled(Z)V

    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    .line 122
    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->status:Landroid/widget/TextView;

    const-string v2, "Aguardando confirma\u00e7\u00e3o do kernel\u2026"

    invoke-virtual {v1, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 123
    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    new-instance v2, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;

    invoke-direct {v2, p0, p1, p2, v0}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;-><init>(Lcom/gmhub/uv/UndervoltPanel;Ljava/lang/String;II)V

    invoke-interface {v1, v2}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    :cond_20
    :goto_20
    return-void
.end method

.method private choose(Ljava/lang/String;Ljava/lang/String;I)V
    .locals 5

    .line 103
    iget-boolean v0, p0, Lcom/gmhub/uv/UndervoltPanel;->busy:Z

    if-eqz v0, :cond_5

    return-void

    :cond_5
    const/16 v0, 0xb

    .line 105
    new-array v1, v0, [Ljava/lang/String;

    const/4 v2, 0x0

    :goto_a
    if-ge v2, v0, :cond_29

    if-nez v2, :cond_11

    .line 106
    const-string v3, "0% \u00b7 padr\u00e3o"

    goto :goto_24

    :cond_11
    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "\u2212"

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v4, "%"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    :goto_24
    aput-object v3, v1, v2

    add-int/lit8 v2, v2, 0x1

    goto :goto_a

    :cond_29
    if-gtz p3, :cond_31

    const/16 v0, -0xa

    if-lt p3, v0, :cond_31

    neg-int v0, p3

    goto :goto_32

    :cond_31
    const/4 v0, -0x1

    .line 108
    :goto_32
    new-instance v2, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->getContext()Landroid/content/Context;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v2, p2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p2

    new-instance v2, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;

    invoke-direct {v2, p0, p3, p1}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;-><init>(Lcom/gmhub/uv/UndervoltPanel;ILjava/lang/String;)V

    .line 109
    invoke-virtual {p2, v1, v0, v2}, Landroid/app/AlertDialog$Builder;->setSingleChoiceItems([Ljava/lang/CharSequence;ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string p2, "Cancelar"

    const/4 p3, 0x0

    .line 116
    invoke-virtual {p1, p2, p3}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    invoke-virtual {p1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    move-result-object p1

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel;->dialog:Landroid/app/AlertDialog;

    return-void
.end method

.method private display(Ljava/util/Map;)V
    .locals 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;)V"
        }
    .end annotation

    .line 87
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->rows:Landroid/widget/LinearLayout;

    invoke-virtual {v0}, Landroid/widget/LinearLayout;->removeAllViews()V

    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->controls:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 88
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->status:Landroid/widget/TextView;

    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->lastResult:Ljava/lang/String;

    if-eqz v1, :cond_11

    goto :goto_13

    :cond_11
    const-string v1, "Valores lidos do kernel. Toque em um dom\u00ednio para escolher seu ajuste."

    :goto_13
    invoke-virtual {v0, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    const/4 v0, 0x0

    move v1, v0

    .line 89
    :goto_18
    sget-object v2, Lcom/gmhub/uv/UvBackend;->DOMAINS:[Ljava/lang/String;

    array-length v2, v2

    if-ge v1, v2, :cond_97

    .line 90
    sget-object v2, Lcom/gmhub/uv/UvBackend;->DOMAINS:[Ljava/lang/String;

    aget-object v2, v2, v1

    invoke-interface {p1, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    if-nez v3, :cond_2a

    goto :goto_94

    .line 92
    :cond_2a
    sget-object v4, Lcom/gmhub/uv/UvBackend;->LABELS:[Ljava/lang/String;

    aget-object v4, v4, v1

    .line 93
    new-instance v5, Landroid/widget/Button;

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->getContext()Landroid/content/Context;

    move-result-object v6

    invoke-direct {v5, v6}, Landroid/widget/Button;-><init>(Landroid/content/Context;)V

    .line 94
    invoke-virtual {v5, v0}, Landroid/widget/Button;->setAllCaps(Z)V

    const/16 v6, 0x38

    invoke-direct {p0, v6}, Lcom/gmhub/uv/UndervoltPanel;->dp(I)I

    move-result v6

    invoke-virtual {v5, v6}, Landroid/widget/Button;->setMinHeight(I)V

    .line 95
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v7, " \u00b7 "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v7, "%"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/widget/Button;->setText(Ljava/lang/CharSequence;)V

    .line 96
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v7, ", tens\u00e3o "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v7, " por cento. Alterar"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Landroid/widget/Button;->setContentDescription(Ljava/lang/CharSequence;)V

    .line 97
    new-instance v6, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda6;

    invoke-direct {v6, p0, v2, v4, v3}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda6;-><init>(Lcom/gmhub/uv/UndervoltPanel;Ljava/lang/String;Ljava/lang/String;Ljava/lang/Integer;)V

    invoke-virtual {v5, v6}, Landroid/widget/Button;->setOnClickListener(Landroid/view/View$OnClickListener;)V

    .line 98
    iget-object v2, p0, Lcom/gmhub/uv/UndervoltPanel;->rows:Landroid/widget/LinearLayout;

    new-instance v3, Landroid/widget/LinearLayout$LayoutParams;

    const/4 v4, -0x1

    const/4 v6, -0x2

    invoke-direct {v3, v4, v6}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V

    invoke-virtual {v2, v5, v3}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    iget-object v2, p0, Lcom/gmhub/uv/UndervoltPanel;->controls:Ljava/util/List;

    invoke-interface {v2, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    :goto_94
    add-int/lit8 v1, v1, 0x1

    goto :goto_18

    :cond_97
    return-void
.end method

.method private dp(I)I
    .locals 0

    int-to-float p1, p1

    .line 44
    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->getResources()Landroid/content/res/Resources;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object p0

    iget p0, p0, Landroid/util/DisplayMetrics;->density:F

    mul-float/2addr p1, p0

    invoke-static {p1}, Ljava/lang/Math;->round(F)I

    move-result p0

    return p0
.end method

.method private enabled(Z)V
    .locals 1

    xor-int/lit8 v0, p1, 0x1

    .line 64
    iput-boolean v0, p0, Lcom/gmhub/uv/UndervoltPanel;->busy:Z

    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->refresh:Landroid/widget/Button;

    invoke-virtual {v0, p1}, Landroid/widget/Button;->setEnabled(Z)V

    .line 65
    iget-object p0, p0, Lcom/gmhub/uv/UndervoltPanel;->controls:Ljava/util/List;

    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_f
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1f

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/widget/Button;

    invoke-virtual {v0, p1}, Landroid/widget/Button;->setEnabled(Z)V

    goto :goto_f

    :cond_1f
    return-void
.end method

.method private load()V
    .locals 3

    .line 69
    iget-boolean v0, p0, Lcom/gmhub/uv/UndervoltPanel;->busy:Z

    if-nez v0, :cond_19

    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    if-nez v0, :cond_9

    goto :goto_19

    :cond_9
    const/4 v0, 0x0

    .line 70
    invoke-direct {p0, v0}, Lcom/gmhub/uv/UndervoltPanel;->enabled(Z)V

    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    .line 71
    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    new-instance v2, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;

    invoke-direct {v2, p0, v0}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;-><init>(Lcom/gmhub/uv/UndervoltPanel;I)V

    invoke-interface {v1, v2}, Ljava/util/concurrent/ExecutorService;->execute(Ljava/lang/Runnable;)V

    :cond_19
    :goto_19
    return-void
.end method

.method private text(Ljava/lang/String;I)Landroid/widget/TextView;
    .locals 2

    .line 46
    new-instance v0, Landroid/widget/TextView;

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    int-to-float p1, p2

    invoke-virtual {v0, p1}, Landroid/widget/TextView;->setTextSize(F)V

    const/16 p1, 0x8

    .line 47
    invoke-direct {p0, p1}, Lcom/gmhub/uv/UndervoltPanel;->dp(I)I

    move-result p2

    invoke-direct {p0, p1}, Lcom/gmhub/uv/UndervoltPanel;->dp(I)I

    move-result p0

    const/4 p1, 0x0

    invoke-virtual {v0, p1, p2, p1, p0}, Landroid/widget/TextView;->setPadding(IIII)V

    return-object v0
.end method


# virtual methods
.method synthetic lambda$apply$0$com-gmhub-uv-UndervoltPanel(Ljava/lang/String;II)V
    .locals 1

    .line 0
    const-string v0, "Solicita\u00e7\u00e3o aceita pelo firmware: "

    .line 125
    :try_start_2
    invoke-static {p1, p2}, Lcom/gmhub/uv/UvBackend;->apply(Ljava/lang/String;I)V

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p2, "%."

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1
    :try_end_16
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_16} :catch_17

    goto :goto_2a

    :catch_17
    move-exception p1

    .line 126
    new-instance p2, Ljava/lang/StringBuilder;

    const-string v0, "N\u00e3o foi poss\u00edvel confirmar o ajuste. "

    invoke-direct {p2, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 128
    :goto_2a
    iget-object p2, p0, Lcom/gmhub/uv/UndervoltPanel;->main:Landroid/os/Handler;

    new-instance v0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda2;

    invoke-direct {v0, p0, p3, p1}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda2;-><init>(Lcom/gmhub/uv/UndervoltPanel;ILjava/lang/String;)V

    invoke-virtual {p2, v0}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method synthetic lambda$apply$1$com-gmhub-uv-UndervoltPanel(ILjava/lang/String;)V
    .locals 1

    .line 129
    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    if-ne p1, v0, :cond_19

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->isAttachedToWindow()Z

    move-result p1

    if-nez p1, :cond_b

    goto :goto_19

    :cond_b
    const/4 p1, 0x1

    .line 130
    invoke-direct {p0, p1}, Lcom/gmhub/uv/UndervoltPanel;->enabled(Z)V

    iput-object p2, p0, Lcom/gmhub/uv/UndervoltPanel;->lastResult:Ljava/lang/String;

    iget-object p1, p0, Lcom/gmhub/uv/UndervoltPanel;->status:Landroid/widget/TextView;

    invoke-virtual {p1, p2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 132
    invoke-direct {p0}, Lcom/gmhub/uv/UndervoltPanel;->load()V

    :cond_19
    :goto_19
    return-void
.end method

.method synthetic lambda$choose$0$com-gmhub-uv-UndervoltPanel(ILjava/lang/String;Landroid/content/DialogInterface;I)V
    .locals 1

    .line 110
    invoke-interface {p3}, Landroid/content/DialogInterface;->dismiss()V

    neg-int p3, p4

    if-ne p3, p1, :cond_7

    return-void

    .line 112
    :cond_7
    new-instance p1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->getContext()Landroid/content/Context;

    move-result-object p4

    invoke-direct {p1, p4}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    new-instance p4, Ljava/lang/StringBuilder;

    const-string v0, "Aplicar "

    invoke-direct {p4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p4, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, "%?"

    invoke-virtual {p4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p4

    invoke-virtual {p1, p4}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string p4, "Uma redu\u00e7\u00e3o excessiva pode causar instabilidade. Este ajuste vale para a inicializa\u00e7\u00e3o atual."

    .line 113
    invoke-virtual {p1, p4}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    const-string p4, "Cancelar"

    const/4 v0, 0x0

    .line 114
    invoke-virtual {p1, p4, v0}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    new-instance p4, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;

    invoke-direct {p4, p0, p2, p3}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;-><init>(Lcom/gmhub/uv/UndervoltPanel;Ljava/lang/String;I)V

    .line 115
    const-string p2, "Aplicar"

    invoke-virtual {p1, p2, p4}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object p1

    invoke-virtual {p1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    move-result-object p1

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel;->dialog:Landroid/app/AlertDialog;

    return-void
.end method

.method synthetic lambda$choose$1$com-gmhub-uv-UndervoltPanel(Ljava/lang/String;ILandroid/content/DialogInterface;I)V
    .locals 0

    .line 115
    invoke-direct {p0, p1, p2}, Lcom/gmhub/uv/UndervoltPanel;->apply(Ljava/lang/String;I)V

    return-void
.end method

.method synthetic lambda$display$0$com-gmhub-uv-UndervoltPanel(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Integer;Landroid/view/View;)V
    .locals 0

    .line 97
    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    invoke-direct {p0, p1, p2, p3}, Lcom/gmhub/uv/UndervoltPanel;->choose(Ljava/lang/String;Ljava/lang/String;I)V

    return-void
.end method

.method synthetic lambda$load$0$com-gmhub-uv-UndervoltPanel(I)V
    .locals 3

    .line 73
    :try_start_0
    invoke-static {}, Lcom/gmhub/uv/UvBackend;->read()Ljava/util/Map;

    move-result-object v0

    .line 74
    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->main:Landroid/os/Handler;

    new-instance v2, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda3;

    invoke-direct {v2, p0, p1, v0}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda3;-><init>(Lcom/gmhub/uv/UndervoltPanel;ILjava/util/Map;)V

    invoke-virtual {v1, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z
    :try_end_e
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_e} :catch_f

    return-void

    :catch_f
    move-exception v0

    .line 76
    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->main:Landroid/os/Handler;

    new-instance v2, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;

    invoke-direct {v2, p0, p1, v0}, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;-><init>(Lcom/gmhub/uv/UndervoltPanel;ILjava/lang/Exception;)V

    invoke-virtual {v1, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method synthetic lambda$load$1$com-gmhub-uv-UndervoltPanel(ILjava/util/Map;)V
    .locals 1

    .line 74
    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    if-ne p1, v0, :cond_11

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->isAttachedToWindow()Z

    move-result p1

    if-eqz p1, :cond_11

    invoke-direct {p0, p2}, Lcom/gmhub/uv/UndervoltPanel;->display(Ljava/util/Map;)V

    const/4 p1, 0x1

    invoke-direct {p0, p1}, Lcom/gmhub/uv/UndervoltPanel;->enabled(Z)V

    :cond_11
    return-void
.end method

.method synthetic lambda$load$2$com-gmhub-uv-UndervoltPanel(ILjava/lang/Exception;)V
    .locals 1

    .line 77
    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    if-ne p1, v0, :cond_30

    invoke-virtual {p0}, Lcom/gmhub/uv/UndervoltPanel;->isAttachedToWindow()Z

    move-result p1

    if-nez p1, :cond_b

    goto :goto_30

    .line 78
    :cond_b
    iget-object p1, p0, Lcom/gmhub/uv/UndervoltPanel;->rows:Landroid/widget/LinearLayout;

    invoke-virtual {p1}, Landroid/widget/LinearLayout;->removeAllViews()V

    iget-object p1, p0, Lcom/gmhub/uv/UndervoltPanel;->controls:Ljava/util/List;

    invoke-interface {p1}, Ljava/util/List;->clear()V

    const/4 p1, 0x1

    invoke-direct {p0, p1}, Lcom/gmhub/uv/UndervoltPanel;->enabled(Z)V

    .line 79
    iget-object p0, p0, Lcom/gmhub/uv/UndervoltPanel;->status:Landroid/widget/TextView;

    new-instance p1, Ljava/lang/StringBuilder;

    const-string v0, "\u00c9 necess\u00e1rio o GMKernel com confirma\u00e7\u00e3o de ajustes e acesso root autorizado para Configura\u00e7\u00f5es. Nenhum valor foi alterado.\n"

    invoke-direct {p1, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 80
    invoke-virtual {p2}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 79
    invoke-virtual {p0, p1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    :cond_30
    :goto_30
    return-void
.end method

.method synthetic lambda$new$0$com-gmhub-uv-UndervoltPanel(Landroid/view/View;)V
    .locals 0

    .line 40
    invoke-direct {p0}, Lcom/gmhub/uv/UndervoltPanel;->load()V

    return-void
.end method

.method protected onAttachedToWindow()V
    .locals 1

    .line 51
    invoke-super {p0}, Landroid/widget/LinearLayout;->onAttachedToWindow()V

    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    add-int/lit8 v0, v0, 0x1

    iput v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    .line 52
    invoke-static {}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor()Ljava/util/concurrent/ExecutorService;

    move-result-object v0

    iput-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    invoke-direct {p0}, Lcom/gmhub/uv/UndervoltPanel;->load()V

    return-void
.end method

.method protected onDetachedFromWindow()V
    .locals 2

    .line 56
    iget v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    add-int/lit8 v0, v0, 0x1

    iput v0, p0, Lcom/gmhub/uv/UndervoltPanel;->generation:I

    .line 57
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->dialog:Landroid/app/AlertDialog;

    const/4 v1, 0x0

    if-eqz v0, :cond_10

    invoke-virtual {v0}, Landroid/app/AlertDialog;->dismiss()V

    iput-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->dialog:Landroid/app/AlertDialog;

    .line 58
    :cond_10
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    if-eqz v0, :cond_19

    invoke-interface {v0}, Ljava/util/concurrent/ExecutorService;->shutdownNow()Ljava/util/List;

    iput-object v1, p0, Lcom/gmhub/uv/UndervoltPanel;->worker:Ljava/util/concurrent/ExecutorService;

    .line 59
    :cond_19
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel;->main:Landroid/os/Handler;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacksAndMessages(Ljava/lang/Object;)V

    const/4 v0, 0x0

    .line 60
    iput-boolean v0, p0, Lcom/gmhub/uv/UndervoltPanel;->busy:Z

    invoke-super {p0}, Landroid/widget/LinearLayout;->onDetachedFromWindow()V

    return-void
.end method
