.class public final synthetic Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# instance fields
.field public final synthetic f$0:Lcom/gmhub/uv/UndervoltPanel;

.field public final synthetic f$1:Ljava/lang/String;

.field public final synthetic f$2:I


# direct methods
.method public synthetic constructor <init>(Lcom/gmhub/uv/UndervoltPanel;Ljava/lang/String;I)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iput-object p2, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;->f$1:Ljava/lang/String;

    iput p3, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;->f$2:I

    return-void
.end method


# virtual methods
.method public final onClick(Landroid/content/DialogInterface;I)V
    .locals 2

    .line 0
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;->f$1:Ljava/lang/String;

    iget p0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda8;->f$2:I

    invoke-virtual {v0, v1, p0, p1, p2}, Lcom/gmhub/uv/UndervoltPanel;->lambda$choose$1$com-gmhub-uv-UndervoltPanel(Ljava/lang/String;ILandroid/content/DialogInterface;I)V

    return-void
.end method
