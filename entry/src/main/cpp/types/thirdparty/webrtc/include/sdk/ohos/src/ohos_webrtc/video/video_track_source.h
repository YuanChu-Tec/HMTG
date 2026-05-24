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

#ifndef WEBRTC_CAMERA_TRACK_SOURCE_H
#define WEBRTC_CAMERA_TRACK_SOURCE_H

#include "video_capturer.h"
#include "../render/egl_context.h"

#include "api/notifier.h"
#include "api/media_stream_interface.h"
#include "media/base/video_adapter.h"
#include "media/base/video_broadcaster.h"
#include "rtc_base/synchronization/mutex.h"
#include "rtc_base/thread.h"
#include "rtc_base/timestamp_aligner.h"

#include <optional>

namespace webrtc {

class OhosVideoTrackSource : public Notifier<VideoTrackSourceInterface>, VideoCapturer::Observer {
public:
    static rtc::scoped_refptr<OhosVideoTrackSource> Create(
        std::unique_ptr<VideoCapturer> capturer, rtc::Thread* signalingThread,
        std::shared_ptr<EglContext> sharedContext = nullptr);

    ~OhosVideoTrackSource() override;

    void Start();
    void Stop();

    void SetCapturerObserver(VideoCapturer::Observer* observer);

protected:
    OhosVideoTrackSource(
        std::unique_ptr<VideoCapturer> capturer, rtc::Thread* signaling_thread,
        std::shared_ptr<EglContext> sharedContext);

    void SetState(SourceState state);
    void SetState(bool isLive);

    bool ApplyRotation();

    bool AdaptFrame(
        int width, int height, int64_t time_us, int* out_width, int* out_height, int* crop_width, int* crop_height,
        int* crop_x, int* crop_y);

protected:
    // Implements rtc::VideoSourceInterface.
    void AddOrUpdateSink(rtc::VideoSinkInterface<VideoFrame>* sink, const rtc::VideoSinkWants& wants) override;
    void RemoveSink(rtc::VideoSinkInterface<VideoFrame>* sink) override;

    // Implements MediaSourceInterface
    SourceState state() const override;
    bool remote() const override;

    // Part of VideoTrackSourceInterface.
    bool is_screencast() const override;
    absl::optional<bool> needs_denoising() const override;
    bool GetStats(Stats* stats) override;

    // Encoded sinks not implemented.
    bool SupportsEncodedOutput() const override
    {
        return false;
    }
    void GenerateKeyFrame() override {}
    void AddEncodedSink(rtc::VideoSinkInterface<RecordableEncodedFrame>* sink) override {}
    void RemoveEncodedSink(rtc::VideoSinkInterface<RecordableEncodedFrame>* sink) override {}
    void ProcessConstraints(const VideoTrackSourceConstraints& constraints) override;

    // VideoCapturer::Observer
    void OnCapturerStarted(bool success) override;
    void OnCapturerStopped() override;
    void
    OnFrameCaptured(rtc::scoped_refptr<VideoFrameBuffer> buffer, int64_t timestampUs, VideoRotation rotation) override;

private:
    std::unique_ptr<rtc::Thread> thread_;
    rtc::Thread* signalingThread_;
    std::unique_ptr<VideoCapturer> capturer_;
    std::shared_ptr<EglContext> sharedContext_;
    cricket::VideoAdapter videoAdapter_;
    rtc::VideoBroadcaster broadcaster_;
    std::atomic<SourceState> state_;
    Mutex statsMutex_;
    std::optional<Stats> stats_ RTC_GUARDED_BY(statsMutex_);
    std::mutex obsMutex_;
    VideoCapturer::Observer* capturerObserver_{};
    rtc::TimestampAligner timestampAligner_;
};

} // namespace webrtc

#endif // WEBRTC_CAMERA_TRACK_SOURCE_H
