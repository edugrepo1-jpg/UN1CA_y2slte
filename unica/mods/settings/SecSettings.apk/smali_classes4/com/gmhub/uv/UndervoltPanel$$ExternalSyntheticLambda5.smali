.class public final synthetic Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/gmhub/uv/UndervoltPanel;

.field public final synthetic f$1:Ljava/lang/String;

.field public final synthetic f$2:I

.field public final synthetic f$3:I


# direct methods
.method public synthetic constructor <init>(Lcom/gmhub/uv/UndervoltPanel;Ljava/lang/String;II)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iput-object p2, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$1:Ljava/lang/String;

    iput p3, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$2:I

    iput p4, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$3:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 3

    .line 0
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iget-object v1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$1:Ljava/lang/String;

    iget v2, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$2:I

    iget p0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda5;->f$3:I

    invoke-virtual {v0, v1, v2, p0}, Lcom/gmhub/uv/UndervoltPanel;->lambda$apply$0$com-gmhub-uv-UndervoltPanel(Ljava/lang/String;II)V

    return-void
.end method
