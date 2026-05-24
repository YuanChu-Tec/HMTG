/*
# Copyright (c) 2023 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/

#ifndef AUDIO_DEVICE_TEMPLATE_H
#define AUDIO_DEVICE_TEMPLATE_H

#include "modules/audio_device/audio_device_generic.h"

#include "rtc_base/checks.h"
#include "rtc_base/logging.h"

namespace webrtc {

template <class InputType, class OutputType>
class AudioDeviceTemplate : public AudioDeviceGeneric {
public:
    AudioDeviceTemplate(AudioDeviceModule::AudioLayer audio_layer, AudioParameters &audio_parameters)
        : audio_layer_(audio_layer), output_(audio_parameters), input_(audio_parameters), initialized_(false)
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
    }

    virtual ~AudioDeviceTemplate() { RTC_LOG(LS_INFO) << __FUNCTION__; }

    int32_t ActiveAudioLayer(AudioDeviceModule::AudioLayer& audioLayer) const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        audioLayer = audio_layer_;
        return 0;
    }

    InitStatus Init() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        RTC_DCHECK(!initialized_);
        if (output_.Init() != 0) {
            return InitStatus::PLAYOUT_ERROR;
        }
        if (input_.Init() != 0) {
            output_.Terminate();
            return InitStatus::RECORDING_ERROR;
        }
        initialized_ = true;
        return InitStatus::OK;
    }

    int32_t Terminate() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        int32_t err = input_.Terminate();
        err |= output_.Terminate();
        initialized_ = false;
        RTC_DCHECK_EQ(err, 0);
        return err;
    }

    bool Initialized() const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return initialized_;
    }

    int16_t PlayoutDevices() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 1;
    }

    int16_t RecordingDevices() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 1;
    }

    int32_t PlayoutDeviceName(uint16_t index, char name[kAdmMaxDeviceNameSize],
                              char guid[kAdmMaxGuidSize]) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t RecordingDeviceName(uint16_t index, char name[kAdmMaxDeviceNameSize],
                                char guid[kAdmMaxGuidSize]) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t SetPlayoutDevice(uint16_t index) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    int32_t SetPlayoutDevice(AudioDeviceModule::WindowsDeviceType device) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t SetRecordingDevice(uint16_t index) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    int32_t SetRecordingDevice(AudioDeviceModule::WindowsDeviceType device) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t PlayoutIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        available = true;
        return 0;
    }

    int32_t InitPlayout() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.InitPlayout();
    }

    bool PlayoutIsInitialized() const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.PlayoutIsInitialized();
    }

    int32_t RecordingIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        available = true;
        return 0;
    }

    int32_t InitRecording() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return input_.InitRecording();
    }

    bool RecordingIsInitialized() const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return input_.RecordingIsInitialized();
    }

    int32_t StartPlayout() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.StartPlayout();
    }

    int32_t StopPlayout() override
    {
        if (!Playing()) {
            return 0;
        }
        RTC_LOG(LS_INFO) << __FUNCTION__;
        int32_t err = output_.StopPlayout();
        return err;
    }

    bool Playing() const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.Playing();
    }

    int32_t StartRecording() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return input_.StartRecording();
    }

    int32_t StopRecording() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        if (!Recording()) {
            return 0;
        }
        int32_t err = input_.StopRecording();
        return err;
    }

    bool Recording() const override { return input_.Recording(); }

    int32_t InitSpeaker() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    bool SpeakerIsInitialized() const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return true;
    }

    int32_t InitMicrophone() override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    bool MicrophoneIsInitialized() const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return true;
    }

    int32_t SpeakerVolumeIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.SpeakerVolumeIsAvailable(available);
    }

    int32_t SetSpeakerVolume(uint32_t volume) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.SetSpeakerVolume(volume);
    }

    int32_t SpeakerVolume(uint32_t& volume) const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.SpeakerVolume(volume);
    }

    int32_t MaxSpeakerVolume(uint32_t& maxVolume) const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.MaxSpeakerVolume(maxVolume);
    }

    int32_t MinSpeakerVolume(uint32_t& minVolume) const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return output_.MinSpeakerVolume(minVolume);
    }

    int32_t MicrophoneVolumeIsAvailable(bool& available) override
    {
        available = false;
        return -1;
    }

    int32_t SetMicrophoneVolume(uint32_t volume) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t MicrophoneVolume(uint32_t& volume) const override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t MaxMicrophoneVolume(uint32_t& maxVolume) const override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t MinMicrophoneVolume(uint32_t& minVolume) const override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t SpeakerMuteIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t SetSpeakerMute(bool enable) override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t SpeakerMute(bool& enabled) const override
    {
        RTC_LOG(LS_INFO) << "should nerver be called";
        return -1;
    }

    int32_t MicrophoneMuteIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << "not implemented";
        return -1;
    }

    int32_t SetMicrophoneMute(bool enable) override
    {
        RTC_LOG(LS_INFO) << "not implemented";
        return -1;
    }

    int32_t MicrophoneMute(bool& enabled) const override
    {
        RTC_LOG(LS_INFO) << "not implemented";
        return -1;
    }

    int32_t StereoPlayoutIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    int32_t SetStereoPlayout(bool enable) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        bool available = true;
        return (enable == available) ? 0 : -1;
    }

    int32_t StereoPlayout(bool& enabled) const override
    {
        return 0;
    }

    int32_t StereoRecordingIsAvailable(bool& available) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    int32_t SetStereoRecording(bool enable) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        bool available = true;
        return (enable == available) ? 0 : -1;
    }

    int32_t StereoRecording(bool& enabled) const override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        return 0;
    }

    int32_t PlayoutDelay(uint16_t& delay_ms) const override
    {
        return 0;
    }

    void AttachAudioBuffer(AudioDeviceBuffer* audioBuffer) override
    {
        RTC_LOG(LS_INFO) << __FUNCTION__;
        output_.AttachAudioBuffer(audioBuffer);
        input_.AttachAudioBuffer(audioBuffer);
    }

private:
    const AudioDeviceModule::AudioLayer audio_layer_;
    OutputType output_;
    InputType input_;
    bool initialized_;
};
}  // namespace webrtc

#endif  // AUDIO_DEVICE_TEMPLATE_H
