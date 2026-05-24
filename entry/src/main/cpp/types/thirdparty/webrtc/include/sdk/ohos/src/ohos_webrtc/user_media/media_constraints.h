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

#ifndef WEBRTC_MEDIA_CONSTRAINTS_H
#define WEBRTC_MEDIA_CONSTRAINTS_H

#include <string>
#include <vector>
#include <memory>
#include <optional>

#include "api/audio_options.h"

namespace webrtc {

class MediaTrackConstraintsPrivate;

class BaseConstraint {
public:
    explicit BaseConstraint(const char* name);
    virtual ~BaseConstraint();

    virtual bool IsConstrained() const = 0;
    virtual void Reset() = 0;
    virtual bool HasExact() const = 0;
    virtual std::string ToString() const = 0;

    bool HasMandatory() const;

    virtual bool HasMin() const
    {
        return false;
    }

    virtual bool HasMax() const
    {
        return false;
    }

    const char* GetName() const
    {
        return name_;
    }

private:
    const char* name_;
};

class LongConstraint : public BaseConstraint {
public:
    explicit LongConstraint(const char* name);

    bool IsConstrained() const override;
    void Reset() override;
    std::string ToString() const override;
    bool Matches(int32_t value) const;

    void SetMin(int32_t value)
    {
        min_ = value;
    }

    void SetMax(int32_t value)
    {
        max_ = value;
    }

    void SetExact(int32_t value)
    {
        exact_ = value;
    }

    void SetIdeal(int32_t value)
    {
        ideal_ = value;
    }

    bool HasMin() const override
    {
        return min_.has_value();
    }

    bool HasMax() const override
    {
        return max_.has_value();
    }

    bool HasExact() const override
    {
        return exact_.has_value();
    }

    int32_t Min() const
    {
        return min_.value();
    }

    int32_t Max() const
    {
        return max_.value();
    }

    int32_t Exact() const
    {
        return exact_.value();
    }

    bool HasIdeal() const
    {
        return ideal_.has_value();
    }

    int32_t Ideal() const
    {
        return ideal_.value();
    }

private:
    std::optional<int32_t> min_;
    std::optional<int32_t> max_;
    std::optional<int32_t> exact_;
    std::optional<int32_t> ideal_;
};

class DoubleConstraint : public BaseConstraint {
public:
    // Permit a certain leeway when comparing floats. The offset of 0.00001
    // is chosen based on observed behavior of doubles formatted with
    // rtc::ToString.
    static const double kConstraintEpsilon;

    explicit DoubleConstraint(const char* name);

    bool IsConstrained() const override;
    void Reset() override;
    std::string ToString() const override;
    bool Matches(int32_t value) const;

    void SetMin(double value)
    {
        min_ = value;
    }

    void SetMax(double value)
    {
        max_ = value;
    }

    void SetExact(double value)
    {
        exact_ = value;
    }

    void SetIdeal(double value)
    {
        ideal_ = value;
    }

    bool HasMin() const override
    {
        return min_.has_value();
    }
    bool HasMax() const override
    {
        return max_.has_value();
    }
    bool HasExact() const override
    {
        return exact_.has_value();
    }

    double Min() const
    {
        return min_.value();
    }
    double Max() const
    {
        return max_.value();
    }
    double Exact() const
    {
        return exact_.value();
    }
    bool HasIdeal() const
    {
        return ideal_.has_value();
    }
    double Ideal() const
    {
        return ideal_.value();
    }

private:
    std::optional<double> min_;
    std::optional<double> max_;
    std::optional<double> exact_;
    std::optional<double> ideal_;
};

class StringConstraint : public BaseConstraint {
public:
    // String-valued options don't have min or max, but can have multiple
    // values for ideal and exact.
    explicit StringConstraint(const char* name);

    bool IsConstrained() const override;
    void Reset() override;
    std::string ToString() const override;
    bool Matches(std::string value) const;

    void SetExact(const std::string& exact)
    {
        exact_ = {exact};
    }

    void SetExact(const std::vector<std::string>& exact)
    {
        exact_ = exact;
    }

    void SetIdeal(const std::string& ideal)
    {
        ideal_ = {ideal};
    }

    void SetIdeal(const std::vector<std::string>& ideal)
    {
        ideal_ = ideal;
    }

    bool HasExact() const override
    {
        return !exact_.empty();
    }

    bool HasIdeal() const
    {
        return !ideal_.empty();
    }

    const std::vector<std::string>& Exact() const
    {
        return exact_;
    }

    const std::vector<std::string>& Ideal() const
    {
        return ideal_;
    }

private:
    std::vector<std::string> exact_;
    std::vector<std::string> ideal_;
};

class BooleanConstraint : public BaseConstraint {
public:
    explicit BooleanConstraint(const char* name);

    bool IsConstrained() const override;
    bool Matches(bool value) const;
    std::string ToString() const override;

    void Reset() override;

    bool Exact() const
    {
        return exact_.value();
    }

    bool Ideal() const
    {
        return ideal_.value();
    }

    void SetIdeal(bool value)
    {
        ideal_ = value;
    }

    void SetExact(bool value)
    {
        exact_ = value;
    }

    bool HasExact() const override
    {
        return exact_.has_value();
    }

    bool HasIdeal() const
    {
        return ideal_.has_value();
    }

private:
    std::optional<bool> ideal_{};
    std::optional<bool> exact_{};
};

struct MediaTrackConstraintSet {
public:
    MediaTrackConstraintSet();

    bool IsConstrained() const;

    LongConstraint width;
    LongConstraint height;
    DoubleConstraint aspectRatio;
    DoubleConstraint frameRate;
    StringConstraint facingMode;
    StringConstraint resizeMode;
    LongConstraint sampleRate;
    LongConstraint sampleSize;
    BooleanConstraint echoCancellation;
    BooleanConstraint autoGainControl;
    BooleanConstraint noiseSuppression;
    DoubleConstraint latency;
    LongConstraint channelCount;
    StringConstraint deviceId;
    StringConstraint groupId;
    BooleanConstraint backgroundBlur;
    StringConstraint displaySurface;
    BooleanConstraint googEchoCancellation;
    BooleanConstraint googAutoGainControl;
    BooleanConstraint googNoiseSuppression;
    BooleanConstraint googHighpassFilter;
    BooleanConstraint googAudioMirroring;

    bool HasMin() const;
    bool HasExact() const;

    std::string ToString() const;

private:
    std::vector<const BaseConstraint*> AllConstraints() const;
};

class MediaTrackConstraints {
public:
    MediaTrackConstraints();
    MediaTrackConstraints(const MediaTrackConstraints& other);
    ~MediaTrackConstraints()
    {
        Reset();
    }

    MediaTrackConstraints& operator=(const MediaTrackConstraints& other)
    {
        Assign(other);
        return *this;
    }

    bool IsConstrained() const;

    void Initialize();
    void Initialize(const MediaTrackConstraintSet& basic, const std::vector<MediaTrackConstraintSet>& advanced);

    void Assign(const MediaTrackConstraints&);

    void Reset();
    bool IsNull() const
    {
        return private_ == nullptr;
    }

    const MediaTrackConstraintSet& Basic() const;
    MediaTrackConstraintSet& MutableBasic();
    const std::vector<MediaTrackConstraintSet>& Advanced() const;

    const std::string ToString() const;

private:
    std::shared_ptr<MediaTrackConstraintsPrivate> private_;
};

} // namespace webrtc

#endif // WEBRTC_MEDIA_CONSTRAINTS_H
