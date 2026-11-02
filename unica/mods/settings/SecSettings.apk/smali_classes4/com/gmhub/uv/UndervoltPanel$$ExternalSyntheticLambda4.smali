.class public final synthetic Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/gmhub/uv/UndervoltPanel;

.field public final synthetic f$1:I

.field public final synthetic f$2:Ljava/lang/Exception;


# direct methods
.method public synthetic constructor <init>(Lcom/gmhub/uv/UndervoltPanel;ILjava/lang/Exception;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iput p2, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;->f$1:I

    iput-object p3, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;->f$2:Ljava/lang/Exception;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    .line 0
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iget v1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;->f$1:I

    iget-object p0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda4;->f$2:Ljava/lang/Exception;

    invoke-virtual {v0, v1, p0}, Lcom/gmhub/uv/UndervoltPanel;->lambda$load$2$com-gmhub-uv-UndervoltPanel(ILjava/lang/Exception;)V

    return-void
.end method
