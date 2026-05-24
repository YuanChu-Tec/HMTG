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

#ifndef WEBRTC_RENDER_MATRIX_H
#define WEBRTC_RENDER_MATRIX_H

#include <array>

#include "../helper/drawing_matrix.h"

namespace webrtc {

class Matrix {
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

    Matrix();
    Matrix(const Matrix& other);
    Matrix(Matrix&& other) noexcept;

    Matrix& operator=(const Matrix& other);
    Matrix& operator=(Matrix&& other) noexcept;

    void SetValues(float values[kMatrixSize]);
    void PreRotate(float degree, float px, float py);
    void PreScale(float sx, float sy, float px, float py);
    void PreTranslate(float dx, float dy);
    void PostRotate(float degree, float px, float py);
    void PostScale(float sx, float sy, float px, float py);
    void PostTranslate(float dx, float dy);
    void Reset();
    void Concat(const Matrix& a, const Matrix& b);
    void PreConcat(const Matrix& other);
    void PostConcat(const Matrix& other);
    void Rotate(float degree, float px, float py);
    void Translate(float dx, float dy);
    void Scale(float sx, float sy, float px, float py);
    bool Invert(Matrix& inverse);
    void GetAll(float value[kMatrixSize]) const;
    float GetValue(int index) const;
    bool IsEqual(const Matrix& other) const;
    bool IsIdentity() const;

    void Swap(Matrix& other)
    {
        impl_.Swap(other.impl_);
    }

private:
    ohos::DrawingMatrix impl_;
};

template <typename OStream>
inline OStream& operator<<(OStream& os, const Matrix& matrix)
{
    float values[Matrix::kMatrixSize];
    matrix.GetAll(values);

    os << "[";
    for (int i = 0; i < Matrix::kMatrixSize; i++) {
        os << values[i] << ((i == Matrix::kMatrixSize - 1) ? "" : ", ");
    }
    os << "]";

    return os;
}

} // namespace webrtc

#endif // WEBRTC_RENDER_MATRIX_H
