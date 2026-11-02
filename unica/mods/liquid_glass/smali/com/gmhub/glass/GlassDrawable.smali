.class public final Lcom/gmhub/glass/GlassDrawable;
.super Landroid/graphics/drawable/BitmapDrawable;
.source "GlassDrawable.java"


# static fields
.field private static final BROKEN:[Z

.field public static final ENGINE_KEY:Ljava/lang/String; = "gmhub_liquid_glass_engine"

.field private static final MAPPER:Ljava/lang/String; = "uniform shader bitmap; uniform float2 captureSize; uniform float2 viewSize; half4 main(float2 p) { return bitmap.eval(clamp(p / viewSize * captureSize, float2(0.5), captureSize - 0.5)); }"

.field private static final MAX_PIXELS:I = 0x400000

.field private static final MAX_SHADER_BYTES:I = 0x20000

.field private static final SOURCES:[Ljava/lang/String;

.field private static final TAG:Ljava/lang/String; = "GMHubGlass"


# instance fields
.field private allowed:Z

.field private final context:Landroid/content/Context;

.field private final density:F

.field private final engine:I

.field private final fallback:Landroid/graphics/drawable/BitmapDrawable;

.field private final glass:Landroid/graphics/Paint;

.field private height:I

.field private final lens:Landroid/graphics/RuntimeShader;

.field private final mapper:Landroid/graphics/RuntimeShader;

.field private nextPolicyCheck:J

.field private final raw:Landroid/graphics/Bitmap;

.field private final veil:Landroid/graphics/Paint;

.field private width:I


# direct methods
.method static constructor <clinit>()V
    .locals 2

    const/4 v0, 0x4

    .line 33
    new-array v1, v0, [Ljava/lang/String;

    sput-object v1, Lcom/gmhub/glass/GlassDrawable;->SOURCES:[Ljava/lang/String;

    .line 34
    new-array v0, v0, [Z

    sput-object v0, Lcom/gmhub/glass/GlassDrawable;->BROKEN:[Z

    return-void
.end method

.method private constructor <init>(Landroid/content/Context;Landroid/graphics/Bitmap;Landroid/graphics/drawable/BitmapDrawable;I)V
    .locals 5

    .line 103
    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    invoke-virtual {p3}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object v1

    invoke-direct {p0, v0, v1}, Landroid/graphics/drawable/BitmapDrawable;-><init>(Landroid/content/res/Resources;Landroid/graphics/Bitmap;)V

    .line 44
    new-instance v0, Landroid/graphics/Paint;

    const/4 v1, 0x1

    invoke-direct {v0, v1}, Landroid/graphics/Paint;-><init>(I)V

    iput-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->glass:Landroid/graphics/Paint;

    .line 45
    new-instance v2, Landroid/graphics/Paint;

    invoke-direct {v2, v1}, Landroid/graphics/Paint;-><init>(I)V

    iput-object v2, p0, Lcom/gmhub/glass/GlassDrawable;->veil:Landroid/graphics/Paint;

    .line 104
    iput-object p1, p0, Lcom/gmhub/glass/GlassDrawable;->context:Landroid/content/Context;

    .line 105
    iput-object p3, p0, Lcom/gmhub/glass/GlassDrawable;->fallback:Landroid/graphics/drawable/BitmapDrawable;

    .line 106
    iput-object p2, p0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    .line 107
    iput p4, p0, Lcom/gmhub/glass/GlassDrawable;->engine:I

    .line 108
    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v1

    iget v1, v1, Landroid/util/DisplayMetrics;->density:F

    iput v1, p0, Lcom/gmhub/glass/GlassDrawable;->density:F

    .line 109
    new-instance v1, Landroid/graphics/RuntimeShader;

    invoke-static {p1, p4}, Lcom/gmhub/glass/GlassDrawable;->source(Landroid/content/Context;I)Ljava/lang/String;

    move-result-object p1

    invoke-direct {v1, p1}, Landroid/graphics/RuntimeShader;-><init>(Ljava/lang/String;)V

    iput-object v1, p0, Lcom/gmhub/glass/GlassDrawable;->lens:Landroid/graphics/RuntimeShader;

    const/4 p1, 0x3

    if-ne p4, p1, :cond_3e

    const/4 v3, 0x0

    goto :goto_45

    .line 110
    :cond_3e
    new-instance v3, Landroid/graphics/RuntimeShader;

    const-string v4, "uniform shader bitmap; uniform float2 captureSize; uniform float2 viewSize; half4 main(float2 p) { return bitmap.eval(clamp(p / viewSize * captureSize, float2(0.5), captureSize - 0.5)); }"

    invoke-direct {v3, v4}, Landroid/graphics/RuntimeShader;-><init>(Ljava/lang/String;)V

    :goto_45
    iput-object v3, p0, Lcom/gmhub/glass/GlassDrawable;->mapper:Landroid/graphics/RuntimeShader;

    if-ne p4, p1, :cond_4a

    goto :goto_4e

    .line 111
    :cond_4a
    invoke-virtual {p3}, Landroid/graphics/drawable/BitmapDrawable;->getBitmap()Landroid/graphics/Bitmap;

    move-result-object p2

    :goto_4e
    if-eqz p2, :cond_92

    .line 112
    invoke-virtual {p2}, Landroid/graphics/Bitmap;->isRecycled()Z

    move-result p0

    if-nez p0, :cond_92

    .line 113
    new-instance p0, Landroid/graphics/BitmapShader;

    sget-object p1, Landroid/graphics/Shader$TileMode;->CLAMP:Landroid/graphics/Shader$TileMode;

    sget-object p3, Landroid/graphics/Shader$TileMode;->CLAMP:Landroid/graphics/Shader$TileMode;

    invoke-direct {p0, p2, p1, p3}, Landroid/graphics/BitmapShader;-><init>(Landroid/graphics/Bitmap;Landroid/graphics/Shader$TileMode;Landroid/graphics/Shader$TileMode;)V

    const/4 p1, 0x2

    .line 114
    invoke-virtual {p0, p1}, Landroid/graphics/BitmapShader;->setFilterMode(I)V

    if-eqz v3, :cond_7f

    .line 116
    const-string p1, "bitmap"

    invoke-virtual {v3, p1, p0}, Landroid/graphics/RuntimeShader;->setInputShader(Ljava/lang/String;Landroid/graphics/Shader;)V

    .line 117
    invoke-virtual {p2}, Landroid/graphics/Bitmap;->getWidth()I

    move-result p0

    int-to-float p0, p0

    invoke-virtual {p2}, Landroid/graphics/Bitmap;->getHeight()I

    move-result p1

    int-to-float p1, p1

    const-string p2, "captureSize"

    invoke-virtual {v3, p2, p0, p1}, Landroid/graphics/RuntimeShader;->setFloatUniform(Ljava/lang/String;FF)V

    .line 118
    const-string p0, "content"

    invoke-virtual {v1, p0, v3}, Landroid/graphics/RuntimeShader;->setInputShader(Ljava/lang/String;Landroid/graphics/Shader;)V

    goto :goto_89

    .line 120
    :cond_7f
    const-string p1, "uSource"

    invoke-virtual {v1, p1, p0}, Landroid/graphics/RuntimeShader;->setInputShader(Ljava/lang/String;Landroid/graphics/Shader;)V

    .line 121
    const-string p1, "uSourceLowRes"

    invoke-virtual {v1, p1, p0}, Landroid/graphics/RuntimeShader;->setInputShader(Ljava/lang/String;Landroid/graphics/Shader;)V

    .line 123
    :goto_89
    invoke-virtual {v0, v1}, Landroid/graphics/Paint;->setShader(Landroid/graphics/Shader;)Landroid/graphics/Shader;

    const/high16 p0, 0x33000000

    .line 125
    invoke-virtual {v2, p0}, Landroid/graphics/Paint;->setColor(I)V

    return-void

    .line 112
    :cond_92
    new-instance p0, Ljava/lang/IllegalStateException;

    const-string p1, "Missing captured backdrop"

    invoke-direct {p0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method private configure(II)V
    .locals 22

    move-object/from16 v0, p0

    move/from16 v1, p1

    move/from16 v2, p2

    const/high16 v3, 0x41e00000    # 28.0f

    .line 129
    iget v4, v0, Lcom/gmhub/glass/GlassDrawable;->density:F

    mul-float/2addr v4, v3

    invoke-static/range {p1 .. p2}, Ljava/lang/Math;->min(II)I

    move-result v3

    int-to-float v3, v3

    const/high16 v5, 0x40000000    # 2.0f

    div-float/2addr v3, v5

    invoke-static {v4, v3}, Ljava/lang/Math;->min(FF)F

    move-result v3

    const/high16 v4, 0x41900000    # 18.0f

    .line 130
    iget v6, v0, Lcom/gmhub/glass/GlassDrawable;->density:F

    mul-float/2addr v6, v4

    invoke-static/range {p1 .. p2}, Ljava/lang/Math;->min(II)I

    move-result v4

    int-to-float v4, v4

    const/high16 v7, 0x40800000    # 4.0f

    div-float/2addr v4, v7

    invoke-static {v6, v4}, Ljava/lang/Math;->min(FF)F

    move-result v4

    const/high16 v6, 0x3f800000    # 1.0f

    invoke-static {v6, v4}, Ljava/lang/Math;->max(FF)F

    move-result v4

    .line 131
    iget-object v7, v0, Lcom/gmhub/glass/GlassDrawable;->mapper:Landroid/graphics/RuntimeShader;

    const-string v8, "viewSize"

    if-eqz v7, :cond_39

    int-to-float v9, v1

    int-to-float v10, v2

    invoke-virtual {v7, v8, v9, v10}, Landroid/graphics/RuntimeShader;->setFloatUniform(Ljava/lang/String;FF)V

    .line 132
    :cond_39
    iget v7, v0, Lcom/gmhub/glass/GlassDrawable;->engine:I

    const/4 v12, 0x3

    const/4 v13, 0x4

    const/4 v14, 0x2

    const/4 v15, 0x0

    move/from16 v16, v5

    const/4 v5, 0x1

    const/16 v17, 0x0

    if-ne v7, v5, :cond_17d

    .line 133
    new-array v7, v5, [F

    aput v17, v7, v15

    move/from16 v18, v6

    const-string v6, "margin"

    invoke-direct {v0, v6, v7}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    int-to-float v6, v1

    int-to-float v7, v2

    const v19, 0x3f933333    # 1.15f

    new-array v9, v14, [F

    aput v6, v9, v15

    aput v7, v9, v5

    invoke-direct {v0, v8, v9}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    div-float v8, v6, v16

    div-float v9, v7, v16

    const v20, 0x3eb33333    # 0.35f

    .line 134
    new-array v10, v13, [F

    aput v8, v10, v15

    aput v9, v10, v5

    aput v8, v10, v14

    aput v9, v10, v12

    const v21, 0x3df5c28f    # 0.12f

    const-string v11, "shape1"

    invoke-direct {v0, v11, v10}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 135
    new-array v10, v13, [F

    aput v8, v10, v15

    aput v9, v10, v5

    aput v8, v10, v14

    aput v9, v10, v12

    const-string v11, "shape1L"

    invoke-direct {v0, v11, v10}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 136
    new-array v10, v13, [F

    aput v3, v10, v15

    aput v3, v10, v5

    aput v3, v10, v14

    aput v3, v10, v12

    const-string v3, "radii1"

    invoke-direct {v0, v3, v10}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v13, [F

    fill-array-data v3, :array_36e

    const-string v10, "shape2"

    invoke-direct {v0, v10, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 137
    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v10, "radius2"

    invoke-direct {v0, v10, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v10, "blendK"

    invoke-direct {v0, v10, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v10, "rimSoft"

    invoke-direct {v0, v10, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 138
    new-array v3, v5, [F

    aput v4, v3, v15

    const-string v10, "bevel"

    invoke-direct {v0, v10, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    const/high16 v3, 0x41c00000    # 24.0f

    iget v10, v0, Lcom/gmhub/glass/GlassDrawable;->density:F

    mul-float/2addr v10, v3

    invoke-static {v10, v4}, Ljava/lang/Math;->min(FF)F

    move-result v3

    new-array v4, v5, [F

    aput v3, v4, v15

    const-string v3, "refractPx"

    invoke-direct {v0, v3, v4}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 139
    new-array v3, v5, [F

    aput v16, v3, v15

    const-string v4, "falloff"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    const/high16 v4, -0x40800000    # -1.0f

    aput v4, v3, v15

    const-string v4, "refractDir"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 140
    new-array v3, v14, [F

    fill-array-data v3, :array_37a

    const-string v4, "sampleLo"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    const/high16 v3, 0x3f000000    # 0.5f

    sub-float/2addr v6, v3

    sub-float/2addr v7, v3

    new-array v3, v14, [F

    aput v6, v3, v15

    aput v7, v3, v5

    const-string v4, "sampleHi"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 141
    new-array v3, v5, [F

    aput v21, v3, v15

    const-string v4, "dispersion"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v14, [F

    fill-array-data v3, :array_382

    const-string v4, "lightDir"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 142
    new-array v3, v5, [F

    aput v20, v3, v15

    const-string v4, "specStrength"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    iget v3, v0, Lcom/gmhub/glass/GlassDrawable;->density:F

    mul-float v3, v3, v16

    new-array v4, v5, [F

    aput v3, v4, v15

    const-string v3, "rimBandMax"

    invoke-direct {v0, v3, v4}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 143
    new-array v3, v13, [F

    fill-array-data v3, :array_38a

    const-string v4, "tintColor"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v18, v3, v15

    const-string v4, "adaptiveTint"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 144
    new-array v3, v13, [F

    fill-array-data v3, :array_396

    const-string v4, "glassTint"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    const v4, 0x3da3d70a    # 0.08f

    aput v4, v3, v15

    const-string v4, "dimAmount"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v19, v3, v15

    const-string v4, "satFactor"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 145
    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "press"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v14, [F

    aput v8, v3, v15

    aput v9, v3, v5

    const-string v4, "touchPos"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "touchAmp"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    goto/16 :goto_369

    :cond_17d
    move/from16 v18, v6

    const v19, 0x3f933333    # 1.15f

    const v20, 0x3eb33333    # 0.35f

    const v21, 0x3df5c28f    # 0.12f

    if-ne v7, v14, :cond_1d7

    int-to-float v6, v1

    int-to-float v7, v2

    .line 147
    new-array v8, v14, [F

    aput v6, v8, v15

    aput v7, v8, v5

    const-string v6, "size"

    invoke-direct {v0, v6, v8}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v6, v14, [F

    fill-array-data v6, :array_3a2

    const-string v7, "offset"

    invoke-direct {v0, v7, v6}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v6, v13, [F

    aput v3, v6, v15

    aput v3, v6, v5

    aput v3, v6, v14

    aput v3, v6, v12

    const-string v3, "cornerRadii"

    invoke-direct {v0, v3, v6}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 148
    new-array v3, v5, [F

    aput v4, v3, v15

    const-string v6, "refractionHeight"

    invoke-direct {v0, v6, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    neg-float v3, v4

    new-array v4, v5, [F

    aput v3, v4, v15

    const-string v3, "refractionAmount"

    invoke-direct {v0, v3, v4}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 149
    new-array v3, v5, [F

    aput v18, v3, v15

    const-string v4, "depthEffect"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v21, v3, v15

    const-string v4, "chromaticAberration"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    goto/16 :goto_369

    .line 151
    :cond_1d7
    iget-object v6, v0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v6}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v6

    int-to-float v6, v6

    iget-object v7, v0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v7}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v7

    int-to-float v7, v7

    new-array v8, v13, [F

    aput v17, v8, v15

    aput v17, v8, v5

    aput v6, v8, v14

    aput v7, v8, v12

    const-string v6, "uSourceRect"

    invoke-direct {v0, v6, v8}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 152
    iget-object v6, v0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v6}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v6

    int-to-float v6, v6

    iget-object v7, v0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v7}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v7

    int-to-float v7, v7

    new-array v8, v13, [F

    aput v17, v8, v15

    aput v17, v8, v5

    aput v6, v8, v14

    aput v7, v8, v12

    const-string v6, "uSourceLowResRect"

    invoke-direct {v0, v6, v8}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 153
    iget-object v6, v0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v6}, Landroid/graphics/Bitmap;->getWidth()I

    move-result v6

    int-to-float v6, v6

    iget-object v7, v0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v7}, Landroid/graphics/Bitmap;->getHeight()I

    move-result v7

    int-to-float v7, v7

    new-array v8, v14, [F

    aput v6, v8, v15

    aput v7, v8, v5

    const-string v6, "uSourceSize"

    invoke-direct {v0, v6, v8}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    int-to-float v6, v1

    int-to-float v7, v2

    new-array v8, v14, [F

    aput v6, v8, v15

    aput v7, v8, v5

    const-string v9, "uViewport"

    invoke-direct {v0, v9, v8}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 154
    new-array v8, v5, [F

    aput v3, v8, v15

    const-string v3, "uCornerRadius"

    invoke-direct {v0, v3, v8}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v8, "uCornerIsConic"

    invoke-direct {v0, v8, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    const v8, 0x3fb2ca58    # 1.3968f

    aput v8, v3, v15

    const-string v9, "uCornerWeight"

    invoke-direct {v0, v9, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 155
    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v9, "uCornerConicBlend"

    invoke-direct {v0, v9, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v9, "uBlurRadius"

    invoke-direct {v0, v9, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 156
    new-array v3, v5, [F

    aput v4, v3, v15

    const-string v9, "uRefractionHeight"

    invoke-direct {v0, v9, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v4, v3, v15

    const-string v4, "uRefractionAmount"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v18, v3, v15

    const-string v4, "uDepth"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 157
    new-array v3, v5, [F

    aput v21, v3, v15

    const-string v4, "uDispersion"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v20, v3, v15

    const-string v4, "uHighlight"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 158
    iget v3, v0, Lcom/gmhub/glass/GlassDrawable;->density:F

    mul-float v3, v3, v16

    new-array v4, v5, [F

    aput v3, v4, v15

    const-string v3, "uHighlightWidth"

    invoke-direct {v0, v3, v4}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v16, v3, v15

    const-string v4, "uHighlightFalloff"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 159
    new-array v3, v5, [F

    const v4, 0x3ecccccd    # 0.4f

    aput v4, v3, v15

    const-string v4, "uHighlightFloor"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "uHighlightInnerAtt"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "uInnerGlow"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 160
    new-array v3, v5, [F

    aput v19, v3, v15

    const-string v4, "uVibrancy"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    const v4, 0x3f490fdb

    aput v4, v3, v15

    const-string v4, "uLightAngle"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v14, [F

    fill-array-data v3, :array_3aa

    const-string v4, "uParallax"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 161
    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "uDebugCoord"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "uDebugHighlight"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 162
    new-array v3, v13, [F

    aput v17, v3, v15

    aput v17, v3, v5

    aput v6, v3, v14

    aput v7, v3, v12

    const-string v4, "uMaskRect"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "uMaskCornerRadius"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 163
    new-array v3, v5, [F

    aput v8, v3, v15

    const-string v4, "uMaskWeight"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v14, [F

    fill-array-data v3, :array_3b2

    const-string v4, "uMaskOffset"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 165
    new-array v3, v5, [F

    aput v17, v3, v15

    const-string v4, "uMetaballEnable"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v13, [F

    fill-array-data v3, :array_3ba

    const-string v4, "uBodyRect"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 166
    new-array v3, v13, [F

    fill-array-data v3, :array_3c6

    const-string v4, "uBall1"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v13, [F

    fill-array-data v3, :array_3d2

    const-string v4, "uBall2"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v13, [F

    fill-array-data v3, :array_3de

    const-string v4, "uBall3"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 167
    new-array v3, v13, [F

    fill-array-data v3, :array_3ea

    const-string v4, "uMetaballParam"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    new-array v3, v13, [F

    fill-array-data v3, :array_3f6

    const-string v4, "uTilt"

    invoke-direct {v0, v4, v3}, Lcom/gmhub/glass/GlassDrawable;->f(Ljava/lang/String;[F)V

    .line 169
    :goto_369
    iput v1, v0, Lcom/gmhub/glass/GlassDrawable;->width:I

    iput v2, v0, Lcom/gmhub/glass/GlassDrawable;->height:I

    return-void

    :array_36e
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_37a
    .array-data 4
        0x3f000000    # 0.5f
        0x3f000000    # 0.5f
    .end array-data

    :array_382
    .array-data 4
        0x3f5db22d    # 0.866f
        0x3f000000    # 0.5f
    .end array-data

    :array_38a
    .array-data 4
        0x3f800000    # 1.0f
        0x3f800000    # 1.0f
        0x3f800000    # 1.0f
        0x3d23d70a    # 0.04f
    .end array-data

    :array_396
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_3a2
    .array-data 4
        0x0
        0x0
    .end array-data

    :array_3aa
    .array-data 4
        0x0
        0x0
    .end array-data

    :array_3b2
    .array-data 4
        0x0
        0x0
    .end array-data

    :array_3ba
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_3c6
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_3d2
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_3de
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_3ea
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data

    :array_3f6
    .array-data 4
        0x0
        0x0
        0x0
        0x0
    .end array-data
.end method

.method private varargs f(Ljava/lang/String;[F)V
    .locals 0

    .line 172
    iget-object p0, p0, Lcom/gmhub/glass/GlassDrawable;->lens:Landroid/graphics/RuntimeShader;

    invoke-virtual {p0, p1, p2}, Landroid/graphics/RuntimeShader;->setFloatUniform(Ljava/lang/String;[F)V

    return-void
.end method

.method private static declared-synchronized fail(ILjava/lang/Throwable;)V
    .locals 5

    const-string v0, "Glass engine "

    const-class v1, Lcom/gmhub/glass/GlassDrawable;

    monitor-enter v1

    .line 175
    :try_start_5
    sget-object v2, Lcom/gmhub/glass/GlassDrawable;->BROKEN:[Z

    aget-boolean v3, v2, p0

    if-nez v3, :cond_21

    const-string v3, "GMHubGlass"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v0, " unavailable; retaining Samsung blur"

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v3, v0, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    :cond_21
    const/4 p1, 0x1

    .line 176
    aput-boolean p1, v2, p0
    :try_end_24
    .catchall {:try_start_5 .. :try_end_24} :catchall_26

    .line 177
    monitor-exit v1

    return-void

    :catchall_26
    move-exception p0

    :try_start_27
    monitor-exit v1
    :try_end_28
    .catchall {:try_start_27 .. :try_end_28} :catchall_26

    throw p0
.end method

.method private static policyAllows(Landroid/content/Context;)Z
    .locals 3

    const/4 v0, 0x0

    .line 74
    :try_start_1
    const-class v1, Landroid/app/ActivityManager;

    invoke-virtual {p0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroid/app/ActivityManager;

    .line 75
    const-class v2, Landroid/os/PowerManager;

    invoke-virtual {p0, v2}, Landroid/content/Context;->getSystemService(Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/os/PowerManager;

    if-eqz v1, :cond_42

    .line 76
    invoke-virtual {v1}, Landroid/app/ActivityManager;->isLowRamDevice()Z

    move-result v1

    if-nez v1, :cond_42

    if-eqz v2, :cond_42

    .line 77
    invoke-virtual {v2}, Landroid/os/PowerManager;->isPowerSaveMode()Z

    move-result v1

    if-nez v1, :cond_42

    invoke-virtual {v2}, Landroid/os/PowerManager;->getCurrentThermalStatus()I

    move-result v1

    const/4 v2, 0x2

    if-ge v1, v2, :cond_42

    .line 78
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v1

    const-string v2, "accessibility_reduce_transparency"

    invoke-static {v1, v2, v0}, Landroid/provider/Settings$Secure;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result v1

    if-nez v1, :cond_42

    .line 79
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v1, "high_text_contrast_enabled"

    invoke-static {p0, v1, v0}, Landroid/provider/Settings$Secure;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result p0
    :try_end_3e
    .catch Ljava/lang/RuntimeException; {:try_start_1 .. :try_end_3e} :catch_42

    if-nez p0, :cond_42

    const/4 p0, 0x1

    return p0

    :catch_42
    :cond_42
    return v0
.end method

.method private static selected(Landroid/content/Context;)I
    .locals 2

    const/4 v0, 0x0

    .line 67
    :try_start_1
    invoke-virtual {p0}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p0

    const-string v1, "gmhub_liquid_glass_engine"

    invoke-static {p0, v1, v0}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result p0
    :try_end_b
    .catch Ljava/lang/RuntimeException; {:try_start_1 .. :try_end_b} :catch_12

    const/4 v1, 0x1

    if-lt p0, v1, :cond_12

    const/4 v1, 0x3

    if-gt p0, v1, :cond_12

    return p0

    :catch_12
    :cond_12
    return v0
.end method

.method private static declared-synchronized source(Landroid/content/Context;I)Ljava/lang/String;
    .locals 6

    const-string v0, "gmhub/liquid_glass/"

    const-class v1, Lcom/gmhub/glass/GlassDrawable;

    monitor-enter v1

    .line 84
    :try_start_5
    sget-object v2, Lcom/gmhub/glass/GlassDrawable;->SOURCES:[Ljava/lang/String;

    aget-object v2, v2, p1
    :try_end_9
    .catchall {:try_start_5 .. :try_end_9} :catchall_a0

    if-eqz v2, :cond_d

    monitor-exit v1

    return-object v2

    .line 85
    :cond_d
    :try_start_d
    const-string v2, ""

    const-string v3, "qwea"

    const-string v4, "kyant"

    const-string v5, "color"

    filled-new-array {v2, v3, v4, v5}, [Ljava/lang/String;

    move-result-object v2
    :try_end_19
    .catchall {:try_start_d .. :try_end_19} :catchall_a0

    .line 86
    :try_start_19
    invoke-virtual {p0}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object p0

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    aget-object v0, v2, p1

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, ".agsl"

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object p0
    :try_end_34
    .catch Ljava/io/IOException; {:try_start_19 .. :try_end_34} :catch_97
    .catchall {:try_start_19 .. :try_end_34} :catchall_a0

    .line 87
    :try_start_34
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V
    :try_end_39
    .catchall {:try_start_34 .. :try_end_39} :catchall_8b

    const/16 v2, 0x1000

    .line 88
    :try_start_3b
    new-array v2, v2, [B

    .line 90
    :goto_3d
    invoke-virtual {p0, v2}, Ljava/io/InputStream;->read([B)I

    move-result v3

    const/4 v4, -0x1

    if-eq v3, v4, :cond_5a

    .line 91
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->size()I

    move-result v4

    add-int/2addr v4, v3

    const/high16 v5, 0x20000

    if-gt v4, v5, :cond_52

    const/4 v4, 0x0

    .line 92
    invoke-virtual {v0, v2, v4, v3}, Ljava/io/ByteArrayOutputStream;->write([BII)V

    goto :goto_3d

    .line 91
    :cond_52
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v2, "Shader exceeds size limit"

    invoke-direct {p1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 94
    :cond_5a
    new-instance v2, Ljava/lang/String;

    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v3

    sget-object v4, Ljava/nio/charset/StandardCharsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v2, v3, v4}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    .line 95
    invoke-virtual {v2}, Ljava/lang/String;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_79

    .line 96
    sget-object v3, Lcom/gmhub/glass/GlassDrawable;->SOURCES:[Ljava/lang/String;

    aput-object v2, v3, p1
    :try_end_6f
    .catchall {:try_start_3b .. :try_end_6f} :catchall_81

    .line 97
    :try_start_6f
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->close()V
    :try_end_72
    .catchall {:try_start_6f .. :try_end_72} :catchall_8b

    if-eqz p0, :cond_77

    :try_start_74
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V
    :try_end_77
    .catch Ljava/io/IOException; {:try_start_74 .. :try_end_77} :catch_97
    .catchall {:try_start_74 .. :try_end_77} :catchall_a0

    .line 96
    :cond_77
    monitor-exit v1

    return-object v2

    .line 95
    :cond_79
    :try_start_79
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v2, "Empty shader"

    invoke-direct {p1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
    :try_end_81
    .catchall {:try_start_79 .. :try_end_81} :catchall_81

    :catchall_81
    move-exception p1

    .line 86
    :try_start_82
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->close()V
    :try_end_85
    .catchall {:try_start_82 .. :try_end_85} :catchall_86

    goto :goto_8a

    :catchall_86
    move-exception v0

    :try_start_87
    invoke-virtual {p1, v0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :goto_8a
    throw p1
    :try_end_8b
    .catchall {:try_start_87 .. :try_end_8b} :catchall_8b

    :catchall_8b
    move-exception p1

    if-eqz p0, :cond_96

    :try_start_8e
    invoke-virtual {p0}, Ljava/io/InputStream;->close()V
    :try_end_91
    .catchall {:try_start_8e .. :try_end_91} :catchall_92

    goto :goto_96

    :catchall_92
    move-exception p0

    :try_start_93
    invoke-virtual {p1, p0}, Ljava/lang/Throwable;->addSuppressed(Ljava/lang/Throwable;)V

    :cond_96
    :goto_96
    throw p1
    :try_end_97
    .catch Ljava/io/IOException; {:try_start_93 .. :try_end_97} :catch_97
    .catchall {:try_start_93 .. :try_end_97} :catchall_a0

    :catch_97
    move-exception p0

    .line 97
    :try_start_98
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Missing glass asset"

    invoke-direct {p1, v0, p0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw p1

    :catchall_a0
    move-exception p0

    monitor-exit v1
    :try_end_a2
    .catchall {:try_start_98 .. :try_end_a2} :catchall_a0

    throw p0
.end method

.method public static wrap(Landroid/content/Context;Landroid/graphics/Bitmap;Landroid/graphics/drawable/BitmapDrawable;Ljava/lang/String;)Landroid/graphics/drawable/BitmapDrawable;
    .locals 1

    .line 53
    const-string v0, "QUICK_PANEL"

    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_2f

    if-eqz p2, :cond_2f

    if-eqz p1, :cond_2f

    .line 54
    invoke-virtual {p1}, Landroid/graphics/Bitmap;->isRecycled()Z

    move-result p3

    if-nez p3, :cond_2f

    .line 55
    invoke-static {p0}, Lcom/gmhub/glass/GlassDrawable;->selected(Landroid/content/Context;)I

    move-result p3

    if-eqz p3, :cond_2f

    .line 56
    sget-object v0, Lcom/gmhub/glass/GlassDrawable;->BROKEN:[Z

    aget-boolean v0, v0, p3

    if-nez v0, :cond_2f

    invoke-static {p0}, Lcom/gmhub/glass/GlassDrawable;->policyAllows(Landroid/content/Context;)Z

    move-result v0

    if-nez v0, :cond_25

    goto :goto_2f

    .line 58
    :cond_25
    :try_start_25
    new-instance v0, Lcom/gmhub/glass/GlassDrawable;

    invoke-direct {v0, p0, p1, p2, p3}, Lcom/gmhub/glass/GlassDrawable;-><init>(Landroid/content/Context;Landroid/graphics/Bitmap;Landroid/graphics/drawable/BitmapDrawable;I)V
    :try_end_2a
    .catch Ljava/lang/RuntimeException; {:try_start_25 .. :try_end_2a} :catch_2b
    .catch Ljava/lang/LinkageError; {:try_start_25 .. :try_end_2a} :catch_2b
    .catch Ljava/lang/OutOfMemoryError; {:try_start_25 .. :try_end_2a} :catch_2b

    return-object v0

    :catch_2b
    move-exception p0

    .line 60
    invoke-static {p3, p0}, Lcom/gmhub/glass/GlassDrawable;->fail(ILjava/lang/Throwable;)V

    :cond_2f
    :goto_2f
    return-object p2
.end method


# virtual methods
.method public draw(Landroid/graphics/Canvas;)V
    .locals 10

    .line 180
    invoke-virtual {p0}, Lcom/gmhub/glass/GlassDrawable;->getBounds()Landroid/graphics/Rect;

    move-result-object v0

    .line 181
    invoke-virtual {v0}, Landroid/graphics/Rect;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_c

    goto/16 :goto_e5

    .line 182
    :cond_c
    iget-object v2, p0, Lcom/gmhub/glass/GlassDrawable;->fallback:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v2, v0}, Landroid/graphics/drawable/BitmapDrawable;->setBounds(Landroid/graphics/Rect;)V

    .line 183
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J

    move-result-wide v2

    .line 185
    iget-wide v4, p0, Lcom/gmhub/glass/GlassDrawable;->nextPolicyCheck:J

    cmp-long v4, v2, v4

    if-ltz v4, :cond_37

    .line 186
    iget-object v4, p0, Lcom/gmhub/glass/GlassDrawable;->context:Landroid/content/Context;

    invoke-static {v4}, Lcom/gmhub/glass/GlassDrawable;->selected(Landroid/content/Context;)I

    move-result v4

    iget v5, p0, Lcom/gmhub/glass/GlassDrawable;->engine:I

    if-ne v4, v5, :cond_2f

    iget-object v4, p0, Lcom/gmhub/glass/GlassDrawable;->context:Landroid/content/Context;

    invoke-static {v4}, Lcom/gmhub/glass/GlassDrawable;->policyAllows(Landroid/content/Context;)Z

    move-result v4

    if-eqz v4, :cond_2f

    const/4 v4, 0x1

    goto :goto_30

    :cond_2f
    const/4 v4, 0x0

    :goto_30
    iput-boolean v4, p0, Lcom/gmhub/glass/GlassDrawable;->allowed:Z

    const-wide/16 v4, 0x3e8

    add-long/2addr v2, v4

    .line 187
    iput-wide v2, p0, Lcom/gmhub/glass/GlassDrawable;->nextPolicyCheck:J

    .line 189
    :cond_37
    iget-boolean v2, p0, Lcom/gmhub/glass/GlassDrawable;->allowed:Z

    if-eqz v2, :cond_ea

    sget-object v2, Lcom/gmhub/glass/GlassDrawable;->BROKEN:[Z

    iget v3, p0, Lcom/gmhub/glass/GlassDrawable;->engine:I

    aget-boolean v2, v2, v3

    if-nez v2, :cond_ea

    invoke-virtual {p1}, Landroid/graphics/Canvas;->isHardwareAccelerated()Z

    move-result v2

    if-eqz v2, :cond_ea

    .line 190
    invoke-virtual {v0}, Landroid/graphics/Rect;->width()I

    move-result v2

    const/4 v3, 0x4

    if-lt v2, v3, :cond_ea

    invoke-virtual {v0}, Landroid/graphics/Rect;->height()I

    move-result v2

    if-lt v2, v3, :cond_ea

    .line 191
    invoke-virtual {v0}, Landroid/graphics/Rect;->width()I

    move-result v2

    int-to-long v2, v2

    invoke-virtual {v0}, Landroid/graphics/Rect;->height()I

    move-result v4

    int-to-long v4, v4

    mul-long/2addr v2, v4

    const-wide/32 v4, 0x400000

    cmp-long v2, v2, v4

    if-gtz v2, :cond_ea

    iget-object v2, p0, Lcom/gmhub/glass/GlassDrawable;->raw:Landroid/graphics/Bitmap;

    invoke-virtual {v2}, Landroid/graphics/Bitmap;->isRecycled()Z

    move-result v2

    if-eqz v2, :cond_72

    goto/16 :goto_ea

    .line 194
    :cond_72
    invoke-virtual {p1}, Landroid/graphics/Canvas;->save()I

    move-result v9

    .line 196
    :try_start_76
    iget v2, p0, Lcom/gmhub/glass/GlassDrawable;->width:I

    invoke-virtual {v0}, Landroid/graphics/Rect;->width()I

    move-result v3

    if-ne v2, v3, :cond_86

    iget v2, p0, Lcom/gmhub/glass/GlassDrawable;->height:I

    invoke-virtual {v0}, Landroid/graphics/Rect;->height()I

    move-result v3

    if-eq v2, v3, :cond_91

    :cond_86
    invoke-virtual {v0}, Landroid/graphics/Rect;->width()I

    move-result v2

    invoke-virtual {v0}, Landroid/graphics/Rect;->height()I

    move-result v3

    invoke-direct {p0, v2, v3}, Lcom/gmhub/glass/GlassDrawable;->configure(II)V

    .line 197
    :cond_91
    iget v2, v0, Landroid/graphics/Rect;->left:I

    int-to-float v2, v2

    iget v0, v0, Landroid/graphics/Rect;->top:I

    int-to-float v0, v0

    invoke-virtual {p1, v2, v0}, Landroid/graphics/Canvas;->translate(FF)V

    .line 198
    iget v0, p0, Lcom/gmhub/glass/GlassDrawable;->width:I

    int-to-float v4, v0

    iget v0, p0, Lcom/gmhub/glass/GlassDrawable;->height:I

    int-to-float v5, v0

    iget-object v6, p0, Lcom/gmhub/glass/GlassDrawable;->glass:Landroid/graphics/Paint;

    const/4 v2, 0x0

    const/4 v3, 0x0

    move-object v1, p1

    invoke-virtual/range {v1 .. v6}, Landroid/graphics/Canvas;->drawRect(FFFFLandroid/graphics/Paint;)V

    .line 199
    iget v0, p0, Lcom/gmhub/glass/GlassDrawable;->density:F

    const/high16 v1, 0x41e00000    # 28.0f

    mul-float/2addr v0, v1

    iget v1, p0, Lcom/gmhub/glass/GlassDrawable;->width:I

    iget v2, p0, Lcom/gmhub/glass/GlassDrawable;->height:I

    invoke-static {v1, v2}, Ljava/lang/Math;->min(II)I

    move-result v1

    int-to-float v1, v1

    const/high16 v2, 0x40000000    # 2.0f

    div-float/2addr v1, v2

    invoke-static {v0, v1}, Ljava/lang/Math;->min(FF)F

    move-result v6

    .line 200
    iget v0, p0, Lcom/gmhub/glass/GlassDrawable;->width:I

    int-to-float v4, v0

    iget v0, p0, Lcom/gmhub/glass/GlassDrawable;->height:I

    int-to-float v5, v0

    iget-object v8, p0, Lcom/gmhub/glass/GlassDrawable;->veil:Landroid/graphics/Paint;

    const/4 v2, 0x0

    const/4 v3, 0x0

    move v7, v6

    move-object v1, p1

    invoke-virtual/range {v1 .. v8}, Landroid/graphics/Canvas;->drawRoundRect(FFFFFFLandroid/graphics/Paint;)V
    :try_end_cc
    .catch Ljava/lang/RuntimeException; {:try_start_76 .. :try_end_cc} :catch_cf
    .catch Ljava/lang/LinkageError; {:try_start_76 .. :try_end_cc} :catch_cf
    .catch Ljava/lang/OutOfMemoryError; {:try_start_76 .. :try_end_cc} :catch_cf
    .catchall {:try_start_76 .. :try_end_cc} :catchall_cd

    goto :goto_d5

    :catchall_cd
    move-exception v0

    goto :goto_e6

    :catch_cf
    move-exception v0

    .line 202
    :try_start_d0
    iget v2, p0, Lcom/gmhub/glass/GlassDrawable;->engine:I

    invoke-static {v2, v0}, Lcom/gmhub/glass/GlassDrawable;->fail(ILjava/lang/Throwable;)V
    :try_end_d5
    .catchall {:try_start_d0 .. :try_end_d5} :catchall_cd

    .line 203
    :goto_d5
    invoke-virtual {p1, v9}, Landroid/graphics/Canvas;->restoreToCount(I)V

    .line 204
    sget-object v0, Lcom/gmhub/glass/GlassDrawable;->BROKEN:[Z

    iget v2, p0, Lcom/gmhub/glass/GlassDrawable;->engine:I

    aget-boolean v0, v0, v2

    if-eqz v0, :cond_e5

    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->fallback:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v0, p1}, Landroid/graphics/drawable/BitmapDrawable;->draw(Landroid/graphics/Canvas;)V

    :cond_e5
    :goto_e5
    return-void

    .line 203
    :goto_e6
    invoke-virtual {p1, v9}, Landroid/graphics/Canvas;->restoreToCount(I)V

    throw v0

    .line 192
    :cond_ea
    :goto_ea
    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->fallback:Landroid/graphics/drawable/BitmapDrawable;

    invoke-virtual {v0, p1}, Landroid/graphics/drawable/BitmapDrawable;->draw(Landroid/graphics/Canvas;)V

    return-void
.end method

.method public getOpacity()I
    .locals 0

    const/4 p0, -0x3

    return p0
.end method

.method public setAlpha(I)V
    .locals 2

    .line 208
    invoke-super {p0, p1}, Landroid/graphics/drawable/BitmapDrawable;->setAlpha(I)V

    .line 209
    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->fallback:Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v0, :cond_a

    invoke-virtual {v0, p1}, Landroid/graphics/drawable/BitmapDrawable;->setAlpha(I)V

    .line 210
    :cond_a
    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->glass:Landroid/graphics/Paint;

    if-eqz v0, :cond_11

    invoke-virtual {v0, p1}, Landroid/graphics/Paint;->setAlpha(I)V

    .line 211
    :cond_11
    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->veil:Landroid/graphics/Paint;

    if-eqz v0, :cond_21

    int-to-float p1, p1

    const v1, 0x3e4ccccd    # 0.2f

    mul-float/2addr p1, v1

    invoke-static {p1}, Ljava/lang/Math;->round(F)I

    move-result p1

    invoke-virtual {v0, p1}, Landroid/graphics/Paint;->setAlpha(I)V

    .line 212
    :cond_21
    invoke-virtual {p0}, Lcom/gmhub/glass/GlassDrawable;->invalidateSelf()V

    return-void
.end method

.method public setColorFilter(Landroid/graphics/ColorFilter;)V
    .locals 1

    .line 215
    invoke-super {p0, p1}, Landroid/graphics/drawable/BitmapDrawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 216
    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->fallback:Landroid/graphics/drawable/BitmapDrawable;

    if-eqz v0, :cond_a

    invoke-virtual {v0, p1}, Landroid/graphics/drawable/BitmapDrawable;->setColorFilter(Landroid/graphics/ColorFilter;)V

    .line 217
    :cond_a
    iget-object v0, p0, Lcom/gmhub/glass/GlassDrawable;->glass:Landroid/graphics/Paint;

    if-eqz v0, :cond_11

    invoke-virtual {v0, p1}, Landroid/graphics/Paint;->setColorFilter(Landroid/graphics/ColorFilter;)Landroid/graphics/ColorFilter;

    .line 218
    :cond_11
    invoke-virtual {p0}, Lcom/gmhub/glass/GlassDrawable;->invalidateSelf()V

    return-void
.end method
