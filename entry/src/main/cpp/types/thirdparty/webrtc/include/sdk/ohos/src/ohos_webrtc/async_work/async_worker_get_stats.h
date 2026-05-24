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

#ifndef WEBRTC_ASYNC_WORKER_GET_STATS_H
#define WEBRTC_ASYNC_WORKER_GET_STATS_H

#include "napi.h"

#include "api/peer_connection_interface.h"

namespace webrtc {

class AsyncWorkerGetStats : public Napi::AsyncWorker {
public:
    static AsyncWorkerGetStats* Create(Napi::Env env, const char* resourceName);

    Napi::Promise GetPromise()
    {
        return deferred_.Promise();
    }

    rtc::scoped_refptr<RTCStatsCollectorCallback> GetCallback() const;

protected:
    AsyncWorkerGetStats(Napi::Env env, const char* resourceName);

    friend class GetStatsCallback;
    void SetReport(const rtc::scoped_refptr<const RTCStatsReport>& report);

protected:
    void Execute() override;
    void OnOK() override;
    void OnError(const Napi::Error& e) override;

private:
    Napi::Promise::Deferred deferred_;
    rtc::scoped_refptr<RTCStatsCollectorCallback> callback_;
    rtc::scoped_refptr<const RTCStatsReport> report_;
};

} // namespace webrtc

#endif // WEBRTC_ASYNC_WORKER_GET_STATS_H
