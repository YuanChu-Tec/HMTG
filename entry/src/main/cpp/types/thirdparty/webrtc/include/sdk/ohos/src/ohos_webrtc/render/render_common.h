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

#ifndef WEBRTC_RENDER_RENDER_COMMON_H
#define WEBRTC_RENDER_RENDER_COMMON_H

#include "matrix.h"

#include <array>

namespace webrtc {

constexpr int32_t kMatrixElementCount = 16;

using GLMatrixData = std::array<float, kMatrixElementCount>;

class RenderCommon {
public:
    // Converts GLMatrixData to Matrix.
    static Matrix ConvertGLMatrixDataToMatrix(const GLMatrixData& matrix44)
    {
        // GLMatrixData is stored in column-major order
        // [11 21 31 41         [11 12 14]
        //  12 22 32 42   -->   [21 22 24]
        //  13 23 33 43         [41 42 44]
        //  14 23 34 44]
        // clang-format off
        float values[] = {
            matrix44[0 * 4 + 0], matrix44[1 * 4 + 0], matrix44[3 * 4 + 0],
            matrix44[0 * 4 + 1], matrix44[1 * 4 + 1], matrix44[3 * 4 + 1],
            matrix44[0 * 4 + 3], matrix44[1 * 4 + 3], matrix44[3 * 4 + 3]
        };
        // clang-format on

        Matrix matrix;
        matrix.SetValues(values);
        return matrix;
    }

    /** Converts Matrix to GLMatrixData. */
    static GLMatrixData ConvertMatrixToGLMatrixData(const Matrix& matrix)
    {
        float values[Matrix::kMatrixSize];
        matrix.GetAll(values);

        // The Matrix looks like this:
        // [x1 y1 w1]
        // [x2 y2 w2]
        // [x3 y3 w3]
        // We want to contruct a matrix that looks like this:
        // [x1 y1  0 w1]
        // [x2 y2  0 w2]
        // [ 0  0  1  0]
        // [x3 y3  0 w3]
        // Since it is stored in column-major order, it looks like this:
        // [x1 x2 0 x3
        //  y1 y2 0 y3
        //   0  0 1  0
        //  w1 w2 0 w3]
        // clang-format off
        GLMatrixData matrix44 = {
            values[0 * 3 + 0],  values[1 * 3 + 0], 0,  values[2 * 3 + 0],
            values[0 * 3 + 1],  values[1 * 3 + 1], 0,  values[2 * 3 + 1],
            0,                  0,                 1,  0,
            values[0 * 3 + 2],  values[1 * 3 + 2], 0,  values[2 * 3 + 2],
        };
        // clang-format on
        return matrix44;
    }

    static std::string DumpGLMatrixDataToString(const GLMatrixData& matrix44)
    {
        std::ostringstream os;
        os << "[";
        for (std::size_t i = 0; i < matrix44.size(); i++) {
            os << matrix44[i] << ((i == matrix44.size() - 1) ? "" : ", ");
        }
        os << "]";

        return os.str();
    }
};

} // namespace webrtc

#endif // WEBRTC_RENDER_RENDER_COMMON_H
