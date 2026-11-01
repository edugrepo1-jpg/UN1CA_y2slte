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
