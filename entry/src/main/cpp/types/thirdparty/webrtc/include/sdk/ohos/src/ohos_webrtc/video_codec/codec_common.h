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

#ifndef WEBRTC_VIDEO_CODEC_CODEC_COMMON_H
#define WEBRTC_VIDEO_CODEC_CODEC_COMMON_H

#include <multimedia/player_framework/native_avbuffer.h>

namespace ohos {

struct CodecBuffer {
    CodecBuffer() : index(-1), buf(nullptr) {}
    CodecBuffer(int32_t _index, OH_AVBuffer* _buf) : index(_index), buf(_buf) {}

    int32_t index;
    OH_AVBuffer* buf;
};

} // namespace ohos

#endif // WEBRTC_VIDEO_CODEC_CODEC_COMMON_H
