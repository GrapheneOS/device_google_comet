#
# Copyright (C) 2020 The Android Open-Source Project
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
ifeq (,$(filter %comet23,$(PRODUCT_NAME)))

TARGET_BOARD_INFO_FILE := device/google/comet/board-info.txt
TARGET_BOOTLOADER_BOARD_NAME := comet
TARGET_SCREEN_DENSITY := 390
BOARD_USES_GENERIC_AUDIO := true
USES_DEVICE_GOOGLE_COMET := true

#Display
USES_IDISPLAY_INTF_SEC := true

include device/google/zumapro/BoardConfig-common.mk
-include vendor/google_devices/zumapro/prebuilts/BoardConfigVendor.mk
-include vendor/google_devices/comet/proprietary/BoardConfigVendor.mk
include device/google/comet-sepolicy/comet-sepolicy.mk
include device/google/comet/wifi/BoardConfig-wifi.mk

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
-include device/google/common/etm/6_1/BoardUserdebugModules.mk
endif

else

include device/google/comet23/comet23/BoardConfig.mk

endif
