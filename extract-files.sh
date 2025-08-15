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
        vendor/lib*/android.hardware.bluetooth.audio-impl.so)
            echo "Patching ${1} for BT audio AIDL version"
            "${PATCHELF}" --replace-needed "android.hardware.bluetooth.audio-V2-ndk.so" "android.hardware.bluetooth.audio-V5-ndk.so" "${2}"
            ;;

        vendor/lib*/vendor.mediatek.hardware.pq_aidl-V1-ndk.so)
            echo "Patching ${1} for graphics.common AIDL version"
            "${PATCHELF}" --replace-needed "android.hardware.graphics.common-V3-ndk.so" "android.hardware.graphics.common-V6-ndk.so" "${2}"
            ;;

        vendor/lib*/*codec2_vpp_A*)
            echo "Found VPP plugin: ${1}. Patching dependencies..."
            "${PATCHELF}" --replace-needed "android.hardware.graphics.common-V3-ndk.so" "android.hardware.graphics.common-V6-ndk.so" "${2}"
            "${PATCHELF}" --replace-needed "android.hardware.graphics.allocator-V1-ndk.so" "android.hardware.graphics.allocator-V2-ndk.so" "${2}"
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

        vendor/lib*/libneuralnetworks_sl_driver_mtk_prebuilt.so|vendor/lib*/libnvram.so|vendor/lib*/libtflite_mtk.so|vendor/bin/factory|vendor/bin/hw/android.hardware.neuralnetworks-shim-service-mtk|vendor/bin/hw/android.hardware.neuralnetworks-shim-service-mtk-lazy|vendor/bin/hw/vendor.samsung.hardware.health-service|vendor/lib64/nfc_nci_nxpsn.so)
            echo "Shim: Patching ${1} with libbase_shim"
            "${PATCHELF}" --add-needed "libbase_shim.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
