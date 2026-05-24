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

#ifndef WEBRTC_RENDER_GL_DRAWER_H
#define WEBRTC_RENDER_GL_DRAWER_H

#include "render_common.h"
#include "gl_shader.h"

namespace webrtc {

class GlDrawer {
public:
    virtual ~GlDrawer() = default;

    virtual void DrawOes(
        int oesTextureId, const GLMatrixData& texMatrix, int frameWidth, int frameHeight, int viewportX, int viewportY,
        int viewportWidth, int viewportHeight) = 0;
    virtual void DrawRgb(
        int textureId, const GLMatrixData& texMatrix, int frameWidth, int frameHeight, int viewportX, int viewportY,
        int viewportWidth, int viewportHeight) = 0;
    virtual void DrawYuv(
        std::vector<uint32_t> yuvTextures, const GLMatrixData& texMatrix, int frameWidth, int frameHeight,
        int viewportX, int viewportY, int viewportWidth, int viewportHeight) = 0;
};

class GlGenericDrawer : public GlDrawer {
public:
    enum class ShaderType {
        UNKNOWN = -1,
        OES,
        RGB,
        YUV
    };

    GlGenericDrawer();
    ~GlGenericDrawer() override;

    void DrawOes(
        int oesTextureId, const GLMatrixData& texMatrix, int frameWidth, int frameHeight, int viewportX, int viewportY,
        int viewportWidth, int viewportHeight) override;
    void DrawRgb(
        int textureId, const GLMatrixData& texMatrix, int frameWidth, int frameHeight, int viewportX, int viewportY,
        int viewportWidth, int viewportHeight) override;
    void DrawYuv(
        std::vector<uint32_t> yuvTextures, const GLMatrixData& texMatrix, int frameWidth, int frameHeight,
        int viewportX, int viewportY, int viewportWidth, int viewportHeight) override;

protected:
    void PrepareShader(
        ShaderType shaderType, const GLMatrixData& texMatrix, int frameWidth, int frameHeight, int viewportWidth,
        int viewportHeight);
    std::unique_ptr<GlShader> CreateShader(ShaderType shaderType);

private:
    ShaderType currentShaderType_{ShaderType::UNKNOWN};
    std::unique_ptr<GlShader> currentShader_;
    int positionLocation_;
    int textureLocation_;
    int texTransformLocation_;
};

} // namespace webrtc

#endif // WEBRTC_RENDER_GL_DRAWER_H
