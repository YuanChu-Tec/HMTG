/**
 * Copyright (c) 2024 Archermind Technology (Nanjing) Co. Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef WEBRTC_CAMERA_DEVICE_INFO_H
#define WEBRTC_CAMERA_DEVICE_INFO_H

#include "../video/video_info.h"

#include <string>
#include <vector>

#include <ohcamera/camera_manager.h>

namespace webrtc {

enum class FacingMode {
    kNone,
    kUser,
    kEnvironment,
    kLeft,
    kRight
};

struct CameraDeviceInfo {
    std::string deviceId;
    std::string groupId;
    std::string label;
    FacingMode facingMode;
    std::vector<video::VideoProfile> profiles;
};

std::string CameraPositionToString(Camera_Position position);

std::string CameraConnectionTypeToString(Camera_Connection connectionType);

video::PixelFormat NativeCameraFormatToPixelFormat(Camera_Format format);

} // namespace webrtc

#endif // WEBRTC_CAMERA_DEVICE_INFO_H
