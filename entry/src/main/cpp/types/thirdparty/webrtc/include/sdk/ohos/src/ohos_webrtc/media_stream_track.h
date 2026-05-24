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

#ifndef WEBRTC_MEDIA_STREAM_TRACK_H
#define WEBRTC_MEDIA_STREAM_TRACK_H

#include <set>

#include "napi.h"

#include "api/media_stream_interface.h"
#include "api/peer_connection_interface.h"

namespace webrtc {

class MediaStreamTrackWrapper : public ObserverInterface {
public:
    static std::unique_ptr<MediaStreamTrackWrapper> Create(rtc::scoped_refptr<MediaStreamTrackInterface> track);

    // Do not use this constructor directly, use 'Create' above.
    explicit MediaStreamTrackWrapper(rtc::scoped_refptr<MediaStreamTrackInterface> track);
    ~MediaStreamTrackWrapper() override;

    const MediaStreamTrackInterface* track() const
    {
        return track_.get();
    }

    MediaStreamTrackInterface* track()
    {
        return track_.get();
    }

    void AddVideoSink(rtc::VideoSinkInterface<VideoFrame>* sink);
    void RemoveVideoSink(rtc::VideoSinkInterface<VideoFrame>* sink);
    void RemoveAllVideoSinks();

protected:
    void OnChanged() override;

private:
    rtc::scoped_refptr<MediaStreamTrackInterface> track_;
    std::mutex sinksMutex_;
    std::set<rtc::VideoSinkInterface<VideoFrame>*> videoSinks_;
};

class NapiMediaStreamTrack : public Napi::ObjectWrap<NapiMediaStreamTrack> {
public:
    static void Init(Napi::Env env, Napi::Object exports);

    static Napi::Object NewInstance(Napi::Env env, std::unique_ptr<MediaStreamTrackWrapper> wrapper);

    ~NapiMediaStreamTrack() override;

    rtc::scoped_refptr<MediaStreamTrackInterface> Get() const
    {
        if (!wrapper_) {
            return nullptr;
        }
        return rtc::scoped_refptr<MediaStreamTrackInterface>(wrapper_->track());
    }

    bool IsAudioTrack() const;
    bool IsVideoTrack() const;

    AudioTrackInterface* GetAudioTrack() const;
    VideoTrackInterface* GetVideoTrack() const;

    void AddSink(rtc::VideoSinkInterface<VideoFrame>* sink);
    void RemoveSink(rtc::VideoSinkInterface<VideoFrame>* sink);

protected:
    friend class ObjectWrap;

    explicit NapiMediaStreamTrack(const Napi::CallbackInfo& info);

    Napi::Value GetId(const Napi::CallbackInfo& info);
    Napi::Value GetKind(const Napi::CallbackInfo& info);
    Napi::Value GetEnabled(const Napi::CallbackInfo& info);
    void SetEnabled(const Napi::CallbackInfo& info, const Napi::Value& value);
    Napi::Value GetReadyState(const Napi::CallbackInfo& info);
    Napi::Value Stop(const Napi::CallbackInfo& info);
    Napi::Value ToJson(const Napi::CallbackInfo& info);

private:
    static Napi::FunctionReference constructor_;

    std::unique_ptr<MediaStreamTrackWrapper> wrapper_;
};

} // namespace webrtc

#endif // WEBRTC_MEDIA_STREAM_TRACK_H
