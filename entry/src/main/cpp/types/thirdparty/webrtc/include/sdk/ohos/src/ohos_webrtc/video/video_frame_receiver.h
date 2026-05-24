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

#ifndef WEBRTC_VIDEO_FRAME_RECEIVER_H
#define WEBRTC_VIDEO_FRAME_RECEIVER_H

#include <cstdint>

#include "api/scoped_refptr.h"
#include "api/video/video_frame.h"
#include "api/video/video_frame_buffer.h"

namespace webrtc {

template <typename From, typename To, typename Rep = int64_t>
constexpr Rep TimestampCast(Rep timestamp)
{
    using CF = std::ratio_divide<From, To>;

    constexpr bool numIsOne = CF::num == 1;
    constexpr bool denIsOne = CF::den == 1;

    if constexpr (denIsOne) {
        if constexpr (numIsOne) {
            return timestamp;
        } else {
            return timestamp * CF::num;
        }
    } else {
        if constexpr (numIsOne) {
            return timestamp / CF::den;
        } else {
            return timestamp * CF::num / CF::den;
        }
    }
}

class TimestampConverter {
public:
    TimestampConverter() {}
    explicit TimestampConverter(std::function<int64_t(int64_t)> converter) : converter_(std::move(converter)) {}

    int64_t Convert(int64_t timestamp)
    {
        if (converter_) {
            return converter_(timestamp);
        }
        return timestamp;
    }

private:
    std::function<int64_t(int64_t)> converter_;
};

class VideoFrameReceiver {
public:
    class Callback {
    public:
        virtual ~Callback() {}
        virtual void
        OnFrameAvailable(rtc::scoped_refptr<VideoFrameBuffer> buffer, int64_t timestampUs, VideoRotation rotation) = 0;
    };

    virtual ~VideoFrameReceiver() {}
    virtual uint64_t GetSurfaceId() const = 0;
    virtual void SetVideoFrameSize(int32_t width, int32_t height) = 0;

    void SetCallback(Callback* observer)
    {
        callback_ = observer;
    }

    void SetTimestampConverter(TimestampConverter timestampConverter)
    {
        timestampConverter_ = std::move(timestampConverter);
    }

protected:
    Callback* callback_{};
    // Adapt with different timestamp units from different sources, such as camera and video decoder,
    // do nothing by Default.
    TimestampConverter timestampConverter_;
};

} // namespace webrtc

#endif // WEBRTC_VIDEO_FRAME_RECEIVER_H
