/*
 * Copyright (C) 2021 The Android Open Source Project
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

#define LOG_TAG "android.hardware.power.stats-service.pixel"

#include <dataproviders/DisplayStateResidencyDataProvider.h>
#include <dataproviders/PowerStatsEnergyConsumer.h>
#include <ZumaProCommonDataProviders.h>
#include <PowerStatsAidl.h>

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <log/log.h>
#include <sys/stat.h>

using aidl::android::hardware::power::stats::DisplayStateResidencyDataProvider;
using aidl::android::hardware::power::stats::EnergyConsumerType;
using aidl::android::hardware::power::stats::PowerStatsEnergyConsumer;

void addDisplay(std::shared_ptr<PowerStats> p) {
    // Add display residency stats for inner display
    struct stat primaryBuffer;
    if (!stat("/sys/class/drm/card0/device/primary-panel/time_in_state", &primaryBuffer)) {
        // time_in_state exists
        addDisplayMrrByEntity(p, "Inner Display", "/sys/class/drm/card0/device/primary-panel/");
    } else {
        // time_in_state doesn't exist
        std::vector<std::string> inner_states = {
            "Off",
            "LP: 2152x2076@1",
            "LP: 2152x2076@30",
            "On: 2152x2076@1",
            "On: 2152x2076@10",
            "On: 2152x2076@60",
            "On: 2152x2076@120",
            "HBM: 2152x2076@60",
            "HBM: 2152x2076@120"};

        p->addStateResidencyDataProvider(std::make_unique<DisplayStateResidencyDataProvider>(
                "Inner Display",
                "/sys/class/backlight/panel0-backlight/state",
                inner_states));
    }

    // Add display residency stats for outer display
    struct stat secondaryBuffer;
    if (!stat("/sys/class/drm/card0/device/secondary-panel/time_in_state", &secondaryBuffer)) {
        // time_in_state exists
        addDisplayMrrByEntity(p, "Outer Display", "/sys/class/drm/card0/device/secondary-panel/");
    } else {
        // time_in_state doesn't exist
        std::vector<std::string> outer_states = {
            "Off",
            "LP: 1080x2424@30",
            "On: 1080x2424@60",
            "On: 1080x2424@120",
            "HBM: 1080x2424@60",
            "HBM: 1080x2424@120"};

        p->addStateResidencyDataProvider(std::make_unique<DisplayStateResidencyDataProvider>(
                "Outer Display",
                "/sys/class/backlight/panel1-backlight/state",
                outer_states));
    }

    // Add display energy consumer
    p->addEnergyConsumer(PowerStatsEnergyConsumer::createMeterConsumer(
            p,
            EnergyConsumerType::DISPLAY,
            "Display",
            {"VSYS_PWR_DISPLAY"}));// VSYS_PWR_DISPLAY = inner + outer
}

int main() {
    LOG(INFO) << "Pixel PowerStats HAL AIDL Service is starting.";

    // single thread
    ABinderProcess_setThreadPoolMaxThreadCount(0);

    std::shared_ptr<PowerStats> p = ndk::SharedRefBase::make<PowerStats>();

    addZumaProCommonDataProviders(p);
    addDisplay(p);

    const std::string instance = std::string() + PowerStats::descriptor + "/default";
    binder_status_t status = AServiceManager_addService(p->asBinder().get(), instance.c_str());
    LOG_ALWAYS_FATAL_IF(status != STATUS_OK);

    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE;  // should not reach
}
