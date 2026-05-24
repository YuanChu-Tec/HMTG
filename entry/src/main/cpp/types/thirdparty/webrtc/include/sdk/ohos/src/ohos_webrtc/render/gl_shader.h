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

#ifndef WEBRTC_RENDER_GL_SHADER_H
#define WEBRTC_RENDER_GL_SHADER_H

#include <string>

namespace webrtc {

class GlShader {
public:
    GlShader();
    ~GlShader();

    bool Compile(const char* vertexShaderString, const char* fragmentShaderString);

    void Use();

    int GetAttribLocation(const char* name);
    int GetUniformLocation(const char* name);

    void SetBool(const char* name, bool value) const;
    void SetInt(const char* name, int value) const;
    void SetFloat(const char* name, float value) const;
    void SetVector2f(const char* name, float x, float y);
    void SetVector3f(const char* name, float x, float y, float z);
    void SetVector4f(const char* name, float x, float y, float z, float w);
    void SetMatrix4(const char* name, const std::array<float, 16>& matrix);

private:
    bool CheckCompileErrors(unsigned int shader, const std::string& type);

    unsigned int id_{0};
};

} // namespace webrtc

#endif // WEBRTC_RENDER_GL_SHADER_H
