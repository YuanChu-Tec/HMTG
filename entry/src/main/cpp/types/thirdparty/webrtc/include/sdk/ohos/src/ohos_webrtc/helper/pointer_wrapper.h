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

#ifndef WEBRTC_HELPER_POINTER_WRAPPER_H
#define WEBRTC_HELPER_POINTER_WRAPPER_H

#include <memory>
#include <functional>

namespace ohos {

template <typename T>
class PointerWrapper {
public:
    /**
     * The deleter type.
     */
    using DeleterType = std::function<void(T*)>;

    T& operator*() const
    {
        return *ptr_;
    }

    T* operator->() const
    {
        return ptr_.get();
    }

    bool IsEmpty() const noexcept
    {
        return ptr_ == nullptr;
    }

    T* Raw() const noexcept
    {
        return ptr_.get();
    }

    void Reset() noexcept
    {
        PointerWrapper tmp;
        tmp.Swap(*this);
    }

    void Swap(PointerWrapper& rhs) noexcept
    {
        using std::swap;
        swap(ptr_, rhs.ptr_);
    }

protected:
    constexpr PointerWrapper() noexcept = default;
    PointerWrapper(T* p, DeleterType del) noexcept : ptr_(p, del) {}

    /**
     * A null deleter.
     */
    static void NullDeleter(T*) {}

protected:
    std::shared_ptr<T> ptr_;
};

} // namespace ohos

namespace std {

template <typename T>
void swap(ohos::PointerWrapper<T>& lhs, ohos::PointerWrapper<T>& rhs) noexcept
{
    lhs.Swap(rhs);
}

} // namespace std

#endif // WEBRTC_HELPER_POINTER_WRAPPER_H
