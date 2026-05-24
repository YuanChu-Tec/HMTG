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

#ifndef WEBRTC_HELPER_DRAWING_MATRIX_H
#define WEBRTC_HELPER_DRAWING_MATRIX_H

#include "pointer_wrapper.h"
#include "error.h"

#include <array>

#include <native_drawing/drawing_matrix.h>

namespace ohos {

class DrawingMatrix : public PointerWrapper<OH_Drawing_Matrix> {
public:
    // DrawingMatrix is a 3x3 float type matrix.
    constexpr static int kMatrixSize = 9;

    constexpr static int kScaleX = 0;
    constexpr static int kSkewX = 1;
    constexpr static int kTransX = 2;
    constexpr static int kSkewY = 3;
    constexpr static int kScaleY = 4;
    constexpr static int kTransY = 5;
    constexpr static int kPersp0 = 6;
    constexpr static int kPersp1 = 7;
    constexpr static int kPersp2 = 8;

    static DrawingMatrix Create();
    static DrawingMatrix CreateRotation(float deg, float x, float y);
    static DrawingMatrix CreateScale(float sx, float sy, float px, float py);
    static DrawingMatrix CreateTranslation(float dx, float dy);

    static DrawingMatrix TakeOwnership(OH_Drawing_Matrix* matrix);

    DrawingMatrix();
    explicit DrawingMatrix(OH_Drawing_Matrix* matrix);

    void PreRotate(float degree, float px, float py);
    void PreScale(float sx, float sy, float px, float py);
    void PreTranslate(float dx, float dy);
    void PostRotate(float degree, float px, float py);
    void PostScale(float sx, float sy, float px, float py);
    void PostTranslate(float dx, float dy);
    void Reset();
    void Concat(const DrawingMatrix& a, const DrawingMatrix& b);
    void PreConcat(const DrawingMatrix& other);
    void PostConcat(const DrawingMatrix& other);
    void GetAll(float value[kMatrixSize]) const;
    float GetValue(int index) const;
    void Rotate(float degree, float px, float py);
    void Translate(float dx, float dy);
    void Scale(float sx, float sy, float px, float py);
    bool Invert(DrawingMatrix& inverse) const;
    bool IsEqual(const DrawingMatrix& other) const;
    bool IsIdentity() const;

    DrawingMatrix Copy() const;
    std::string ToString() const;

private:
    using PointerWrapper::PointerWrapper;
};

inline DrawingMatrix DrawingMatrix::Create()
{
    return TakeOwnership(OH_Drawing_MatrixCreate());
}

inline DrawingMatrix DrawingMatrix::CreateRotation(float deg, float x, float y)
{
    return TakeOwnership(OH_Drawing_MatrixCreateRotation(deg, x, y));
}

inline DrawingMatrix DrawingMatrix::CreateScale(float sx, float sy, float px, float py)
{
    return TakeOwnership(OH_Drawing_MatrixCreateScale(sx, sy, px, py));
}

inline DrawingMatrix DrawingMatrix::CreateTranslation(float dx, float dy)
{
    return TakeOwnership(OH_Drawing_MatrixCreateTranslation(dx, dy));
}

inline DrawingMatrix DrawingMatrix::TakeOwnership(OH_Drawing_Matrix* matrix)
{
    NATIVE_THROW_IF_FAILED(matrix != nullptr, -1, "OH_Drawing_Matrix", "Null argument", DrawingMatrix());
    return DrawingMatrix(matrix, [](OH_Drawing_Matrix* matrix) { OH_Drawing_MatrixDestroy(matrix); });
}

inline DrawingMatrix::DrawingMatrix() = default;

inline DrawingMatrix::DrawingMatrix(OH_Drawing_Matrix* capture) : PointerWrapper(capture, NullDeleter) {}

inline void DrawingMatrix::PreRotate(float degree, float px, float py)
{
    OH_Drawing_MatrixPreRotate(Raw(), degree, px, py);
}

inline void DrawingMatrix::PreScale(float sx, float sy, float px, float py)
{
    OH_Drawing_MatrixPreScale(Raw(), sx, sy, px, py);
}

inline void DrawingMatrix::PreTranslate(float dx, float dy)
{
    OH_Drawing_MatrixPreTranslate(Raw(), dx, dy);
}

inline void DrawingMatrix::PostRotate(float degree, float px, float py)
{
    OH_Drawing_MatrixPostRotate(Raw(), degree, px, py);
}

inline void DrawingMatrix::PostScale(float sx, float sy, float px, float py)
{
    OH_Drawing_MatrixPostScale(Raw(), sx, sy, px, py);
}

inline void DrawingMatrix::PostTranslate(float dx, float dy)
{
    OH_Drawing_MatrixPostTranslate(Raw(), dx, dy);
}

inline void DrawingMatrix::Reset()
{
    OH_Drawing_MatrixReset(Raw());
}

inline void DrawingMatrix::Concat(const DrawingMatrix& a, const DrawingMatrix& b)
{
    OH_Drawing_MatrixConcat(Raw(), a.Raw(), b.Raw());
}

inline void DrawingMatrix::PreConcat(const DrawingMatrix& other)
{
    OH_Drawing_MatrixConcat(Raw(), Raw(), other.Raw());
}

inline void DrawingMatrix::PostConcat(const DrawingMatrix& other)
{
    OH_Drawing_MatrixConcat(Raw(), other.Raw(), Raw());
}

inline void DrawingMatrix::GetAll(float value[kMatrixSize]) const
{
    OH_Drawing_MatrixGetAll(Raw(), value);
}

inline float DrawingMatrix::GetValue(int index) const
{
    return OH_Drawing_MatrixGetValue(Raw(), index);
}

inline void DrawingMatrix::Rotate(float degree, float px, float py)
{
    OH_Drawing_MatrixRotate(Raw(), degree, px, py);
}

inline void DrawingMatrix::Translate(float dx, float dy)
{
    OH_Drawing_MatrixTranslate(Raw(), dx, dy);
}

inline void DrawingMatrix::Scale(float sx, float sy, float px, float py)
{
    OH_Drawing_MatrixScale(Raw(), sx, sy, px, py);
}

inline bool DrawingMatrix::Invert(DrawingMatrix& inverse) const
{
    return OH_Drawing_MatrixInvert(Raw(), inverse.Raw());
}

inline bool DrawingMatrix::IsEqual(const DrawingMatrix& other) const
{
    return OH_Drawing_MatrixIsEqual(Raw(), other.Raw());
}

inline bool DrawingMatrix::IsIdentity() const
{
    return OH_Drawing_MatrixIsIdentity(Raw());
}

inline DrawingMatrix DrawingMatrix::Copy() const
{
    float data[kMatrixSize];
    GetAll(data);

    auto copy = DrawingMatrix::Create();
    // clang-format off
    OH_Drawing_MatrixSetMatrix(copy.Raw(),
        data[kScaleX], data[kSkewX], data[kTransX],
        data[kSkewY], data[kScaleY], data[kTransY],
        data[kPersp0], data[kPersp1], data[kPersp2]);
    // clang-format on
    return copy;
}

inline std::string DrawingMatrix::ToString() const
{
    float values[kMatrixSize];
    GetAll(values);

    std::ostringstream os;
    os << "[";
    for (int i = 0; i < kMatrixSize; i++) {
        os << values[i] << ((i == kMatrixSize - 1) ? "" : ", ");
    }
    os << "]";

    return os.str();
}

} // namespace ohos

#endif // WEBRTC_HELPER_DRAWING_MATRIX_H
