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

#ifndef WEBRTC_RENDER_VIDEO_FRAME_DRAWER_H
#define WEBRTC_RENDER_VIDEO_FRAME_DRAWER_H

#include "gl_drawer.h"
#include "../video/texture_buffer.h"

#include "api/scoped_refptr.h"
#include "api/video/video_frame.h"
#include "rtc_base/thread.h"

namespace webrtc {

class VideoFrameDrawer {
public:
    void DrawFrame(const VideoFrame& frame, GlDrawer& drawer, const Matrix& additionalRenderMatrix);
    void DrawFrame(
        const VideoFrame& frame, GlDrawer& drawer, const Matrix& additionalRenderMatrix, int viewportX, int viewportY,
        int viewportWidth, int viewportHeight);

    void DrawTexture(
        rtc::scoped_refptr<TextureBuffer> buffer, GlDrawer& drawer, const Matrix& renderMatrix, int frameWidth,
        int frameHeight, int viewportX, int viewportY, int viewportWidth, int viewportHeight);

private:
    std::vector<uint32_t> yuvTextures_;
    Matrix renderMatrix_;
};

} // namespace webrtc

#endif // WEBRTC_RENDER_VIDEO_FRAME_DRAWER_H
