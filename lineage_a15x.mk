#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from a15x device
$(call inherit-product, device/samsung/a15x/device.mk)

PRODUCT_DEVICE := a15x
PRODUCT_NAME := lineage_a15x
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A156M
PRODUCT_MANUFACTURER := samsung

PRODUCT_GMS_CLIENTID_BASE := android-samsung-ss

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a15xub-user 15 AP3A.240905.015.A2 A156MUBS6CYF2 release-keys"

BUILD_FINGERPRINT := samsung/a15xub/a15x:15/AP3A.240905.015.A2/A156MUBS6CYF2:user/release-keys
