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

#ifndef WEBRTC_HELPER_NATIVE_WINDOW_H
#define WEBRTC_HELPER_NATIVE_WINDOW_H

#include "pointer_wrapper.h"
#include "error.h"

#include <poll.h>

#include <native_window/external_window.h>

namespace ohos {

class NativeWindowBuffer : public PointerWrapper<OHNativeWindowBuffer> {
public:
    static NativeWindowBuffer CreateFromSurfaceBuffer(void* pSurfaceBuffer);

    static NativeWindowBuffer CreateFromNativeBuffer(OH_NativeBuffer* nativeBuffer);

    static NativeWindowBuffer TakeOwnership(OHNativeWindowBuffer* buffer);

    NativeWindowBuffer();
    explicit NativeWindowBuffer(OHNativeWindowBuffer* buffer);

private:
    using PointerWrapper::PointerWrapper;
};

class NativeWindow : public PointerWrapper<OHNativeWindow> {
public:
    static NativeWindow CreateFromSurfaceId(uint64_t surfaceId);

    static NativeWindow TakeOwnership(OHNativeWindow* window);

    NativeWindow();
    explicit NativeWindow(OHNativeWindow* window);

    uint64_t GetSurfaceId() const;

    NativeWindowBuffer RequestBuffer(bool wait = false);

    void FlushBuffer(OHNativeWindowBuffer* buffer, int fenceFd = -1);

    void AbortBuffer(OHNativeWindowBuffer* buffer);

private:
    using PointerWrapper::PointerWrapper;
};

inline NativeWindowBuffer NativeWindowBuffer::TakeOwnership(OHNativeWindowBuffer* buffer)
{
    NATIVE_THROW_IF_FAILED(buffer != nullptr, -1, "OHNativeWindow", "Null argument", NativeWindowBuffer());
    return NativeWindowBuffer(
        buffer, [](OHNativeWindowBuffer* buffer) { OH_NativeWindow_DestroyNativeWindowBuffer(buffer); });
}

inline NativeWindowBuffer::NativeWindowBuffer() = default;

inline NativeWindowBuffer::NativeWindowBuffer(OHNativeWindowBuffer* buffer) : PointerWrapper(buffer, NullDeleter) {}

inline NativeWindow NativeWindow::CreateFromSurfaceId(uint64_t surfaceId)
{
    OHNativeWindow* window = nullptr;
    int32_t ret = OH_NativeWindow_CreateNativeWindowFromSurfaceId(surfaceId, &window);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OHNativeWindow", "Failed to create native window", NativeWindow());
    return NativeWindow::TakeOwnership(window);
}

inline NativeWindow NativeWindow::TakeOwnership(OHNativeWindow* window)
{
    NATIVE_THROW_IF_FAILED(window != nullptr, -1, "OHNativeWindow", "Null argument", NativeWindow());
    return NativeWindow(window, [](OHNativeWindow* window) { OH_NativeWindow_DestroyNativeWindow(window); });
}

inline NativeWindow::NativeWindow() = default;

inline NativeWindow::NativeWindow(OHNativeWindow* window) : PointerWrapper(window, NullDeleter) {}

inline uint64_t NativeWindow::GetSurfaceId() const
{
    uint64_t surfaceId = 0;
    int32_t ret = OH_NativeWindow_GetSurfaceId(Raw(), &surfaceId);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OHNativeWindow", "Failed to get surface id", 0);
    return surfaceId;
}

inline NativeWindowBuffer NativeWindow::RequestBuffer(bool wait)
{
    OHNativeWindowBuffer* windowBuffer = nullptr;
    int releaseFenceFd = -1;
    int32_t ret = OH_NativeWindow_NativeWindowRequestBuffer(Raw(), &windowBuffer, &releaseFenceFd);
    NATIVE_THROW_IF_FAILED(ret == 0, ret, "OHNativeWindow", "Failed to request buffer", NativeWindowBuffer());

    if (releaseFenceFd != -1) {
        if (wait) {
            int retCode = -1;
            uint32_t timeout = 3000;
            struct pollfd fds = {0};
            fds.fd = releaseFenceFd;
            fds.events = POLLIN;

            do {
                retCode = poll(&fds, 1, timeout);
            } while (retCode == -1 && (errno == EINTR || errno == EAGAIN));
        }

        close(releaseFenceFd);
    }

    return NativeWindowBuffer(windowBuffer);
}

inline void NativeWindow::FlushBuffer(OHNativeWindowBuffer* buffer, int fenceFd)
{
    Region region{nullptr, 0};
    int32_t ret = OH_NativeWindow_NativeWindowFlushBuffer(Raw(), buffer, fenceFd, region);
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OHNativeWindow", "Failed to flush buffer");
}

inline void NativeWindow::AbortBuffer(OHNativeWindowBuffer* buffer)
{
    int32_t ret = OH_NativeWindow_NativeWindowAbortBuffer(Raw(), buffer);
    NATIVE_THROW_IF_FAILED_VOID(ret == 0, ret, "OHNativeWindow", "Failed to flush buffer");
}

} // namespace ohos

#endif // WEBRTC_HELPER_NATIVE_WINDOW_H
