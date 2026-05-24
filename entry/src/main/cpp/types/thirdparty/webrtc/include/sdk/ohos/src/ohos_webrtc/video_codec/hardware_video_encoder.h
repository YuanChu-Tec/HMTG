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

#ifndef WEBRTC_VIDEO_CODEC_HARDWARE_VIDEO_ENCODER_H
#define WEBRTC_VIDEO_CODEC_HARDWARE_VIDEO_ENCODER_H

#include "codec_common.h"
#include "../render/egl_env.h"
#include "../render/egl_context.h"
#include "../render/video_frame_drawer.h"
#include "../video/texture_buffer.h"
#include "../helper/avcodec.h"
#include "../helper/native_window.h"
#include "../helper/native_buffer.h"

#include <string>
#include <memory>
#include <queue>
#include <deque>
#include <mutex>
#include <condition_variable>

#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <multimedia/player_framework/native_avcapability.h>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <multimedia/player_framework/native_avformat.h>

#include <api/video_codecs/video_encoder.h>
#include <api/video_codecs/sdp_video_format.h>

namespace webrtc {
namespace adapter {

class HardwareVideoEncoder : public VideoEncoder {
public:
    static std::unique_ptr<HardwareVideoEncoder> Create(
        const std::string& codecName, int32_t pixelFormat, const SdpVideoFormat& format,
        std::shared_ptr<EglContext> sharedContext = nullptr);

    ~HardwareVideoEncoder() override;

protected:
    HardwareVideoEncoder(
        const std::string& codecName, int32_t pixelFormat, const SdpVideoFormat& format,
        std::shared_ptr<EglContext> sharedContext);

    int InitEncode(const VideoCodec* codec_settings, const Settings& settings) override;
    int32_t RegisterEncodeCompleteCallback(EncodedImageCallback* callback) override;
    int32_t Encode(const VideoFrame& frame, const std::vector<VideoFrameType>* frame_types) override;
    void SetRates(const RateControlParameters& parameters) override;
    EncoderInfo GetEncoderInfo() const override;
    int32_t Release() override;

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
    void UpdateEncoderInfo();
    VideoEncoder::ScalingSettings GetScalingSettings();

    bool DequeueInputBuffer(ohos::CodecBuffer& buffer);
    void QueueInputBuffer(const ohos::CodecBuffer& buffer);

    int32_t EncodeTextureBuffer(const VideoFrame& frame);
    int32_t EncodeByteBuffer(const VideoFrame& frame);

private:
    struct FrameExtraInfo {
        int64_t timestampUs; // Used as an identifier of the frame.
        uint32_t timestampRtp;
        VideoRotation rotation;
    };

    const std::string codecName_;
    const int32_t pixelFormat_;
    const SdpVideoFormat format_;
    const std::shared_ptr<EglContext> sharedContext_;

    std::atomic<bool> initialized_{false};

    OH_AVRange supportedBitrateRange_;
    ohos::VideoEncoder encoder_;
    ohos::NativeWindow nativeWindow_;

    std::unique_ptr<EglEnv> eglEnv_;
    std::unique_ptr<GlDrawer> textureDrawer_;
    std::unique_ptr<VideoFrameDrawer> videoFrameDrawer_;

    VideoCodec codecSettings_;
    EncoderInfo encoderInfo_;
    uint32_t targetBitrate_;
    uint32_t curBitrate_;
    uint32_t targetFramerate_;
    uint32_t curFramerate_;

    EncodedImageCallback* callback_;

    std::mutex inputMutex_;
    std::condition_variable inputCond_;
    std::queue<ohos::CodecBuffer> inputBufferQueue_;

    rtc::scoped_refptr<EncodedImageBuffer> configData_;

    std::mutex extraInfosMutex_;
    std::deque<FrameExtraInfo> extraInfos_;
};

} // namespace adapter
} // namespace webrtc

#endif // WEBRTC_VIDEO_CODEC_HARDWARE_VIDEO_ENCODER_H
