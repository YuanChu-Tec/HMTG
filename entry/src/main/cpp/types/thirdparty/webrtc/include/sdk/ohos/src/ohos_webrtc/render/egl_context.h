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

#ifndef WEBRTC_EGL_CONTEXT_H
#define WEBRTC_EGL_CONTEXT_H

#include "../utils/marcos.h"

#include <memory>

#include <EGL/egl.h>

#include "napi.h"

namespace webrtc {

class EglContext : public std::enable_shared_from_this<EglContext> {
public:
    virtual ~EglContext() = default;
    virtual EGLContext GetRawContext() = 0;
};

class NapiEglContext : public Napi::ObjectWrap<NapiEglContext> {
public:
    NAPI_CLASS_NAME_DECLARE(EglContext);
    NAPI_METHOD_NAME_DECLARE(ToJson, toJSON);

    static void Init(Napi::Env env, Napi::Object exports);
    static Napi::Value NewInstance(Napi::Env env, std::shared_ptr<EglContext> eglContext);

    std::shared_ptr<EglContext> Get()
    {
        return eglContext_;
    }

protected:
    friend class ObjectWrap;
    explicit NapiEglContext(const Napi::CallbackInfo& info);
    ~NapiEglContext();

    Napi::Value ToJson(const Napi::CallbackInfo& info);

private:
    static Napi::FunctionReference constructor_;

    std::shared_ptr<EglContext> eglContext_;
};

} // namespace webrtc

#endif // WEBRTC_EGL_CONTEXT_H
