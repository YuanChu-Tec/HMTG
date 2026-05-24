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

#ifndef WEBRTC_RENDER_EGL_ENV_H
#define WEBRTC_RENDER_EGL_ENV_H

#include "egl_context.h"
#include "../helper/native_window.h"

#include <EGL/eglext.h>
#include <cstdint>
#include <vector>
#include <memory>

#include <EGL/egl.h>

#include "napi.h"
#include "utils/marcos.h"

namespace webrtc {

class EglEnv {
public:
    // used for shared context
    static EglEnv& GetDefault();

    static std::unique_ptr<EglEnv> Create();
    static std::unique_ptr<EglEnv> Create(std::shared_ptr<EglContext> sharedContext);
    static std::unique_ptr<EglEnv> Create(const std::vector<int32_t>& configAttributes);
    static std::unique_ptr<EglEnv>
    Create(std::shared_ptr<EglContext> sharedContext, const std::vector<int32_t>& configAttributes);

    static int32_t GetOpenGLESVersionFromConfig(const std::vector<int32_t>& configAttributes);

    // Do not use this constructor directly, use 'Create' above.
    explicit EglEnv();
    ~EglEnv();

    std::shared_ptr<EglContext> GetContext() const;

    bool CreatePbufferSurface(int width, int height);
    bool CreateWindowSurface(ohos::NativeWindow window);
    void ReleaseSurface();

    bool MakeCurrent();
    bool DetachCurrent();

    bool SwapBuffers();
    bool SwapBuffers(uint64_t timestampNs);

    int GetSurfaceWidth() const;
    int GetSurfaceHeight() const;

protected:
    bool Init(EGLContext sharedContext, const std::vector<int32_t>& configAttributes);
    void Release();

    void SetupExtensions();

private:
    EGLConfig eglConfig_{};
    EGLDisplay eglDisplay_{EGL_NO_DISPLAY};
    EGLContext eglContext_{EGL_NO_CONTEXT};
    EGLSurface eglSurface_{EGL_NO_SURFACE};

    PFNEGLPRESENTATIONTIMEANDROIDPROC eglPresentationTimeANDROID_{};
};

class NapiEglEnv : public Napi::ObjectWrap<NapiEglEnv> {
public:
    NAPI_CLASS_NAME_DECLARE(EglEnv);
    NAPI_METHOD_NAME_DECLARE(Create, create);
    NAPI_METHOD_NAME_DECLARE(GetContext, getContext);
    NAPI_METHOD_NAME_DECLARE(ToJson, toJSON);

    static void Init(Napi::Env env, Napi::Object exports);

protected:
    friend class ObjectWrap;
    explicit NapiEglEnv(const Napi::CallbackInfo& info);
    ~NapiEglEnv();

    static Napi::Value Create(const Napi::CallbackInfo& info);

    Napi::Value GetContext(const Napi::CallbackInfo& info);
    Napi::Value ToJson(const Napi::CallbackInfo& info);

private:
    static Napi::FunctionReference constructor_;

    std::shared_ptr<EglEnv> eglEnv_;
};

} // namespace webrtc

#endif // WEBRTC_RENDER_EGL_ENV_H
