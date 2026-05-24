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

#ifndef WEBRTC_VIDEO_TEXTURE_BUFFER_H
#define WEBRTC_VIDEO_TEXTURE_BUFFER_H

#include "../render/render_common.h"

#include "api/scoped_refptr.h"
#include "api/video/video_frame_buffer.h"
#include "rtc_base/thread.h"

#include <mutex>

namespace webrtc {

class YuvConverter;

class TextureData {
public:
    enum class Type {
        OES, // GL_TEXTURE_EXTERNAL_OES
        RGB, // GL_TEXTURE_2D
    };

    TextureData(unsigned int id, Type type, rtc::Thread* toI420Handler, YuvConverter* yuvConverter)
        : id_(id), type_(type), toI420Handler_(toI420Handler), yuvConverter_(yuvConverter)
    {
    }

    unsigned int GetId() const
    {
        return id_;
    }

    Type GetType() const
    {
        return type_;
    }

    void Lock() const
    {
        mutex_.lock();
    }

    void Unlock() const
    {
        mutex_.unlock();
    }

    rtc::Thread* getToI420Handler()
    {
        return toI420Handler_;
    }

    YuvConverter* getYuvConverter()
    {
        return yuvConverter_;
    }

private:
    const unsigned int id_;
    const Type type_;
    rtc::Thread* toI420Handler_{};
    YuvConverter* yuvConverter_{};
    mutable std::mutex mutex_;
};

class TextureBuffer : public VideoFrameBuffer {
public:
    static rtc::scoped_refptr<TextureBuffer>
    Create(std::weak_ptr<TextureData> texture, int width, int height, const Matrix& transformMatrix);

    ~TextureBuffer() override;

    Type type() const override
    {
        return Type::kNative;
    }

    int width() const override
    {
        return width_;
    }

    int height() const override
    {
        return height_;
    }

    rtc::scoped_refptr<I420BufferInterface> ToI420() override;

    rtc::scoped_refptr<VideoFrameBuffer> CropAndScale(
        int offset_x, int offset_y, int crop_width, int crop_height, int scaled_width, int scaled_height) override;

    const Matrix& GetTransformMatrix() const
    {
        return transformMatrix_;
    }

    std::shared_ptr<TextureData> GetTexture() const
    {
        return texture_.lock();
    }

protected:
    TextureBuffer(std::weak_ptr<TextureData> texture, int width, int height, const Matrix& transformMatrix);

private:
    std::weak_ptr<TextureData> texture_;
    const int width_;
    const int height_;
    const Matrix transformMatrix_;
};

} // namespace webrtc

#endif // WEBRTC_VIDEO_TEXTURE_BUFFER_H
