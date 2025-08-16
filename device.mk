#
# Copyright (C) 2025 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# API levels
PRODUCT_SHIPPING_API_LEVEL := 34

# Audio HAL
PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.0-impl \
    android.hardware.audio.effect@7.0-impl \
    audio.primary.default \
    audio.r_submix.default \
    audio.usb.default

# Audio libraries  
PRODUCT_PACKAGES += \
    libaudiofoundation \
    libaudioclient_aidl_conversion \
    audioclient-types-aidl-cpp \
    framework-permission-aidl-cpp \
    shared-file-region-aidl-cpp

# Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider-service.samsung
    
# fastbootd
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.1-impl-mock \
    fastbootd

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Product characteristics
PRODUCT_CHARACTERISTICS := phone

# Rootdir
PRODUCT_PACKAGES += \
    init.insmod.sh \
    install-recovery.sh \

PRODUCT_PACKAGES += \
    fstab.emmc \
    factory_init.connectivity.common.rc \
    factory_init.connectivity.rc \
    factory_init.project.rc \
    factory_init.rc \
    init.aee.rc \
    init.audio.samsung.rc \
    init.cgroup.rc \
    init.connectivity.common.rc \
    init.connectivity.rc \
    init.modem.rc \
    init.mt6835.rc \
    init.mt6835.usb.rc \
    init.mtkgki.rc \
    init.project.rc \
    init.sec.rc \
    init_connectivity.rc \
    meta_init.connectivity.common.rc \
    meta_init.connectivity.rc \
    meta_init.modem.rc \
    meta_init.project.rc \
    meta_init.rc \
    meta_init.vendor.rc \
    multi_init.rc \
    init.recovery.mt6835.rc \
    init.recovery.samsung.rc \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.emmc:$(TARGET_COPY_OUT_RAMDISK)/fstab.emmc

# RIL
PRODUCT_PACKAGES += \
    secril_config_svc

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/samsung

# Inherit the proprietary files
$(call inherit-product, vendor/samsung/a15x/a15x-vendor.mk)
