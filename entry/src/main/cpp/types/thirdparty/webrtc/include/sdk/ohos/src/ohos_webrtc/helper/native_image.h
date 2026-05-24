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

#ifndef WEBRTC_HELPER_NATIVE_IMAGE_H
#define WEBRTC_HELPER_NATIVE_IMAGE_H

#include "pointer_wrapper.h"
#include "native_window.h"
#include "error.h"

#include <multimedia/player_framework/native_avcodec_base.h>
#include <native_image/native_image.h>
#include <native_window/external_window.h>

namespace ohos {

constexpr int32_t kMatrixElementCount = 16;

using TransformMatrix = std::array<float, kMatrixElementCount>;

class NativeImage : public PointerWrapper<OH_NativeImage> {
public:
    static NativeImage Create(uint32_t textureId, uint32_t textureTarget);
    static NativeImage TakeOwnership(OH_NativeImage* image);

    NativeImage();
    explicit NativeImage(OH_NativeImage* image);

    NativeWindow AcquireNativeWindow() const;
    void AttachContext(uint32_t textureId);
    void DetachContext();
    void UpdateSurfaceImage();
    int64_t GetTimestamp();
    TransformMatrix GetTransformMatrix();
    uint64_t GetSurfaceId() const;
    void SetOnFrameAvailableListener(OH_OnFrameAvailableListener listener);
    void UnsetOnFrameAvailableListener();
    TransformMatrix GetTransformMatrixV2();
    OHNativeWindowBuffer* AcquireNativeWindowBuffer(int* fenceFd);
    void ReleaseNativeWindowBuffer(OHNativeWindowBuffer* nativeWindowBuffer, int fenceFd);

private:
    using PointerWrapper::PointerWrapper;
};

inline NativeImage NativeImage::Create(uint32_t textureId, uint32_t textureTarget)
{
    OH_NativeImage* image = OH_NativeImage_Create(textureId, textureTarget);
    NATIVE_THROW_IF_FAILED(image != nullptr, -1, "OH_NativeImage", "Failed to create native image", NativeImage());
    return NativeImage(image, [](OH_NativeImage* image) { OH_NativeImage_Destroy(&image); });
}

inline NativeImage NativeImage::TakeOwnership(OH_NativeImage* image)
{
    NATIVE_THROW_IF_FAILED(image != nullptr, -1, "OH_NativeImage", "Null native image", NativeImage());
    return NativeImage(image, [](OH_NativeImage* image) { OH_NativeImage_Destroy(&image); });
}

inline NativeImage::NativeImage() = default;

inline NativeImage::NativeImage(OH_NativeImage* image) : PointerWrapper(image, NullDeleter) {}

inline NativeWindow NativeImage::AcquireNativeWindow() const
{
    OHNativeWindow* window = OH_NativeImage_AcquireNativeWindow(Raw());
    NATIVE_THROW_IF_FAILED(window != nullptr, -1, "OH_NativeImage", "Failed to acquire native window", NativeWindow());
    return NativeWindow(window);
}

inline void NativeImage::AttachContext(uint32_t textureId)
{
    int32_t ret = OH_NativeImage_AttachContext(Raw(), textureId);
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeImage", "Failed to attach context");
}

inline void NativeImage::DetachContext()
{
    int32_t ret = OH_NativeImage_DetachContext(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeImage", "Failed to detach context");
}

inline void NativeImage::UpdateSurfaceImage()
{
    int32_t ret = OH_NativeImage_UpdateSurfaceImage(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeImage", "Failed to update surface image");
}

inline int64_t NativeImage::GetTimestamp()
{
    return OH_NativeImage_GetTimestamp(Raw());
}

inline TransformMatrix NativeImage::GetTransformMatrix()
{
    TransformMatrix matrix;
    int32_t ret = OH_NativeImage_GetTransformMatrix(Raw(), matrix.data());
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeImage", "Failed to get transform matrix", matrix);
    return matrix;
}

inline uint64_t NativeImage::GetSurfaceId() const
{
    uint64_t surfaceId = 0;
    int32_t ret = OH_NativeImage_GetSurfaceId(Raw(), &surfaceId);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeImage", "Failed to get surface id", surfaceId);
    return surfaceId;
}

inline void NativeImage::SetOnFrameAvailableListener(OH_OnFrameAvailableListener listener)
{
    int32_t ret = OH_NativeImage_SetOnFrameAvailableListener(Raw(), listener);
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeImage", "Failed to set on frame available listener");
}

inline void NativeImage::UnsetOnFrameAvailableListener()
{
    int32_t ret = OH_NativeImage_UnsetOnFrameAvailableListener(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeImage", "Failed to unset on frame available listener");
}

inline TransformMatrix NativeImage::GetTransformMatrixV2()
{
    TransformMatrix matrix;
    int32_t ret = OH_NativeImage_GetTransformMatrixV2(Raw(), matrix.data());
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeImage", "Failed to get transform matrix (V2)", matrix);
    return matrix;
}

inline OHNativeWindowBuffer* NativeImage::AcquireNativeWindowBuffer(int* fenceFd)
{
    OHNativeWindowBuffer* buffer = nullptr;
    int32_t ret = OH_NativeImage_AcquireNativeWindowBuffer(Raw(), &buffer, fenceFd);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeImage", "Failed to acquire native window buffer", buffer);
    ret = OH_NativeWindow_NativeObjectReference(buffer);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OH_NativeImage", "Failed to acquire native window buffer", buffer);
    return buffer;
}

inline void NativeImage::ReleaseNativeWindowBuffer(OHNativeWindowBuffer* nativeWindowBuffer, int fenceFd)
{
    int32_t ret = OH_NativeImage_ReleaseNativeWindowBuffer(Raw(), nativeWindowBuffer, fenceFd);
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OH_NativeImage", "Failed to release native window buffer");
}

} // namespace ohos

#endif // WEBRTC_HELPER_NATIVE_IMAGE_H
