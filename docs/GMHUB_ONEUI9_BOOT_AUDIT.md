# Auditoria cruzada — GM HUB One UI 9 / Galaxy S20 FE Exynos (r8s)
**Mantenedor:** GMNevz · **Kernel:** GMKernel · **Estado:** experimental, boot ainda não comprovado

## Matriz de origem (não confundir firmware, framework e vendor)
| Componente | Origem exata | Contrato / verificação |
|---|---|---|
| Framework + SystemUI + SecSettings | Samsung S24+ SM-S926B EUX `S926BXXSIEZJ1`, One UI 9, Android 17 | API 37, firmware Samsung publicado em 2026-10-26 |
| Vendor/hardware | Samsung SM-G780F AUT, Exynos 990 | Firmware original do S20 FE, `TARGET_PLATFORM_SDK_VERSION=33` (ramo do vendor legado API 30 não é o mesmo que versão do sistema doador) |
| Boot partition | SM-G780F PIT | 61.865.984 bytes (59 MiB), verificação antes de copiar `boot.img` |
| Kernel | `edugrepo1-jpg/android_kernel_samsung_exynos990` / `gmkernel-android17-r8s-20261101` | SHA `521d4e09a29288cc40afd2318be6ce52b3c5726f`, KSU Next Legacy, Charge Max V3 e alterações do usuário |
| DTBO | Gerado pelo GMKernel, não o Extreme | Revisões (custom0, custom1) = (0,1), (2,4), (5,255); `validate_gmkernel_dtbo.py` valida a tabela final |
| Tela | EA8079 / S6E3FC3 | 60/120 universal, 96 específico EA8079; nunca oferecer 48Hz ou WQHD como modo físico no GM HUB |
| Câmera | Mantém patches de câmera/vídeo da UN1CA + mods r8s | Confrontar IDs 2/50 com HAL ativo e Smali Android 17 antes de declarar funcional |
| Biometria | FOD óptico do r8s vs sensor ultrassônico do doador | Verificar `SystemUI.apk`, `BiometricSetting.apk` e `framework.jar` reais da EZJ1 |
| Graphics V6/V7 | API37 com vendor legado Exynos990 | Preservar SurfaceFlinger/libgui/libui do doador moderno, revisar SONAME e mapeamento linker |
| Brilho | Serviços Samsung e HAL legado | SehLights / VintfHalCache compatíveis apenas após validação das classes EZJ1 |
| Pure Black | Modificação de recursos escuros no SystemUI | Patch de compilação, não configurações com botão dinâmico; exige nomes de recursos reais EZJ1 |
| Multijanelas OneLab | `SemMultiWindowManager.setMultiWindowEnabled(String,boolean)` | Alterar apenas pedido SSRM de fechamento, sem desligar proteções térmicas |

## Verificações de boot que o código já consegue fazer
1. `test_gmhub_oneui9_contracts.py`: firmware fixado, API, 59MiB, GMKernel exato, workflow sem release inadvertida.
2. `test_r8s_gm_hub.py` e `test_r8s_ui_features.py`: fragmentos Smali importados, XML e recursos, Pure Black e proteção SSRM em amostras.
3. `verify_gmkernel_android17.sh`: interfaces `memory_recursiveprot`, `cgroup.kill`, `CAP_PERFMON`, `CAP_BPF`, `CAP_CHECKPOINT_RESTORE` já existentes no GMKernel — não reaplicar os patches do Extreme.
4. `platform/exynos990/patches/extremekrnl/customize.sh`: recusa SHA incorreto, produz novas imagens e confere que `boot.img` contém o Image da build.
5. GitHub Actions: um trigger isolado `.github/gmhub-build-trigger.txt` iniciou o build real `41332367125`, exclusivamente em modo de compilação.
6. Build unofficial utiliza certificados AOSP presentes em `security/`; não depende dos certificados privados da UN1CA.
7. GitHub Actions de teste completo, se bem-sucedido, preservará ZIP e imagens como artefatos internos, **não publicará OTA nem release estável**.

## Bloqueios que só a build real ou aparelho pode resolver
- Download real do firmware Samsung por FUS (`S926BXXSIEZJ1/S926BOXMIEZJ1/S926BXXSIEZJ1`) e sua extração.
- Build das ferramentas, GMKernel/KSU e framework APK/JAR — CI de fonte não prova binários funcionais.
- Adaptação das classes Smali One UI9 **API37**: não presumir compatibilidade apenas por vir da mesma linha S24+.
- Kernel/DTBO/AVB/ramdisk, recovery e sequência de inicialização; não confundir ZIP compilado com boot confirmado.
- Testes físicos com SM-G780F: FOD, display, câmeras, vídeo, LTE, Wi-Fi, áudio, brilho, temperatura, Charge Max e segurança.
- Banner personalizado: referência enviada pelo usuário exige resource `gmhub` real sem cortes, margens ou molduras; não referenciar um drawable inexistente em XML.

## Segurança de entrega
- Não fazer merge automático em `sixteen` ou `seventeen` sem resultados.
- Não enviar release OTA antes de confirmar boot e recuperação.
- Para a primeira instalação exigir backup e procedimento de recuperação, preservando EFS/NV, modem e partições de serviço.
- Charge Max V3 inclui alterações de corrente e temperatura no kernel do usuário; não há prova de carregamento seguro no aparelho sem ensaios físicos.

**PR:** https://github.com/edugrepo1-jpg/UN1CA_y2slte/pull/2
**Execução de build:** https://github.com/edugrepo1-jpg/UN1CA_y2slte/actions/runs/41332367125


## Resultado real do build 41332867681 / correção da compatibilidade EZJ1

**Comprovado no GitHub Actions:** download e extração do firmware, dependências, compilação GMKernel com KernelSU Next Legacy v3.4.0-legacy, verificação da Image empacotada e dos seletores do dtbo.img. O processo avançou até os patches de dispositivo e falhou ao aplicar Pure Black ao `SystemUI.apk`, pois o recurso `sec_qs_background` existia como pressuposto do Android 16, mas não na mesma tabela de recursos da One UI 9.

**Adaptação implementada:** o algoritmo de Pure Black não depende mais exclusivamente desse nome; procura alvos semanticamente identificados nas variantes `values-night*`, `color-night*` e `drawable-night*` e cria substituições apenas para o modo escuro quando encontra backgrounds seguros em variantes de base. Preserva o tema diurno, os textos, os scrims semitransparentes e verifica duplicidade de recursos com o mesmo qualifier; registra a lista extraída em `out/gmhub-oneui9-pure-black-resources.txt` (ou na pasta de output correspondente). Se o layout real do doador não corresponder, para com diagnóstico em vez de declarar uma falsa correção.

**Otimização QSAnimView:** se o Android 17 já removeu a chamada de diagnóstico pesada, o script não injeta Smali incompatível; registra que não há um recurso legado a otimizar.

**Nova execução completa sem publicação:** https://github.com/edugrepo1-jpg/UN1CA_y2slte/actions/runs/41340161531

**Não confirmado:** conclusão dessa execução, rebuild final de APK/JAR, Pure Black funcionando no aparelho, digital, câmera, conectividade, Charging Max, GM HUB e boot físico. O banner personalizado ainda aguarda inclusão real do arquivo de imagem no repositório; não usar referência XML a um asset ausente.
