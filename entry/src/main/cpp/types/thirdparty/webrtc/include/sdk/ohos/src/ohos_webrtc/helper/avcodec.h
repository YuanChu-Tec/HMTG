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

#ifndef WEBRTC_HELPER_AVCODEC_H
#define WEBRTC_HELPER_AVCODEC_H

#include "pointer_wrapper.h"
#include "error.h"

#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <multimedia/player_framework/native_avcodec_videodecoder.h>

namespace ohos {

class AVFormat : public PointerWrapper<OH_AVFormat> {
public:
    static AVFormat Create();
    static AVFormat TakeOwnership(OH_AVFormat* format);

    AVFormat();
    explicit AVFormat(OH_AVFormat* format);

private:
    using PointerWrapper::PointerWrapper;
};

class AVCodec : public PointerWrapper<OH_AVCodec> {
public:
    OH_AVErrCode SetCallback(OH_AVCodec* codec, OH_AVCodecAsyncCallback callback, void* userData);

private:
    using PointerWrapper::PointerWrapper;
};

class VideoEncoder : public AVCodec {
public:
    static VideoEncoder CreateByName(const char* name);

    static VideoEncoder CreateByMime(const char* mime);

    static VideoEncoder TakeOwnership(OH_AVCodec* encoder);

    VideoEncoder();
    explicit VideoEncoder(OH_AVCodec* codec);

private:
    using AVCodec::AVCodec;
};

class VideoDecoder : public AVCodec {
public:
    static VideoDecoder CreateByName(const char* name);

    static VideoDecoder CreateByMime(const char* mime);

    static VideoDecoder TakeOwnership(OH_AVCodec* decoder);

    VideoDecoder();
    explicit VideoDecoder(OH_AVCodec* codec);

private:
    using AVCodec::AVCodec;
};

inline AVFormat AVFormat::Create()
{
    OH_AVFormat* format = OH_AVFormat_Create();
    return TakeOwnership(format);
}

inline AVFormat AVFormat::TakeOwnership(OH_AVFormat* format)
{
    NATIVE_THROW_IF_FAILED(format != nullptr, -1, "OH_AVCodec", "Invalid argument", AVFormat());
    return AVFormat(format, [](OH_AVFormat* format) { OH_AVFormat_Destroy(format); });
}

inline AVFormat::AVFormat() = default;

inline AVFormat::AVFormat(OH_AVFormat* format) : PointerWrapper(format, NullDeleter) {}

inline VideoEncoder VideoEncoder::CreateByName(const char* name)
{
    OH_AVCodec* encoder = OH_VideoEncoder_CreateByName(name);
    return TakeOwnership(encoder);
}

inline VideoEncoder VideoEncoder::CreateByMime(const char* mime)
{
    OH_AVCodec* encoder = OH_VideoEncoder_CreateByMime(mime);
    return TakeOwnership(encoder);
}

inline VideoEncoder VideoEncoder::TakeOwnership(OH_AVCodec* encoder)
{
    NATIVE_THROW_IF_FAILED(encoder != nullptr, -1, "OH_AVCodec", "Invalid argument", VideoEncoder());
    return VideoEncoder(encoder, [](OH_AVCodec* encoder) {
        RTC_DLOG(LS_VERBOSE) << "Destroy video encoder: " << encoder;
        if (encoder) {
            OH_VideoEncoder_Destroy(encoder);
        }
    });
}

inline VideoEncoder::VideoEncoder() = default;

inline VideoEncoder::VideoEncoder(OH_AVCodec* codec) : AVCodec(codec, NullDeleter) {}

inline VideoDecoder VideoDecoder::CreateByName(const char* name)
{
    OH_AVCodec* decoder = OH_VideoDecoder_CreateByName(name);
    return TakeOwnership(decoder);
}

inline VideoDecoder VideoDecoder::CreateByMime(const char* mime)
{
    OH_AVCodec* decoder = OH_VideoDecoder_CreateByMime(mime);
    return TakeOwnership(decoder);
}

inline VideoDecoder VideoDecoder::TakeOwnership(OH_AVCodec* decoder)
{
    NATIVE_THROW_IF_FAILED(decoder != nullptr, -1, "OH_AVCodec", "Invalid argument", VideoDecoder());
    return VideoDecoder(decoder, [](OH_AVCodec* decoder) {
        RTC_DLOG(LS_VERBOSE) << "Destroy video decoder: " << decoder;
        if (decoder) {
            OH_VideoDecoder_Destroy(decoder);
        }
    });
}

inline VideoDecoder::VideoDecoder() = default;

inline VideoDecoder::VideoDecoder(OH_AVCodec* codec) : AVCodec(codec, NullDeleter) {}

} // namespace ohos

#endif // WEBRTC_HELPER_AVCODEC_H
