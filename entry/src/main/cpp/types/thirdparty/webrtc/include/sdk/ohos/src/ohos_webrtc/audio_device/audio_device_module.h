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

#ifndef WEBRTC_AUDIO_DEVICE_MODULE_H
#define WEBRTC_AUDIO_DEVICE_MODULE_H

#include <map>
#include <string>
#include <memory>

#include "napi.h"

#include "absl/types/optional.h"
#include "rtc_base/copy_on_write_buffer.h"
#include "modules/audio_device/include/audio_device.h"

namespace webrtc {

class AudioDeviceBuffer;

enum class AudioErrorType {
    INIT,
    START_EXCEPTION,
    START_STATE_MISMATCH,
    GENERAL
};

enum class AudioStateType {
    START,
    STOP
};

class AudioInput {
public:
    class Observer {
    public:
        virtual ~Observer() = default;
        virtual void OnAudioInputError(AudioErrorType type, const std::string& message) = 0;
        virtual void OnAudioInputStateChange(AudioStateType newState) = 0;
        virtual void OnAudioInputSamplesReady(
            int32_t sampleRate, int32_t format, int32_t channelCount, rtc::CopyOnWriteBuffer* data) = 0;
    };

    virtual ~AudioInput() {}

    virtual int32_t Init() = 0;
    virtual int32_t Terminate() = 0;

    virtual int32_t InitRecording() = 0;
    virtual bool RecordingIsInitialized() const = 0;

    virtual int32_t StartRecording() = 0;
    virtual int32_t StopRecording() = 0;
    virtual bool Recording() const = 0;

    virtual void AttachAudioBuffer(AudioDeviceBuffer* audioBuffer) = 0;

    virtual int32_t MicrophoneMuteIsAvailable(bool* available) = 0;
    virtual int32_t SetMicrophoneMute(bool mute) = 0;
    virtual int32_t MicrophoneMute(bool* enabled) const = 0;

    virtual void RegisterObserver(Observer* obs) = 0;
    virtual void UnregisterObserver(Observer* obs) = 0;
};

class AudioOutput {
public:
    class Observer {
    public:
        virtual ~Observer() = default;
        virtual void OnAudioOutputError(AudioErrorType type, const std::string& message) = 0;
        virtual void OnAudioOutputStateChange(AudioStateType newState) = 0;
    };

    virtual ~AudioOutput() {}

    virtual int32_t Init() = 0;
    virtual int32_t Terminate() = 0;

    virtual int32_t InitPlayout() = 0;
    virtual bool PlayoutIsInitialized() const = 0;

    virtual int32_t StartPlayout() = 0;
    virtual int32_t StopPlayout() = 0;
    virtual bool Playing() const = 0;

    virtual int32_t SpeakerMuteIsAvailable(bool* available) = 0;
    virtual int32_t setSpeakerMute(bool mute) = 0;
    virtual int32_t SpeakerMute(bool* enabled) const = 0;

    virtual void AttachAudioBuffer(AudioDeviceBuffer* audioBuffer) = 0;

    virtual int32_t PlayoutDelay(uint16_t* delay_ms) const = 0;
    virtual int GetPlayoutUnderrunCount() = 0;

    virtual absl::optional<AudioDeviceModule::Stats> GetStats() const
    {
        return absl::nullopt;
    }

    virtual void RegisterObserver(Observer* obs) = 0;
    virtual void UnregisterObserver(Observer* obs) = 0;
};

class NapiAudioDeviceModule : public Napi::ObjectWrap<NapiAudioDeviceModule>,
                              public AudioInput::Observer,
                              public AudioOutput::Observer {
public:
    static void Init(Napi::Env env, Napi::Object exports);

    ~NapiAudioDeviceModule() override;

    rtc::scoped_refptr<AudioDeviceModule> Get() const
    {
        return adm_;
    }

protected:
    friend class ObjectWrap;

    explicit NapiAudioDeviceModule(const Napi::CallbackInfo& info);

    Napi::Value GetEventHandler(const Napi::CallbackInfo& info);
    void SetEventHandler(const Napi::CallbackInfo& info, const Napi::Value& value);

    Napi::Value SetSpeakerMute(const Napi::CallbackInfo& info);
    Napi::Value SetMicrophoneMute(const Napi::CallbackInfo& info);
    Napi::Value SetNoiseSuppressorEnabled(const Napi::CallbackInfo& info);
    Napi::Value ToJson(const Napi::CallbackInfo& info);

    static Napi::Value isBuiltInAcousticEchoCancelerSupported(const Napi::CallbackInfo& info);
    static Napi::Value isBuiltInNoiseSuppressorSupported(const Napi::CallbackInfo& info);

protected:
    void OnAudioInputError(AudioErrorType type, const std::string& message) override;
    void OnAudioInputStateChange(AudioStateType newState) override;
    void OnAudioInputSamplesReady(
        int32_t sampleRate, int32_t format, int32_t channelCount, rtc::CopyOnWriteBuffer* data) override;
    void OnAudioOutputError(AudioErrorType type, const std::string& message) override;
    void OnAudioOutputStateChange(AudioStateType newState) override;

private:
    static Napi::FunctionReference constructor_;

    rtc::scoped_refptr<AudioDeviceModule> adm_;

    struct EventHandler {
        Napi::FunctionReference ref;
        Napi::ThreadSafeFunction tsfn;
    };

    mutable std::mutex mutex_;
    std::map<std::string, EventHandler> eventHandlers_;
};

} // namespace webrtc

#endif // WEBRTC_AUDIO_DEVICE_MODULE_H
