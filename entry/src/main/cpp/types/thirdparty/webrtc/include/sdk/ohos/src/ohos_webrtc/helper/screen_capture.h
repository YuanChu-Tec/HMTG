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

#ifndef WEBRTC_HELPER_SCREEN_CAPTURE_H
#define WEBRTC_HELPER_SCREEN_CAPTURE_H

#include "pointer_wrapper.h"
#include "error.h"

#include <multimedia/player_framework/native_avscreen_capture.h>
#include <multimedia/player_framework/native_avscreen_capture_base.h>
#include <multimedia/player_framework/native_avscreen_capture_errors.h>

namespace ohos {

class AVScreenCapture : public PointerWrapper<OH_AVScreenCapture> {
public:
    static AVScreenCapture Create();
    static AVScreenCapture TakeOwnership(OH_AVScreenCapture* capture);

    AVScreenCapture();
    explicit AVScreenCapture(OH_AVScreenCapture* capture);

private:
    using PointerWrapper::PointerWrapper;
};

inline AVScreenCapture AVScreenCapture::Create()
{
    OH_AVScreenCapture* capture = OH_AVScreenCapture_Create();
    NATIVE_THROW_IF_FAILED(
        capture != nullptr, -1, "OH_AVScreenCapture", "Failed to create native window", AVScreenCapture());
    return AVScreenCapture(capture, [](OH_AVScreenCapture* capture) { OH_AVScreenCapture_Release(capture); });
}

inline AVScreenCapture AVScreenCapture::TakeOwnership(OH_AVScreenCapture* capture)
{
    NATIVE_THROW_IF_FAILED(capture != nullptr, -1, "OH_AVScreenCapture", "Null argument", AVScreenCapture());
    return AVScreenCapture(capture, [](OH_AVScreenCapture* capture) { OH_AVScreenCapture_Release(capture); });
}

inline AVScreenCapture::AVScreenCapture() = default;

inline AVScreenCapture::AVScreenCapture(OH_AVScreenCapture* capture) : PointerWrapper(capture, NullDeleter) {}

} // namespace ohos

#endif // WEBRTC_HELPER_SCREEN_CAPTURE_H
