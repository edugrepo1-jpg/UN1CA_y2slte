# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# SEC Floating Feature configuration file for Galaxy S20FE (Exynos) (r8s)

# Enable AOD live clock
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM=activeclock=7,aodversion=7,clocktransition,coverboldfont

# Set default HFR Refresh Rate
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE=120

# Enable seamless refresh rate feature
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2

# EA8079 supports the pinned GM kernel's calibrated 96-Hz mode.
# S6E3FC3 remains restricted to its 60/120-Hz panel table.
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE=60,96,120

# Enable extra brightness feature
SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE
