#
# Copyright (C) 2021 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

SHIPPING_API_LEVEL := 34

ifdef RELEASE_GOOGLE_COMET_RADIO_DIR
RELEASE_GOOGLE_PRODUCT_RADIO_DIR := $(RELEASE_GOOGLE_COMET_RADIO_DIR)
endif
ifdef RELEASE_GOOGLE_COMET_RADIOCFG_DIR
RELEASE_GOOGLE_PRODUCT_RADIOCFG_DIR := $(RELEASE_GOOGLE_COMET_RADIOCFG_DIR)
endif
RELEASE_GOOGLE_BOOTLOADER_COMET_DIR ?= 24D1# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_COMET_DIR)
$(call soong_config_set,comet_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_COMET_DIR))

ifdef RELEASE_KERNEL_COMET_VERSION
TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_COMET_VERSION)
else
TARGET_LINUX_KERNEL_VERSION ?= 6.1
endif

ifdef RELEASE_KERNEL_COMET_DIR
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_COMET_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_COMET_DIR)/kernel-headers
else
TARGET_KERNEL_DIR ?= device/google/comet-kernels/6.1/24D1
TARGET_BOARD_KERNEL_HEADERS ?= device/google/comet-kernels/6.1/24D1/kernel-headers
endif

TARGET_RECOVERY_DEFAULT_ROTATION := ROTATION_RIGHT

LOCAL_PATH := device/google/comet

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
    USE_UWBFIELDTESTQM := true
endif

$(call inherit-product-if-exists, vendor/google_devices/comet/prebuilts/device-vendor-comet.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zumapro/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/comet/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/comet/proprietary/comet/device-vendor-comet.mk)
$(call inherit-product-if-exists, vendor/qorvo/uwb/qm35-hal/Device.mk)

ifeq ($(filter factory_comet, $(TARGET_PRODUCT)),)
    $(call inherit-product-if-exists, vendor/google_devices/comet/proprietary/WallpapersComet.mk)
endif

DEVICE_PACKAGE_OVERLAYS += device/google/comet/comet/overlay

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/comet/audio/comet/audio-tables.mk
include device/google/zumapro/device-shipping-common.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/gti/predump_gti_dual.mk
include device/google/gs-common/display/dump_second_display.mk
include device/google/gs-common/gril/hidl/1.7/gril_hidl.mk

# Increment the SVN for any official public releases
ifdef RELEASE_SVN_COMET
TARGET_SVN ?= $(RELEASE_SVN_COMET)
else
# Set this for older releases that don't use build flag
TARGET_SVN ?= 04
endif

PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.build.svn=$(TARGET_SVN)

# Set device family property for SMR
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device_family=CT3

# Set build properties for SMR builds
ifeq ($(RELEASE_IS_SMR), true)
    ifneq (,$(RELEASE_BASE_OS_COMET))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_COMET)
    endif
endif

# Set build properties for EMR builds
ifeq ($(RELEASE_IS_EMR), true)
    ifneq (,$(RELEASE_BASE_OS_COMET))
        PRODUCT_PROPERTY_OVERRIDES += \
        ro.build.version.emergency_base_os=$(RELEASE_BASE_OS_COMET)
    endif
endif

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,comet)
$(call soong_config_set,lyric,tuning_product,comet)
$(call soong_config_set,google3a_config,target_device,comet)

# Init files
PRODUCT_COPY_FILES += \
	device/google/comet/conf/init.comet.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.comet.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/comet/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.comet.rc

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st \
	NfcOverlayComet

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \

#Thermal VT estimator
PRODUCT_PACKAGES += \
    libthermal_tflite_wrapper

PRODUCT_PACKAGES += \
	init_thermal_config

# Bluetooth hci_inject test tool
PRODUCT_PACKAGES_DEBUG += \
    hci_inject

# Bluetooth SAR test tool
PRODUCT_PACKAGES_DEBUG += \
    sar_test

# Bluetooth EWP test tool
PRODUCT_PACKAGES_DEBUG += \
    ewp_tool

# Override BQR mask to enable LE Audio Choppy report, remove BTRT logging
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.bqr.event_mask=295006 \
    persist.bluetooth.bqr.vnd_quality_mask=29 \
    persist.bluetooth.bqr.vnd_trace_mask=0 \
    persist.bluetooth.vendor.btsnoop=true
endif

# Spatial Audio
PRODUCT_PACKAGES += \
	libspatialaudio \
	librondo

ifneq ($(USE_AUDIO_HAL_AIDL),true)
# HIDL Sound Dose
PRODUCT_PACKAGES += \
	android.hardware.audio.sounddose-vendor-impl \
	audio_sounddose_aoc
endif

PRODUCT_PACKAGES += \
    libspeechenhancer

# UWB Overlay
PRODUCT_PACKAGES += \
	UwbOverlayCT3

# WiFi Overlay
PRODUCT_PACKAGES += \
	WifiOverlay2024Mid_CT3 \
	PixelWifiOverlay2024

# GRil Overlay
PRODUCT_PACKAGES += \
	GRilServiceOverlay_CT3

# Settings Overlay
PRODUCT_PACKAGES += \
    SettingsCometOverlay

# Graphics
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += debug.sf.set_idle_timer_ms_4619827677550801152=80
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += debug.sf.support_kernel_idle_timer_4619827677550801152=true
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += debug.sf.set_idle_timer_ms_4619827677550801153=1000
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += debug.sf.support_kernel_idle_timer_4619827677550801153=false

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/comet/prebuilts

# UWB
PRODUCT_SOONG_NAMESPACES += \
    device/google/comet/uwb

# Location
PRODUCT_SOONG_NAMESPACES += device/google/comet/location
$(call soong_config_set, gpssdk, buildtype, $(TARGET_BUILD_VARIANT))
PRODUCT_PACKAGES += gps.cfg

# Install product specific framework compatibility matrix
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += device/google/comet/device_framework_matrix_product.xml

# Haptics
# Placeholders for updates later, need to update:
# remove ro.vendor.vibrator.hal.dbc.enable (needed for setting pm.activetimeout)
# remove pm.activetimeout
# ro.vendor.vibrator.hal.loc.coeff.folded currently unused
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ACTUATOR_MODEL := luxshare_ict_081545
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.vibrator.hal.chirp.enabled=1 \
    ro.vendor.vibrator.hal.device.mass=0.2605 \
    ro.vendor.vibrator.hal.loc.coeff.folded=3.15 \
    ro.vendor.vibrator.hal.loc.coeff=2.58 \
    ro.vendor.vibrator.hal.dbc.enable=1 \
    ro.vendor.vibrator.hal.pm.activetimeout=5 \
    persist.vendor.vibrator.hal.context.enable=false \
    persist.vendor.vibrator.hal.context.scale=60 \
    persist.vendor.vibrator.hal.context.fade=true \
    persist.vendor.vibrator.hal.context.cooldowntime=1600 \
    persist.vendor.vibrator.hal.context.settlingtime=5000

# Override Output Distortion Gain
PRODUCT_VENDOR_PROPERTIES += \
    vendor.audio.hapticgenerator.distortion.output.gain=0.45

# Hinge angle sensor
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.sensor.hinge_angle.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hinge_angle.xml

# Keyboard height ratio and bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += \
          ro.com.google.ime.kb_pad_port_b=11.2 \
          ro.com.google.ime.height_ratio=1.18


# Bluetooth LE Audio
# Unicast
PRODUCT_PRODUCT_PROPERTIES += \
        bluetooth.profile.bap.unicast.client.enabled=true \
        bluetooth.profile.csip.set_coordinator.enabled=true \
        bluetooth.profile.hap.client.enabled=true \
        bluetooth.profile.mcp.server.enabled=true \
        bluetooth.profile.ccp.server.enabled=true \
        bluetooth.profile.vcp.controller.enabled=true

# Bluetooth LE Audio Broadcast
PRODUCT_PRODUCT_PROPERTIES += \
	bluetooth.profile.bap.broadcast.assist.enabled=true \
	bluetooth.profile.bap.broadcast.source.enabled=true

# LE Audio switcher in developer options
PRODUCT_PRODUCT_PROPERTIES += \
        ro.bluetooth.leaudio_switcher.supported=true \

# Enable hardware offloading
PRODUCT_PRODUCT_PROPERTIES += \
        ro.bluetooth.leaudio_offload.supported=true \
        persist.bluetooth.leaudio_offload.disabled=false

# Bluetooth LE Audio CIS handover to SCO
# Set the property only for the controller couldn't support CIS/SCO simultaneously. More detailed in
# b/242908683.
PRODUCT_PRODUCT_PROPERTIES += \
        persist.bluetooth.leaudio.notify.idle.during.call=true

# Disable LE Audio dual mic SWB call support
# This may depend on the BT controller capability or the launch strategy
# For example, P22 BT chip is not able to support 32k dual mic
# P23a disabled the 32k dual mic as it is not in the phase 2 launch plan
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.leaudio.dual_bidirection_swb.supported=true

# LE Audio Unicast Allowlist
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.leaudio.allow_list=SM-R510,WF-1000XM5,SM-R630

SUPPORT_VENDOR_SATELLITE_SERVICE := true

# Support NTN(satellite) with dual SIM
NTN_DUAL_SIM := true

# Telephony Satellite Feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.satellite.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/permissions/android.hardware.telephony.satellite.xml

# Exynos RIL and telephony
# Support RIL Domain-selection
SUPPORT_RIL_DOMAIN_SELECTION := true

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

# Connectivity Resources Overlay for Thread host settings
PRODUCT_PACKAGES += \
    ConnectivityResourcesOverlayCometOverride

# Thread Dispatcher enablement in Bluetooth HAL
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.thread_dispatcher.enabled=false

# Camera concurrent foldable dual front feature support
PRODUCT_PACKAGES += \
    concurrent_foldable_dual_front_xml

# Bluetooth device id
# Comet: 0x4113
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.device_id.product_id=16659

# Set support for LEA multicodec
PRODUCT_PRODUCT_PROPERTIES +=\
    bluetooth.core.le_audio.codec_extension_aidl.enabled=true

# Enable APF by default
PRODUCT_VENDOR_PROPERTIES += \
    vendor.powerhal.apf_disabled=false \
    vendor.powerhal.apf_enabled=true
