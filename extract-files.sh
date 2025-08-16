#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=a15x
VENDOR=samsung

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        vendor/lib*/*codec2_vpp_A*)
            echo "Found VPP plugin: ${1}. Patching dependencies..."
            "${PATCHELF}" --replace-needed "android.hardware.graphics.common-V3-ndk.so" "android.hardware.graphics.common-V6-ndk.so" "${2}"
            "${PATCHELF}" --replace-needed "android.hardware.graphics.allocator-V1-ndk.so" "android.hardware.graphics.allocator-V2-ndk.so" "${2}"
            ;;

        vendor/lib*/vendor.mediatek.hardware.pq_aidl-V1-ndk.so)
            echo "Patching ${1} for graphics.common AIDL version"
            "${PATCHELF}" --replace-needed "android.hardware.graphics.common-V3-ndk.so" "android.hardware.graphics.common-V6-ndk.so" "${2}"
            ;;

        vendor/bin/tzdaemon|vendor/bin/tzts_daemon)
            echo "Patching ${1} to use libuuid_vendor.so"
            "${PATCHELF}" --replace-needed "libuuid.so" "libuuid_vendor.so" "${2}"
            ;;

        vendor/bin/hw/vendor.samsung.hardware.hyper-service)
            echo "Patching ${1} to use libhyper_vendor.so"
            "${PATCHELF}" --replace-needed "libhyper.so" "libhyper_vendor.so" "${2}"
            ;;

        vendor/lib*/vendor.mediatek.hardware.bluetooth.audio-V1-ndk.so | vendor/lib*/vendor.samsung.hardware.bluetooth.audio-V1-ndk.so)
            echo "Patching ${1} to use modern audio.common AIDL"
            "${PATCHELF}" --replace-needed "android.hardware.audio.common-V1-ndk.so" "android.hardware.audio.common-V4-ndk.so" "${2}"
            ;;

        vendor/lib*/lib3a.ae.stat.so)
            echo "Patching ${1} to add missing liblog dependency"
            "${PATCHELF}" --add-needed "liblog.so" "${2}"
            ;;

        vendor/lib*/unihal_android.so)
            echo "Shim: Patching ${1} with libui_shim"
            "${PATCHELF}" --add-needed "libui_shim.so" "${2}"
            ;;

        vendor/bin/factory)
            echo "Patching ${1} for libminui and libbase_shim"
            "${PATCHELF}" --replace-needed "libminiui.so" "libminui.so" "${2}"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;

        vendor/lib*/libneuralnetworks_sl_driver_mtk_prebuilt.so)
            echo "Shim: Patching ${1} with libbase_shim"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            echo "ABI Patch: clearing symbols for ${1}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_allocate" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_createFromHandle" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_describe" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_getNativeHandle" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_lock" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_release" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "AHardwareBuffer_unlock" "${2}"
            ;;

        vendor/lib/libh264enc_sa.ca7.so|vendor/lib/libmp4enc_sa.ca7.so|vendor/lib/libmp4enc_xa.ca7.so|vendor/lib/libvp8dec_sa.ca7.so|vendor/lib/libvp9dec_sa.ca7.so)
            echo "ABI Patch: clearing symbols for ${1}"
            "${PATCHELF_0_18}" --clear-symbol-version "__aeabi_memcpy" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "__aeabi_memset" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "__gnu_Unwind_Find_exidx" "${2}"
            echo "Shim: Adding idiv0 shim to ${1}"
            "${PATCHELF}" --add-needed "libshim_idiv0.so" "${2}"
            ;;

        vendor/lib*/libnvram.so|vendor/lib*/libtflite_mtk.so|vendor/bin/hw/android.hardware.neuralnetworks-shim-service-mtk|vendor/bin/hw/android.hardware.neuralnetworks-shim-service-mtk-lazy|vendor/bin/hw/vendor.samsung.hardware.health-service|vendor/lib64/nfc_nci_nxpsn.so)
            echo "Shim: Patching ${1} with libbase_shim"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;

        vendor/lib/libFace_Landmark_API.camera.samsung.so|vendor/lib/libHpr_RecGAE_cvFeature_v1.0.camera.samsung.so|vendor/lib/libSQLiteModule_VER_ALL.so|vendor/lib/lib_SamsungRec_07010.so|vendor/lib/lib_SoundAlive_play_plus_ver600.so|vendor/lib/lib_SoundBooster_ver2000.so|vendor/lib/libegis_fp_normal_sensor_test.so|vendor/lib/libmvpuop_mtk_cv.so|vendor/lib/libmvpuop_mtk_nn.so|vendor/lib/lib3a.ae.so|vendor/lib/lib3a.awb.core.so|vendor/lib/libHEVCdec_sa.ca7.android.so|vendor/lib/libfocuspeaking.so|vendor/lib/libh264dec_sa.ca7.so|vendor/lib/libh264dec_sd.ca7.so|vendor/lib/libh264dec_se.ca7.so|vendor/lib/libsynaFpSensorTestNwd.so|vendor/lib/libvp8enc_sa.ca7.so)
            echo "Shim: Patching ${1} with libshim_idiv0"
            "${PATCHELF}" --add-needed "libshim_idiv0.so" "${2}"
            ;;

        vendor/lib/libthha.so|vendor/lib/libvcodec_oal.so)
            echo "ABI Patch: Clearing private symbol versions in ${1}"
            "${PATCHELF_0_18}" --clear-symbol-version "__aeabi_memcpy" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "__aeabi_memset" "${2}"
            "${PATCHELF_0_18}" --clear-symbol-version "__gnu_Unwind_Find_exidx" "${2}"
            ;;

        vendor/lib*/libSecC2ComponentStore.so)
            echo "Shim: Patching ${1} with libshim_c2"
            "${PATCHELF}" --add-needed "libshim_c2.so" "${2}"
            ;;

        vendor/lib*/libskeymint10device.so|vendor/lib*/libskeymint_cli.so)
            echo "Shim: Patching ${1} for libcrypto ABI break"
            "${PATCHELF}" --replace-needed "libcrypto.so" "libcrypto-tm.so" "${2}"
            "${PATCHELF}" --add-needed "libshim_crypto.so" "${2}"
            ;;

        vendor/lib64/libril_sem.so)
            echo "Patching ${1} to use vendor.samsung.hardware.radio.network-V1-ndk-vendor"
            "${PATCHELF}" --replace-needed "vendor.samsung.hardware.radio.network-V1-ndk.so" "vendor.samsung.hardware.radio.network-V1-ndk-vendor.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
