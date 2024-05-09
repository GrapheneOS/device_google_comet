/*
 * Copyright (C) 2023 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <android-base/logging.h>
#include <android-base/properties.h>

#include <string>

namespace {
constexpr std::string_view  kWingBoardHwId("0x00060603000100020000000000000000");
using android::base::GetProperty;
bool useThermalWingBoardConfig() {
  const auto cdt_hwid = GetProperty("ro.boot.cdt_hwid", "");
  if (cdt_hwid == kWingBoardHwId) {
    LOG(INFO) << "Using wingboard thermal config as found cdt_hwid " << cdt_hwid;
    return true;
  }
  return false;
}

bool useThermalBackupConfig() {
    const auto panel_drv = GetProperty("ro.boot.primary_panel_drv", "");
    const auto is_panel_available = (panel_drv.find("panel-google-ct3a") != std::string::npos) ||
                                    (panel_drv.find("panel-google-ct3b") != std::string::npos);
    if (!is_panel_available) {
        LOG(INFO) << "Using backup thermal config as unknown panel [" << panel_drv << "] found.";
        return true;
    }
    const auto hardware_revision = GetProperty("ro.boot.hardware.revision", "");
    if (hardware_revision == "PROTO1.0" || hardware_revision == "PROTO1.1") {
        LOG(INFO) << "Using backup thermal config as hardware revision [" << hardware_revision
                  << "] found.";
        return true;
    }
    return false;
}
}  // namespace

int main() {
    if (useThermalWingBoardConfig()) {
        if (!android::base::SetProperty("vendor.thermal.config",
                                        "thermal_info_config_wingboard.json")) {
            LOG(FATAL) << "Failed to set property vendor.thermal.config to "
                          "thermal_info_config_wingboard.";
        }
    } else if (useThermalBackupConfig()) {
        if (!android::base::SetProperty("vendor.thermal.config",
                                        "thermal_info_config_backup.json")) {
            LOG(FATAL) << "Failed to set property vendor.thermal.config to "
                          "thermal_info_config_backup.";
        }
    }
    return 0;
}