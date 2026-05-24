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

#ifndef WEBRTC_RENDER_NATIVE_WINDOW_RENDERER_H
#define WEBRTC_RENDER_NATIVE_WINDOW_RENDERER_H

#include "../helper/native_window.h"

#include "api/video/video_frame.h"
#include "api/video/video_sink_interface.h"

namespace webrtc {
namespace adapter {

class NativeWindowRenderer : public rtc::VideoSinkInterface<VideoFrame> {
public:
    enum class ScalingMode {
        // Scale the content to fit the size of the window by changing the aspect ratio of the content if necessary.
        FILL = 0,
        // Scale the content to fill the size of the window. Some portion of the content may be clipped to fill the
        // window’s bounds.
        ASPECT_FILL,
        // Scale the content to fit the size of the window by maintaining the aspect ratio. Any remaining area of the
        // window bounds is blank.
        ASPECT_FIT
    };

    virtual ~NativeWindowRenderer();

    uint64_t GetSurfaceId() const;

    virtual void SetMirrorHorizontally(bool mirror) {}
    virtual void SetMirrorVertically(bool mirror) {}
    virtual void SetScalingMode(ScalingMode scaleMode) {}

protected:
    explicit NativeWindowRenderer(ohos::NativeWindow window);

protected:
    ohos::NativeWindow window_;
};

} // namespace adapter
} // namespace webrtc

#endif // WEBRTC_RENDER_NATIVE_WINDOW_RENDERER_H
