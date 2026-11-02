.class public final Lcom/gmhub/uv/UvBackend;
.super Ljava/lang/Object;
.source "UvBackend.java"


# static fields
.field public static final DOMAINS:[Ljava/lang/String;

.field public static final LABELS:[Ljava/lang/String;

.field public static final MAX:I = 0x0

.field public static final MIN:I = -0xa

.field private static final ROOT:Ljava/lang/String; = "/sys/power/percent_margin/"


# direct methods
.method static constructor <clinit>()V
    .locals 5

    .line 13
    const-string v0, "g3d"

    const-string v1, "mif"

    const-string v2, "lit"

    const-string v3, "mid"

    const-string v4, "big"

    filled-new-array {v2, v3, v4, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/gmhub/uv/UvBackend;->DOMAINS:[Ljava/lang/String;

    .line 14
    const-string v0, "GPU"

    const-string v1, "Mem\u00f3ria RAM"

    const-string v2, "CPU eficiente \u00b7 A55"

    const-string v3, "CPU intermedi\u00e1ria \u00b7 A76"

    const-string v4, "CPU de desempenho \u00b7 M5"

    filled-new-array {v2, v3, v4, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/gmhub/uv/UvBackend;->LABELS:[Ljava/lang/String;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .line 11
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static apply(Ljava/lang/String;I)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 71
    invoke-static {p0}, Lcom/gmhub/uv/UvBackend;->node(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    const/16 v0, -0xa

    if-lt p1, v0, :cond_4a

    if-gtz p1, :cond_4a

    .line 75
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {}, Lcom/gmhub/uv/UvBackend;->guard()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, "printf \'%s\\n\' \'"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v1, "\' > "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, " || exit 71; cat "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p0, " || exit 72"

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lcom/gmhub/uv/UvBackend;->root(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    .line 77
    invoke-static {p0}, Lcom/gmhub/uv/UvBackend;->parsePercent(Ljava/lang/String;)I

    move-result p0

    if-ne p0, p1, :cond_42

    return-void

    :cond_42
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string p1, "A leitura n\u00e3o confirmou o ajuste"

    invoke-direct {p0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 72
    :cond_4a
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "Ajuste fora da faixa do Hub"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private static guard()Ljava/lang/String;
    .locals 1

    .line 52
    const-string v0, "[ \"$(id -u)\" = 0 ] && [ \"$(cat /sys/power/percent_margin/gmhub_checked 2>/dev/null)\" = 1 ] || exit 70; "

    return-object v0
.end method

.method private static node(Ljava/lang/String;)Ljava/lang/String;
    .locals 4

    .line 21
    sget-object v0, Lcom/gmhub/uv/UvBackend;->DOMAINS:[Ljava/lang/String;

    array-length v1, v0

    const/4 v2, 0x0

    :goto_4
    if-ge v2, v1, :cond_25

    aget-object v3, v0, v2

    invoke-virtual {v3, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_22

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "/sys/power/percent_margin/"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p0, "_margin_percent"

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0

    :cond_22
    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 22
    :cond_25
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "Dom\u00ednio indispon\u00edvel"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static parsePercent(Ljava/lang/String;)I
    .locals 1

    if-eqz p0, :cond_1f

    .line 26
    const-string v0, "-?(0|[1-9][0-9]{0,2})"

    invoke-virtual {p0, v0}, Ljava/lang/String;->matches(Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_1f

    .line 28
    invoke-static {p0}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result p0

    const/16 v0, -0x64

    if-lt p0, v0, :cond_17

    const/16 v0, 0x64

    if-gt p0, v0, :cond_17

    return p0

    .line 29
    :cond_17
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "Valor fora da interface do kernel"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 27
    :cond_1f
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string v0, "Valor inv\u00e1lido"

    invoke-direct {p0, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method public static read()Ljava/util/Map;
    .locals 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 56
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-static {}, Lcom/gmhub/uv/UvBackend;->guard()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 57
    sget-object v1, Lcom/gmhub/uv/UvBackend;->DOMAINS:[Ljava/lang/String;

    array-length v2, v1

    const/4 v3, 0x0

    move v4, v3

    :goto_e
    if-ge v4, v2, :cond_3a

    aget-object v5, v1, v4

    const-string v6, "if [ -r "

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v5}, Lcom/gmhub/uv/UvBackend;->node(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, " ]; then printf \'"

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 58
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v6, "=\'; cat "

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v5}, Lcom/gmhub/uv/UvBackend;->node(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v5, "; fi; "

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    add-int/lit8 v4, v4, 0x1

    goto :goto_e

    .line 59
    :cond_3a
    new-instance v1, Ljava/util/LinkedHashMap;

    invoke-direct {v1}, Ljava/util/LinkedHashMap;-><init>()V

    .line 60
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lcom/gmhub/uv/UvBackend;->root(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v2, "\\R"

    invoke-virtual {v0, v2}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v0

    array-length v2, v0

    move v4, v3

    :goto_4f
    if-ge v4, v2, :cond_82

    aget-object v5, v0, v4

    .line 61
    const-string v6, "="

    const/4 v7, -0x1

    invoke-virtual {v5, v6, v7}, Ljava/lang/String;->split(Ljava/lang/String;I)[Ljava/lang/String;

    move-result-object v5

    .line 62
    array-length v6, v5

    const/4 v7, 0x2

    if-ne v6, v7, :cond_7a

    .line 63
    aget-object v6, v5, v3

    invoke-static {v6}, Lcom/gmhub/uv/UvBackend;->node(Ljava/lang/String;)Ljava/lang/String;

    .line 64
    aget-object v6, v5, v3

    const/4 v7, 0x1

    aget-object v5, v5, v7

    invoke-virtual {v5}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Lcom/gmhub/uv/UvBackend;->parsePercent(Ljava/lang/String;)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-interface {v1, v6, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    add-int/lit8 v4, v4, 0x1

    goto :goto_4f

    .line 62
    :cond_7a
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "Resposta inv\u00e1lida do kernel"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 66
    :cond_82
    invoke-interface {v1}, Ljava/util/Map;->isEmpty()Z

    move-result v0

    if-nez v0, :cond_89

    return-object v1

    :cond_89
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "Nenhum dom\u00ednio compat\u00edvel"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static root(Ljava/lang/String;)Ljava/lang/String;
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 34
    new-instance v0, Ljava/lang/ProcessBuilder;

    const-string v1, "su"

    const-string v2, "-c"

    filled-new-array {v1, v2, p0}, [Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/ProcessBuilder;-><init>([Ljava/lang/String;)V

    const/4 p0, 0x1

    invoke-virtual {v0, p0}, Ljava/lang/ProcessBuilder;->redirectErrorStream(Z)Ljava/lang/ProcessBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/ProcessBuilder;->start()Ljava/lang/Process;

    move-result-object p0

    .line 37
    :try_start_16
    sget-object v0, Ljava/util/concurrent/TimeUnit;->SECONDS:Ljava/util/concurrent/TimeUnit;

    const-wide/16 v1, 0xf

    invoke-virtual {p0, v1, v2, v0}, Ljava/lang/Process;->waitFor(JLjava/util/concurrent/TimeUnit;)Z

    move-result v0

    if-eqz v0, :cond_7c

    .line 38
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 39
    invoke-virtual {p0}, Ljava/lang/Process;->getInputStream()Ljava/io/InputStream;

    move-result-object v1
    :try_end_29
    .catchall {:try_start_16 .. :try_end_29} :catchall_84

    const/16 v2, 0x400

    .line 40
    :try_start_2b
    new-array v2, v2, [B

    .line 41
    :goto_2d
    invoke-virtual {v1, v2}, Ljava/io/InputStream;->read([B)I

    move-result v3

    const/4 v4, -0x1

    if-eq v3, v4, :cond_4a

    .line 42
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v4

    add-int/2addr v4, v3

    const/16 v5, 0x2000

    if-gt v4, v5, :cond_42

    const/4 v4, 0x0

    .line 43
    invoke-virtual {v0, v2, v4, v3}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_2d

    .line 42
    :cond_42
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v2, "Resposta inesperada do kernel"

    invoke-direct {v0, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_4a
    .catchall {:try_start_2b .. :try_end_4a} :catchall_70

    :cond_4a
    if-eqz v1, :cond_4f

    .line 45
    :try_start_4c
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    .line 46
    :cond_4f
    invoke-virtual {p0}, Ljava/lang/Process;->exitValue()I

    move-result v1

    if-nez v1, :cond_68

    .line 47
    new-instance v1, Ljava/lang/String;

    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v0

    sget-object v2, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v1, v0, v2}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v0
    :try_end_64
    .catchall {:try_start_4c .. :try_end_64} :catchall_84

    .line 48
    invoke-virtual {p0}, Ljava/lang/Process;->destroy()V

    return-object v0

    .line 46
    :cond_68
    :try_start_68
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "O kernel recusou o acesso ou o ajuste"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_70
    .catchall {:try_start_68 .. :try_end_70} :catchall_84

    :catchall_70
    move-exception v0

    if-eqz v1, :cond_7b

    .line 39
    :try_start_73
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    :try_end_76
    .catchall {:try_start_73 .. :try_end_76} :catchall_77

    goto :goto_7b

    :catchall_77
    move-exception v1

    :try_start_78
    invoke-virtual {v0, v1}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_7b
    :goto_7b
    throw v0

    .line 37
    :cond_7c
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "O acesso root n\u00e3o respondeu"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
    :try_end_84
    .catchall {:try_start_78 .. :try_end_84} :catchall_84

    :catchall_84
    move-exception v0

    .line 48
    invoke-virtual {p0}, Ljava/lang/Process;->destroy()V

    throw v0
.end method
