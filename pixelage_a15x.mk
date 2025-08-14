#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Pixelage stuff.
$(call inherit-product, vendor/pixelage/config/common_full_phone.mk)

# Inherit from a15x device
$(call inherit-product, device/samsung/a15x/device.mk)

TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_DEVICE := a15x
PRODUCT_NAME := pixelage_a15x
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-A156M
PRODUCT_MANUFACTURER := samsung

# Pixelage
PIXELAGE_BUILD := a15x
PIXELAGE_MAINTAINER := Flopster101
TARGET_FACE_UNLOCK_SUPPORTED := true
TARGET_SUPPORTS_QUICK_TAP := true

PRODUCT_GMS_CLIENTID_BASE := android-samsung-ss

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a15xub-user 15 AP3A.240905.015.A2 A156MUBS6CYF2 release-keys"

BUILD_FINGERPRINT := samsung/a15xub/a15x:15/AP3A.240905.015.A2/A156MUBS6CYF2:user/release-keys
