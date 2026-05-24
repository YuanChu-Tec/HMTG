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

#ifndef WEBRTC_HELPER_ERROR_H
#define WEBRTC_HELPER_ERROR_H

#include "rtc_base/logging.h"

#if !defined(NDK_HELPER_CPP_EXCEPTIONS) && !defined(NDK_HELPER_DISABLE_CPP_EXCEPTIONS)
#if defined(__EXCEPTIONS)
#define NDK_HELPER_CPP_EXCEPTIONS
#else
#error Exception support not detected. \
      Define either NDK_HELPER_CPP_EXCEPTIONS or NDK_HELPER_DISABLE_CPP_EXCEPTIONS.
#endif
#endif

#include <string>
#ifdef NDK_HELPER_CPP_EXCEPTIONS
#include <exception>
#endif // NDK_HELPER_CPP_EXCEPTIONS

#ifdef NDK_HELPER_CPP_EXCEPTIONS

#define NATIVE_THROW(e, ...) throw(e)
#define NATIVE_THROW_VOID(e) throw(e)

#define NATIVE_THROW_IF_FAILED(condition, code, domain, message, ...)                                                  \
    if (!(condition)) {                                                                                                \
        throw NativeError::Create(code, domain, message);                                                              \
    }

#define NATIVE_THROW_IF_FAILED_VOID(condition, code, domain, message)                                                  \
    if (!(condition)) {                                                                                                \
        throw NativeError::Create(code, domain, message);                                                              \
    }

#else // NDK_HELPER_CPP_EXCEPTIONS

#define NATIVE_THROW(e, ...)                                                                                           \
    do {                                                                                                               \
        NativeError::ThrowAsNativeException(e);                                                                        \
        return __VA_ARGS__;                                                                                            \
    } while (0)

#define NATIVE_THROW_VOID(e)                                                                                           \
    do {                                                                                                               \
        NativeError::ThrowAsNativeException(e);                                                                        \
        return;                                                                                                        \
    } while (0)

#define NATIVE_THROW_IF_FAILED(condition, code, domain, message, ...)                                                  \
    if (!(condition)) {                                                                                                \
        NativeError::ThrowAsNativeException(NativeError::Create(code, domain, message));                               \
        return __VA_ARGS__;                                                                                            \
    }

#define NATIVE_THROW_IF_FAILED_VOID(condition, code, domain, message)                                                  \
    if (!(condition)) {                                                                                                \
        NativeError::ThrowAsNativeException(NativeError::Create(code, domain, message));                               \
        return;                                                                                                        \
    }

#endif // __EXCEPTIONS

namespace ohos {

void ThrowError(const char* message);

class NativeError
#ifdef NDK_HELPER_CPP_EXCEPTIONS
    : public std::exception
#endif // NDK_HELPER_CPP_EXCEPTIONS
{
public:
    static NativeError Create(const char* domain, const char* message);
    static NativeError Create(const std::string& domain, const std::string& message);
    static NativeError Create(int32_t code, const char* domain, const char* message);
    static NativeError Create(int32_t code, const std::string& domain, const std::string& message);

    static bool HasPendingException();
    static NativeError GetAndClearPendingException();
    static void ThrowAsNativeException(NativeError&& e);

    int32_t Code() const;
    const std::string& Domain() const;

    void PrintToLog() const;

#ifdef NDK_HELPER_CPP_EXCEPTIONS
    const char* what() const noexcept override;
#else
    const char* what() const noexcept;
#endif // NDK_HELPER_CPP_EXCEPTIONS

protected:
    NativeError(int32_t code, const char* domain, const char* message);
    NativeError(int32_t code, const std::string& domain, const std::string& message);

private:
    const int32_t code_{-1};
    const std::string domain_;
    const std::string message_;

    static thread_local std::unique_ptr<NativeError> error_;
};

inline thread_local std::unique_ptr<NativeError> NativeError::error_;

inline NativeError NativeError::Create(const char* domain, const char* message)
{
    return NativeError(0, domain, message);
}

inline NativeError NativeError::Create(const std::string& domain, const std::string& message)
{
    return NativeError(0, domain, message);
}

inline NativeError NativeError::Create(int32_t code, const char* domain, const char* message)
{
    return NativeError(code, domain, message);
}

inline NativeError NativeError::Create(int32_t code, const std::string& domain, const std::string& message)
{
    return NativeError(code, domain, message);
}

inline bool NativeError::HasPendingException()
{
    return static_cast<bool>(error_);
}

inline NativeError NativeError::GetAndClearPendingException()
{
    RTC_CHECK(HasPendingException());
    return *error_.release();
}

inline void NativeError::ThrowAsNativeException(NativeError&& e)
{
    error_ = std::make_unique<NativeError>(e);
}

inline NativeError::NativeError(int32_t code, const char* domain, const char* message)
    : code_(code), domain_(domain), message_(message)
{
}

inline NativeError::NativeError(int32_t code, const std::string& domain, const std::string& message)
    : code_(code), domain_(domain), message_(message)
{
}

inline int32_t NativeError::Code() const
{
    return code_;
}

inline const std::string& NativeError::Domain() const
{
    return domain_;
}

inline void NativeError::PrintToLog() const
{
    RTC_LOG(LS_ERROR) << "NativeError: " << code_ << "-" << domain_ << ", " << what();
}

inline const char* NativeError::what() const noexcept
{
    // caller should not save the return value.
    return message_.c_str();
}

} // namespace ohos

#endif // WEBRTC_HELPER_ERROR_H
