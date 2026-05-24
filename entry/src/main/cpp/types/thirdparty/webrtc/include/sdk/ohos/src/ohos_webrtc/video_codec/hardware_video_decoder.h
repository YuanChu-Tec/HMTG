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

#ifndef WEBRTC_VIDEO_CODEC_HARDWARE_VIDEO_DECODER_H
#define WEBRTC_VIDEO_CODEC_HARDWARE_VIDEO_DECODER_H

#include "codec_common.h"
#include "../render/egl_context.h"
#include "../helper/avcodec.h"
#include "helper/native_window.h"
#include "video/video_frame_receiver.h"

#include <string>
#include <deque>
#include <queue>
#include <mutex>
#include <condition_variable>

#include <api/video_codecs/video_decoder.h>
#include <api/video_codecs/sdp_video_format.h>
#include <api/sequence_checker.h>
#include <rtc_base/race_checker.h>

namespace webrtc {
namespace adapter {

class HardwareVideoDecoder : public VideoDecoder, public VideoFrameReceiver::Callback {
public:
    static std::unique_ptr<HardwareVideoDecoder> Create(
        const std::string& codecName, int32_t colorFormat, const SdpVideoFormat& format,
        std::shared_ptr<EglContext> sharedContext = nullptr);

    ~HardwareVideoDecoder() override;

protected:
    HardwareVideoDecoder(
        const std::string& codecName, int32_t colorFormat, const SdpVideoFormat& format,
        std::shared_ptr<EglContext> sharedContext);

    bool Configure(const Settings& settings) override;

    int32_t RegisterDecodeCompleteCallback(DecodedImageCallback* callback) override;

    // `missing_frames`, `fragmentation` and `render_time_ms` are ignored.
    int32_t Decode(const EncodedImage& input_image, bool /*missing_frames*/, int64_t render_time_ms = -1) override;

    int32_t Release() override;

    DecoderInfo GetDecoderInfo() const override;

    const char* ImplementationName() const override;

    void
    OnFrameAvailable(rtc::scoped_refptr<VideoFrameBuffer> buffer, int64_t timestampUs, VideoRotation rotation) override;

protected:
    static void OnCodecError1(OH_AVCodec* codec, int32_t errorCode, void* userData);
    static void OnStreamChanged1(OH_AVCodec* codec, OH_AVFormat* format, void* userData);
    static void OnNeedInputBuffer1(OH_AVCodec* codec, uint32_t index, OH_AVBuffer* buffer, void* userData);
    static void OnNewOutputBuffer1(OH_AVCodec* codec, uint32_t index, OH_AVBuffer* buffer, void* userData);

    void OnCodecError(OH_AVCodec* codec, int32_t errorCode);
    void OnStreamChanged(OH_AVCodec* codec, OH_AVFormat* format);
    void OnNeedInputBuffer(OH_AVCodec* codec, uint32_t index, OH_AVBuffer* buffer);
    void OnNewOutputBuffer(OH_AVCodec* codec, uint32_t index, OH_AVBuffer* buffer);

private:
    bool InitDecode();
    void QueueInputBuffer(const ohos::CodecBuffer& buffer);
    bool DequeueInputBuffer(ohos::CodecBuffer& buffer);
    void DeliverTextureFrame(const ohos::CodecBuffer& buffer);
    void DeliverByteFrame(const ohos::CodecBuffer& buffer);

private:
    struct FrameExtraInfo {
        int64_t timestampUs; // Used as an identifier of the frame.
        uint32_t timestampRtp;
        int64_t timestampNtp;
    };

    std::atomic<bool> initialized_{false};

    const std::string codecName_;
    const SdpVideoFormat& format_;
    const int32_t colorFormat_;
    const std::shared_ptr<EglContext> sharedContext_;

    Settings decoderSettings_;

    ohos::VideoDecoder decoder_;

    std::unique_ptr<VideoFrameReceiver> videoFrameReceiver_;
    ohos::NativeWindow nativeWindow_;

    rtc::RaceChecker callbackRaceChecker_;
    DecodedImageCallback* callback_ RTC_GUARDED_BY(callbackRaceChecker_);

    std::mutex inputMutex_;
    std::condition_variable inputCond_;
    std::queue<ohos::CodecBuffer> inputBufferQueue_;

    std::mutex extraInfosMutex_;
    std::deque<FrameExtraInfo> extraInfos_;
};

} // namespace adapter
} // namespace webrtc

#endif // WEBRTC_VIDEO_CODEC_HARDWARE_VIDEO_DECODER_H
