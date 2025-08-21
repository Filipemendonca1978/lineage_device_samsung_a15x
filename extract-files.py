#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/samsung/a15x',
    'hardware/samsung',
    'hardware/mediatek',
    'hardware/mediatek/libmtkperf_client',
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}_{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    'libhyper': lib_fixup_vendor_suffix,
    'libuuid': lib_fixup_vendor_suffix,
}

blob_fixups: blob_fixups_user_type = {
    ('vendor/lib64/libcodec2_vpp_AIMEMC_plugin.so', 'vendor/lib64/libcodec2_vpp_AISR_plugin.so'): blob_fixup()
        .replace_needed('android.hardware.graphics.common-V3-ndk.so', 'android.hardware.graphics.common-V6-ndk.so')
        .replace_needed('android.hardware.graphics.allocator-V1-ndk.so', 'android.hardware.graphics.allocator-V2-ndk.so'),

    ('vendor/lib/vendor.mediatek.hardware.pq_aidl-V1-ndk.so', 'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V1-ndk.so'): blob_fixup()
        .replace_needed('android.hardware.graphics.common-V3-ndk.so', 'android.hardware.graphics.common-V6-ndk.so'),

    ('vendor/bin/tzdaemon', 'vendor/bin/tzts_daemon'): blob_fixup()
        .replace_needed('libuuid.so', 'libuuid_vendor.so'),

    'vendor/bin/hw/vendor.samsung.hardware.hyper-service': blob_fixup()
        .replace_needed('libhyper.so', 'libhyper_vendor.so'),

    ('vendor/lib/vendor.mediatek.hardware.bluetooth.audio-V1-ndk.so', 'vendor/lib64/vendor.mediatek.hardware.bluetooth.audio-V1-ndk.so',
     'vendor/lib/vendor.samsung.hardware.bluetooth.audio-V1-ndk.so', 'vendor/lib64/vendor.samsung.hardware.bluetooth.audio-V1-ndk.so'): blob_fixup()
        .replace_needed('android.hardware.audio.common-V1-ndk.so', 'android.hardware.audio.common-V4-ndk.so'),

    ('vendor/lib/lib3a.ae.stat.so', 'vendor/lib64/lib3a.ae.stat.so'): blob_fixup()
        .add_needed('liblog.so'),

    ('vendor/lib/unihal_android.so', 'vendor/lib64/unihal_android.so'): blob_fixup()
        .add_needed('libui_shim.so'),

    ('vendor/lib/libneuralnetworks_sl_driver_mtk_prebuilt.so', 'vendor/lib64/libneuralnetworks_sl_driver_mtk_prebuilt.so'): blob_fixup()
        .add_needed('libbase_shim.so')
        .patchelf_version('0_18')
        .clear_symbol_version('AHardwareBuffer_allocate')
        .clear_symbol_version('AHardwareBuffer_createFromHandle')
        .clear_symbol_version('AHardwareBuffer_describe')
        .clear_symbol_version('AHardwareBuffer_getNativeHandle')
        .clear_symbol_version('AHardwareBuffer_lock')
        .clear_symbol_version('AHardwareBuffer_release')
        .clear_symbol_version('AHardwareBuffer_unlock'),

    ('vendor/lib/libh264enc_sa.ca7.so', 'vendor/lib/libmp4enc_sa.ca7.so', 'vendor/lib/libmp4enc_xa.ca7.so',
     'vendor/lib/libvp8dec_sa.ca7.so', 'vendor/lib/libvp9dec_sa.ca7.so'): blob_fixup()
        .patchelf_version('0_18')
        .clear_symbol_version('__aeabi_memcpy')
        .clear_symbol_version('__aeabi_memset')
        .clear_symbol_version('__gnu_Unwind_Find_exidx')
        .add_needed('libshim_idiv0.so'),

    ('vendor/lib/libnvram.so', 'vendor/lib64/libnvram.so', 'vendor/lib/libtflite_mtk.so', 'vendor/lib64/libtflite_mtk.so',
     'vendor/bin/hw/android.hardware.neuralnetworks-shim-service-mtk', 'vendor/bin/hw/android.hardware.neuralnetworks-shim-service-mtk-lazy',
     'vendor/bin/hw/vendor.samsung.hardware.health-service', 'vendor/lib64/nfc_nci_nxpsn.so'): blob_fixup()
        .add_needed('libbase_shim.so'),

    ('vendor/lib/libFace_Landmark_API.camera.samsung.so', 'vendor/lib/libHpr_RecGAE_cvFeature_v1.0.camera.samsung.so',
     'vendor/lib/libSQLiteModule_VER_ALL.so', 'vendor/lib/lib_SamsungRec_07010.so', 'vendor/lib/lib_SoundAlive_play_plus_ver600.so',
     'vendor/lib/lib_SoundBooster_ver2000.so', 'vendor/lib/libegis_fp_normal_sensor_test.so', 'vendor/lib/libmvpuop_mtk_cv.so',
     'vendor/lib/libmvpuop_mtk_nn.so', 'vendor/lib/lib3a.ae.so', 'vendor/lib/lib3a.awb.core.so',
     'vendor/lib/libHEVCdec_sa.ca7.android.so', 'vendor/lib/libfocuspeaking.so', 'vendor/lib/libh264dec_sa.ca7.so',
     'vendor/lib/libh264dec_sd.ca7.so', 'vendor/lib/libh264dec_se.ca7.so', 'vendor/lib/libsynaFpSensorTestNwd.so',
     'vendor/lib/libvp8enc_sa.ca7.so'): blob_fixup()
        .add_needed('libshim_idiv0.so'),

    ('vendor/lib/libthha.so', 'vendor/lib/libvcodec_oal.so'): blob_fixup()
        .patchelf_version('0_18')
        .clear_symbol_version('__aeabi_memcpy')
        .clear_symbol_version('__aeabi_memset')
        .clear_symbol_version('__gnu_Unwind_Find_exidx'),

    ('vendor/lib/libSecC2ComponentStore.so', 'vendor/lib64/libSecC2ComponentStore.so'): blob_fixup()
        .add_needed('libshim_c2.so'),

    (
    'vendor/bin/hw/android.hardware.security.keymint-service.mtk',
    'vendor/lib64/libskeymint10device.so',
    'vendor/lib64/libskeymint_cli.so'
    ): blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-tm.so')
        .add_needed('libshim_crypto.so')
        .add_needed('android.hardware.security.rkp-V3-ndk.so'),

    'vendor/etc/init/android.hardware.security.keymint-service-mtk.rc': blob_fixup()
        .regex_replace('android.hardware.security.keymint-service', 'android.hardware.security.keymint-service.mtk'),

    ('vendor/lib/vendor.samsung.hardware.camera.device@5.0-impl.so', 'vendor/lib64/vendor.samsung.hardware.camera.device@5.0-impl.so'): blob_fixup()
        .add_needed('libshim_camera.so'),

    'vendor/lib64/libril_sem.so': blob_fixup()
        .replace_needed('vendor.samsung.hardware.radio.network-V1-ndk.so', 'vendor.samsung.hardware.radio.network-V1-ndk-vendor.so'),

    'vendor/bin/aee_aedv64_v2': blob_fixup()
        .add_needed('aedv64_shim.so'),

    'vendor/lib64/hw/hwcomposer.mtk_common.so': blob_fixup()
        .add_needed('libprocessgroup_shim.so'),
}  # fmt: skip

module = ExtractUtilsModule(
    'a15x',
    'samsung',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
