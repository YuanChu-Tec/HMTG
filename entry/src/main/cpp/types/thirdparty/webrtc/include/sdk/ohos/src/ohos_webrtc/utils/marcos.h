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

#ifndef WEBRTC_UTILS_MARCOS_H
#define WEBRTC_UTILS_MARCOS_H

#ifndef UNUSED
#define UNUSED __attribute__((unused))
#endif

#define LIKELY(x) __builtin_expect(!!(x), 1)
#define UNLIKELY(x) __builtin_expect(!!(x), 0)

#define NAPI_CLASS_NAME_DECLARE(value) static constexpr char kClassName[] = #value
#define NAPI_ATTRIBUTE_NAME_DECLARE(name, value) static constexpr char kAttributeName##name[] = #value
#define NAPI_METHOD_NAME_DECLARE(name, value) static constexpr char kMethodName##name[] = #value
#define NAPI_EVENT_NAME_DECLARE(name, value) static constexpr char kEventName##name[] = #value
#define NAPI_ENUM_NAME_DECLARE(name, value) static constexpr char kEnumName##name[] = #value

#define NAPI_TYPE_TAG_DECLARE(lower, upper) static constexpr napi_type_tag kTypeTag = {lower, upper}
#define NAPI_CHECK_TYPE_TAG(object, type) (object).CheckTypeTag(&type::kTypeTag)

#endif // WEBRTC_UTILS_MARCOS_H
