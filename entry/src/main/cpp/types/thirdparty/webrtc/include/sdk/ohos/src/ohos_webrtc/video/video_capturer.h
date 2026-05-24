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

#ifndef WEBRTC_VIDEO_VIDEO_CAPTURER_H
#define WEBRTC_VIDEO_VIDEO_CAPTURER_H

#include "../video/video_frame_receiver.h"

#include "api/video/video_frame_buffer.h"
#include "api/video/video_rotation.h"

#include <memory>
#include <mutex>

namespace webrtc {

class VideoCapturer {
public:
    class Observer {
    public:
        virtual ~Observer() {}
        virtual void OnCapturerStarted(bool success) = 0;
        virtual void OnCapturerStopped() = 0;
        virtual void
        OnFrameCaptured(rtc::scoped_refptr<VideoFrameBuffer> buffer, int64_t timestampUs, VideoRotation rotation) = 0;
    };

    virtual ~VideoCapturer() = default;

    virtual void Init(std::unique_ptr<VideoFrameReceiver>, Observer* observer) = 0;
    virtual void Release() = 0;
    virtual void Start() = 0;
    virtual void Stop() = 0;
    virtual bool IsScreencast() = 0;
};

} // namespace webrtc

#endif // WEBRTC_VIDEO_VIDEO_CAPTURER_H
