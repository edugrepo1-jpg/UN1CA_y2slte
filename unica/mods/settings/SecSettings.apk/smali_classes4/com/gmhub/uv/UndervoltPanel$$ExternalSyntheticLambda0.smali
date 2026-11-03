.class public final synthetic Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/gmhub/uv/UndervoltPanel;

.field public final synthetic f$1:I


# direct methods
.method public synthetic constructor <init>(Lcom/gmhub/uv/UndervoltPanel;I)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iput p2, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;->f$1:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 1

    .line 0
    iget-object v0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;->f$0:Lcom/gmhub/uv/UndervoltPanel;

    iget p0, p0, Lcom/gmhub/uv/UndervoltPanel$$ExternalSyntheticLambda0;->f$1:I

    invoke-virtual {v0, p0}, Lcom/gmhub/uv/UndervoltPanel;->lambda$load$0$com-gmhub-uv-UndervoltPanel(I)V

    return-void
.end method
