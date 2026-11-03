.class public final synthetic Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# instance fields
.field public final synthetic f$0:Lcom/gmhub/uv/UndervoltPanel;

.field public final synthetic f$1:I

.field public final synthetic f$2:Ljava/lang/String;


# direct methods
.method public synthetic constructor <init>(Lcom/gmhub/uv/UndervoltPanel;ILjava/lang/String;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iput p2, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;->f$1:I

    iput-object p3, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;->f$2:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public final onClick(Landroid/content/DialogInterface;I)V
    .locals 2

    .line 0
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iget v1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;->f$1:I

    iget-object p0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda7;->f$2:Ljava/lang/String;

    invoke-virtual {v0, v1, p0, p1, p2}, Lcom/gmhub/uv/UndervoltPanel;->lambda$choose$0$com-gmhub-uv-UndervoltPanel(ILjava/lang/String;Landroid/content/DialogInterface;I)V

    return-void
.end method
