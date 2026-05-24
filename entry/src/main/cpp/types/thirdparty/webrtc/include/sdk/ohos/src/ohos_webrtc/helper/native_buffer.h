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

#ifndef WEBRTC_HELPER_NATIVE_BUFFER_H
#define WEBRTC_HELPER_NATIVE_BUFFER_H

#include "pointer_wrapper.h"
#include "error.h"

#include <native_buffer/native_buffer.h>
#include <native_window/external_window.h>

namespace ohos {

class NativeBuffer : public PointerWrapper<OH_NativeBuffer> {
public:
    static NativeBuffer Create(const OH_NativeBuffer_Config* config);

    static NativeBuffer Create(int32_t width, int32_t height, int32_t format, int32_t usage, int32_t stride);

    /**
     * Adds the reference count of a OH_NativeBuffer, and take its ownership.
     * @param buffer Indicates the pointer to a <b>OH_NativeBuffer</b> instance.
     * @return An NativeBuffer.
     */
    static NativeBuffer Reference(OH_NativeBuffer* buffer);

    static NativeBuffer TakeOwnership(OH_NativeBuffer* buffer);

    static NativeBuffer From(OHNativeWindowBuffer* nativeWindowBuffer);

    NativeBuffer();
    explicit NativeBuffer(OH_NativeBuffer*);

    OH_NativeBuffer_Config GetConfig() const;

    void* Map() const;
    void Unmap() const;

    uint32_t GetSeqNum() const;

private:
    using PointerWrapper::PointerWrapper;
};

inline NativeBuffer NativeBuffer::Create(const OH_NativeBuffer_Config* config)
{
    OH_NativeBuffer* buffer = OH_NativeBuffer_Alloc(config);
    NATIVE_THROW_IF_FAILED(buffer != nullptr, -1, "OH_NativeBuffer", "Failed to alloc native buffer", NativeBuffer());
    return NativeBuffer::TakeOwnership(buffer);
}

inline NativeBuffer NativeBuffer::Create(int32_t width, int32_t height, int32_t format, int32_t usage, int32_t stride)
{
    OH_NativeBuffer_Config config{width, height, format, usage, stride};
    OH_NativeBuffer* buffer = OH_NativeBuffer_Alloc(&config);
    NATIVE_THROW_IF_FAILED(buffer != nullptr, -1, "OH_NativeBuffer", "Failed to alloc native buffer", NativeBuffer());
    return NativeBuffer::TakeOwnership(buffer);
}

inline NativeBuffer NativeBuffer::Reference(OH_NativeBuffer* buffer)
{
    int32_t ret = OH_NativeBuffer_Reference(buffer);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeBuffer", "Failed to alloc native buffer", NativeBuffer());
    return NativeBuffer::TakeOwnership(buffer);
}

inline NativeBuffer NativeBuffer::TakeOwnership(OH_NativeBuffer* buffer)
{
    NATIVE_THROW_IF_FAILED(buffer != nullptr, -1, "OH_NativeBuffer", "Invalid argument", NativeBuffer());
    return NativeBuffer(buffer, [](OH_NativeBuffer* buffer) { OH_NativeBuffer_Unreference(buffer); });
}

inline NativeBuffer NativeBuffer::From(OHNativeWindowBuffer* nativeWindowBuffer)
{
    NATIVE_THROW_IF_FAILED(nativeWindowBuffer != nullptr, -1, "OH_NativeBuffer", "Invalid argument", NativeBuffer());
    OH_NativeBuffer* buffer = nullptr;
    int32_t ret = OH_NativeBuffer_FromNativeWindowBuffer(nativeWindowBuffer, &buffer);
    NATIVE_THROW_IF_FAILED(
        ret == 0, ret, "OH_NativeBuffer", "Failed to get native buffer from native window buffer", NativeBuffer());
    return NativeBuffer(buffer);
}

inline NativeBuffer::NativeBuffer() = default;

inline NativeBuffer::NativeBuffer(OH_NativeBuffer* buffer) : PointerWrapper(buffer, NullDeleter) {}

inline OH_NativeBuffer_Config NativeBuffer::GetConfig() const
{
    OH_NativeBuffer_Config config;
    OH_NativeBuffer_GetConfig(Raw(), &config);
    return config;
}

inline void* NativeBuffer::Map() const
{
    void* addr = nullptr;
    int32_t ret = OH_NativeBuffer_Map(Raw(), &addr);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeBuffer", "Failed to alloc native buffer", nullptr);
    return addr;
}

inline void NativeBuffer::Unmap() const
{
    int32_t ret = OH_NativeBuffer_Unmap(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeBuffer", "Failed to alloc native buffer");
}

inline uint32_t NativeBuffer::GetSeqNum() const
{
    return OH_NativeBuffer_GetSeqNum(Raw());
}

} // namespace ohos

#endif // WEBRTC_HELPER_NATIVE_BUFFER_H
