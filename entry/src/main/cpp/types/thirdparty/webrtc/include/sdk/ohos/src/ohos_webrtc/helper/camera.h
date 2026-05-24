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

#ifndef WEBRTC_HELPER_CAMERA_H
#define WEBRTC_HELPER_CAMERA_H

#include "pointer_wrapper.h"
#include "error.h"

#include <cstddef>
#include <map>
#include <list>
#include <memory>
#include <vector>
#include <mutex>

#include <ohcamera/camera_manager.h>

namespace ohos {

class CameraDevices : public PointerWrapper<Camera_Device> {
public:
    static CameraDevices TakeOwnership(Camera_Device* devices, std::size_t size);

    // empty
    CameraDevices();
    CameraDevices(Camera_Device* devices, std::size_t size);

    Camera_Device* operator[](std::size_t index) const;

    std::size_t Size() const;

protected:
    CameraDevices(Camera_Device* devices, std::size_t size, DeleterType del);

private:
    std::size_t size_{};

    using PointerWrapper::PointerWrapper;
};

class CameraSceneModes : public PointerWrapper<Camera_SceneMode> {
public:
    static CameraSceneModes TakeOwnership(Camera_SceneMode* modes, std::size_t size);

    CameraSceneModes();
    CameraSceneModes(Camera_SceneMode* modes, std::size_t size);

    Camera_SceneMode operator[](std::size_t index) const;

    std::size_t Size() const;

protected:
    CameraSceneModes(Camera_SceneMode* modes, std::size_t size, DeleterType del);

private:
    std::size_t size_{};

    using PointerWrapper::PointerWrapper;
};

class CameraOutputCapability : public PointerWrapper<Camera_OutputCapability> {
public:
    /**
     * Take ownership of a specified Camera_OutputCapability pointer.
     * @param ptr The pointer. Cannot be NULL.
     * @return An CameraOutputCapability.
     */
    static CameraOutputCapability TakeOwnership(Camera_OutputCapability* outputCapability);

    /**
     * Create a new empty CameraOutputCapability.
     */
    CameraOutputCapability();

    /**
     * Create an CameraOutputCapability by *NOT* taking ownership of an existing Camera_OutputCapability pointer.
     * @param ptr The Camera_OutputCapability pointer.
     * @warning The caller is still responsible for freeing the memory.
     */
    explicit CameraOutputCapability(Camera_OutputCapability* outputCapability);

    uint32_t PreviewProfileSize() const;
    uint32_t PhotoProfileSize() const;
    uint32_t VideoProfileSize() const;

    Camera_Profile* GetPreviewProfile(uint32_t) const;
    Camera_Profile* GetPhotoProfile(uint32_t index) const;
    Camera_VideoProfile* GetVideoProfile(uint32_t index) const;

private:
    using PointerWrapper::PointerWrapper;
};

class CameraInput : public PointerWrapper<Camera_Input> {
public:
    /**
     * Take ownership of a specified Camera_Input pointer.
     * @param ptr The pointer. Cannot be NULL.
     * @return An CameraInput.
     */
    static CameraInput TakeOwnership(Camera_Input* input);

    /**
     * Create a new empty CameraInput.
     */
    CameraInput();

    /**
     * Create an CameraInput by *NOT* taking ownership of an existing Camera_Input pointer.
     * @param ptr The Camera_Input pointer.
     * @warning The caller is still responsible for freeing the memory.
     */
    explicit CameraInput(Camera_Input* input);

    bool Open();

    bool Close();

private:
    using PointerWrapper::PointerWrapper;
};

class CameraPreviewOutput : public PointerWrapper<Camera_PreviewOutput> {
public:
    class Observer {
    public:
        virtual ~Observer() {}
        virtual void OnPreviewOutputFrameStart() = 0;
        virtual void OnPreviewOutputFrameEnd(int32_t frameCount) = 0;
        virtual void OnPreviewOutputError(Camera_ErrorCode errorCode) = 0;
    };

    /**
     * Take ownership of a specified Camera_PreviewOutput pointer.
     * @param ptr The pointer. Cannot be NULL.
     * @return An CameraPreviewOutput.
     */
    static CameraPreviewOutput TakeOwnership(Camera_PreviewOutput* output);

    /**
     * Create a new empty CameraPreviewOutput.
     */
    CameraPreviewOutput();

    /**
     * Create an CameraPreviewOutput by *NOT* taking ownership of an existing Camera_PreviewOutput pointer.
     * @param ptr The Camera_PreviewOutput pointer.
     * @warning The caller is still responsible for freeing the memory.
     */
    explicit CameraPreviewOutput(Camera_PreviewOutput* output);

    void Start();
    void Stop();

    void AddObserver(Observer* observer);
    void RemoveObserver(Observer* observer);

protected:
    void RegisterCallback(PreviewOutput_Callbacks* callback);
    void UnregisterCallback(PreviewOutput_Callbacks* callback);

protected:
    static void OnPreviewOutputFrameStart(Camera_PreviewOutput* previewOutput);
    static void OnPreviewOutputFrameEnd(Camera_PreviewOutput* previewOutput, int32_t frameCount);
    static void OnPreviewOutputError(Camera_PreviewOutput* previewOutput, Camera_ErrorCode errorCode);

private:
    static std::map<Camera_PreviewOutput*, std::list<Observer*>> observersMap_;
    static std::mutex mutex_;

    using PointerWrapper::PointerWrapper;
};

class CameraVideoOutput : public PointerWrapper<Camera_VideoOutput> {
public:
    class Observer {
    public:
        virtual ~Observer() {}
        virtual void OnVideoOutputFrameStart() = 0;
        virtual void OnVideoOutputFrameEnd(int32_t frameCount) = 0;
        virtual void OnVideoOutputError(Camera_ErrorCode errorCode) = 0;
    };

    /**
     * Take ownership of a specified Camera_VideoOutput pointer.
     * @param ptr The pointer. Cannot be NULL.
     * @return An CameraVideoOutput.
     */
    static CameraVideoOutput TakeOwnership(Camera_VideoOutput* videoOutput);

    /**
     * Create a new empty CameraVideoOutput.
     */
    CameraVideoOutput();

    /**
     * Create an CameraVideoOutput by *NOT* taking ownership of an existing Camera_VideoOutput pointer.
     * @param ptr The Camera_VideoOutput pointer.
     * @warning The caller is still responsible for freeing the memory.
     */
    explicit CameraVideoOutput(Camera_VideoOutput* videoOutput);

    void Start();
    void Stop();

    void AddObserver(Observer* observer);
    void RemoveObserver(Observer* observer);

protected:
    void RegisterCallback(VideoOutput_Callbacks* callback);
    void UnregisterCallback(VideoOutput_Callbacks* callback);

protected:
    static void OnVideoOutputFrameStart(Camera_VideoOutput* videoOutput);
    static void OnVideoOutputFrameEnd(Camera_VideoOutput* videoOutput, int32_t frameCount);
    static void OnVideoOutputError(Camera_VideoOutput* videoOutput, Camera_ErrorCode errorCode);

private:
    static std::map<Camera_VideoOutput*, std::list<Observer*>> observersMap_;
    static std::mutex mutex_;

    using PointerWrapper::PointerWrapper;
};

class CameraCaptureSession : public PointerWrapper<Camera_CaptureSession> {
public:
    /**
     * Take ownership of a specified Camera_CaptureSession pointer.
     * @param ptr The pointer. Cannot be NULL.
     * @return An CameraCaptureSession.
     */
    static CameraCaptureSession TakeOwnership(Camera_CaptureSession* session);

    /**
     * Create a new empty CameraCaptureSession.
     */
    CameraCaptureSession();

    /**
     * Create an CameraCaptureSession by *NOT* taking ownership of an existing Camera_CaptureSession pointer.
     * @param ptr The Camera_CaptureSession pointer.
     * @warning The caller is still responsible for freeing the memory.
     */
    explicit CameraCaptureSession(Camera_CaptureSession* session);

    bool Start();

    bool Stop();

    bool BeginConfig();

    bool CommitConfig();

    bool AddInput(const CameraInput& input);

    bool AddPreviewOutput(const CameraPreviewOutput& output);

    bool AddVideoOutput(const CameraVideoOutput& output);

private:
    using PointerWrapper::PointerWrapper;
};

class CameraManager {
public:
    class Observer {
    public:
        virtual ~Observer() {}
        virtual void OnDeviceStatus() = 0;
    };

    static CameraManager& GetInstance();

    ~CameraManager();

    void AddObserver(Observer* observer);

    void RemoveObserver(Observer* observer);

    CameraDevices GetSupportedCameras();

    CameraOutputCapability GetSupportedCameraOutputCapability(Camera_Device* cameraDevice);

    CameraSceneModes GetSupportedSceneModes(Camera_Device* device);

    CameraInput CreateCameraInput(Camera_Device* cameraDevice);

    CameraPreviewOutput CreatePreviewOutput(Camera_Profile* profile, const std::string& surfaceId);

    CameraVideoOutput CreateVideoOutput(Camera_VideoProfile* profile, const std::string& surfaceId);

    CameraCaptureSession CreateCaptureSession();

    Camera_Manager* Raw() const;

protected:
    CameraManager();

    static void OnCameraManagerStatusCallback1(Camera_Manager* cameraManager, Camera_StatusInfo* status);
    void OnCameraManagerStatusCallback(Camera_StatusInfo* status);

private:
    Camera_Manager* manager_{};

    std::list<Observer*> observers_;
    std::mutex mutex_;
};

// implementations
inline CameraDevices CameraDevices::TakeOwnership(Camera_Device* devices, std::size_t size)
{
    NATIVE_THROW_IF_FAILED((devices != nullptr) && (size > 0), -1, "OH_Camera", "Invalid argument", CameraDevices());
    return CameraDevices(devices, size, [size](Camera_Device* devices) {
        OH_CameraManager_DeleteSupportedCameras(CameraManager::GetInstance().Raw(), devices, size);
    });
}

inline CameraDevices::CameraDevices() = default;

inline CameraDevices::CameraDevices(Camera_Device* devices, std::size_t size)
    : PointerWrapper(devices, NullDeleter), size_(size)
{
}

inline CameraDevices::CameraDevices(Camera_Device* devices, std::size_t size, DeleterType del)
    : PointerWrapper(devices, del), size_(size)
{
}

inline Camera_Device* CameraDevices::operator[](std::size_t index) const
{
    // 此处不检查index的范围，由调用者保证
    return Raw() + index;
}

inline std::size_t CameraDevices::Size() const
{
    return size_;
}

inline CameraSceneModes CameraSceneModes::TakeOwnership(Camera_SceneMode* modes, std::size_t size)
{
    NATIVE_THROW_IF_FAILED((modes != nullptr) && (size > 0), -1, "OH_Camera", "Invalid argument", CameraSceneModes());
    return CameraSceneModes(modes, size, [](Camera_SceneMode* modes) {
        OH_CameraManager_DeleteSceneModes(CameraManager::GetInstance().Raw(), modes);
    });
}

inline CameraSceneModes::CameraSceneModes() = default;

inline CameraSceneModes::CameraSceneModes(Camera_SceneMode* modes, std::size_t size)
    : PointerWrapper(modes, NullDeleter), size_(size)
{
}

inline CameraSceneModes::CameraSceneModes(Camera_SceneMode* modes, std::size_t size, DeleterType del)
    : PointerWrapper(modes, del), size_(size)
{
}

inline Camera_SceneMode CameraSceneModes::operator[](std::size_t index) const
{
    // 此处不检查index的范围，由调用者保证
    return Raw()[index];
}

inline std::size_t CameraSceneModes::Size() const
{
    return size_;
}

inline CameraOutputCapability CameraOutputCapability::TakeOwnership(Camera_OutputCapability* outputCapability)
{
    NATIVE_THROW_IF_FAILED(outputCapability != nullptr, -1, "OH_Camera", "Null argument", CameraOutputCapability());
    return CameraOutputCapability(outputCapability, [](Camera_OutputCapability* capability) {
        OH_CameraManager_DeleteSupportedCameraOutputCapability(CameraManager::GetInstance().Raw(), capability);
    });
}

inline CameraOutputCapability::CameraOutputCapability() = default;

inline CameraOutputCapability::CameraOutputCapability(Camera_OutputCapability* outputCapability)
    : PointerWrapper(outputCapability, NullDeleter)
{
}

inline uint32_t CameraOutputCapability::PreviewProfileSize() const
{
    return Raw()->previewProfilesSize;
}

inline uint32_t CameraOutputCapability::PhotoProfileSize() const
{
    return Raw()->photoProfilesSize;
}

inline uint32_t CameraOutputCapability::VideoProfileSize() const
{
    return Raw()->videoProfilesSize;
}

inline Camera_Profile* CameraOutputCapability::GetPreviewProfile(uint32_t index) const
{
    return Raw()->previewProfiles[index];
}

inline Camera_Profile* CameraOutputCapability::GetPhotoProfile(uint32_t index) const
{
    return Raw()->photoProfiles[index];
}

inline Camera_VideoProfile* CameraOutputCapability::GetVideoProfile(uint32_t index) const
{
    return Raw()->videoProfiles[index];
}

inline CameraInput CameraInput::TakeOwnership(Camera_Input* input)
{
    NATIVE_THROW_IF_FAILED(input != nullptr, -1, "OH_Camera", "Null argument", CameraInput());
    return CameraInput(input, [](Camera_Input* input) { OH_CameraInput_Release(input); });
}

inline CameraInput::CameraInput() = default;

inline CameraInput::CameraInput(Camera_Input* input) : PointerWrapper(input, NullDeleter) {}

inline bool CameraInput::Open()
{
    Camera_ErrorCode ret = OH_CameraInput_Open(Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to open camera input", false);
    return true;
}

inline bool CameraInput::Close()
{
    Camera_ErrorCode ret = OH_CameraInput_Close(Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to close camera input", false);
    return true;
}

inline CameraPreviewOutput CameraPreviewOutput::TakeOwnership(Camera_PreviewOutput* output)
{
    NATIVE_THROW_IF_FAILED(output != nullptr, -1, "OH_Camera", "Null argument", CameraPreviewOutput());
    return CameraPreviewOutput(output, [](Camera_PreviewOutput* output) { OH_PreviewOutput_Release(output); });
}

inline CameraPreviewOutput::CameraPreviewOutput() = default;

inline CameraPreviewOutput::CameraPreviewOutput(Camera_PreviewOutput* output) : PointerWrapper(output, NullDeleter) {}

inline void CameraPreviewOutput::Start()
{
    Camera_ErrorCode ret = OH_PreviewOutput_Start(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to start camera preview output");
}

inline void CameraPreviewOutput::Stop()
{
    Camera_ErrorCode ret = OH_PreviewOutput_Stop(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to stop camera preview output");
}

inline void CameraPreviewOutput::RegisterCallback(PreviewOutput_Callbacks* callback)
{
    Camera_ErrorCode ret = OH_PreviewOutput_RegisterCallback(Raw(), callback);
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to register callback");
}

inline void CameraPreviewOutput::UnregisterCallback(PreviewOutput_Callbacks* callback)
{
    Camera_ErrorCode ret = OH_PreviewOutput_UnregisterCallback(Raw(), callback);
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to unregister callback");
}

inline CameraVideoOutput CameraVideoOutput::TakeOwnership(Camera_VideoOutput* videoOutput)
{
    NATIVE_THROW_IF_FAILED(videoOutput != nullptr, -1, "OH_Camera", "Null argument", CameraVideoOutput());
    return CameraVideoOutput(videoOutput, [](Camera_VideoOutput* videoOutput) { OH_VideoOutput_Release(videoOutput); });
}

inline CameraVideoOutput::CameraVideoOutput() = default;

inline CameraVideoOutput::CameraVideoOutput(Camera_VideoOutput* videoOutput) : PointerWrapper(videoOutput, NullDeleter)
{
}

inline void CameraVideoOutput::Start()
{
    Camera_ErrorCode ret = OH_VideoOutput_Start(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to start camera preview output");
}

inline void CameraVideoOutput::Stop()
{
    Camera_ErrorCode ret = OH_VideoOutput_Stop(Raw());
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to stop camera preview output");
}

inline void CameraVideoOutput::RegisterCallback(VideoOutput_Callbacks* callback)
{
    Camera_ErrorCode ret = OH_VideoOutput_RegisterCallback(Raw(), callback);
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to register callback");
}

inline void CameraVideoOutput::UnregisterCallback(VideoOutput_Callbacks* callback)
{
    Camera_ErrorCode ret = OH_VideoOutput_UnregisterCallback(Raw(), callback);
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to unregister callback");
}

inline CameraCaptureSession CameraCaptureSession::TakeOwnership(Camera_CaptureSession* session)
{
    NATIVE_THROW_IF_FAILED(session != nullptr, -1, "OH_Camera", "Null argument", CameraCaptureSession());
    return CameraCaptureSession(session, [](Camera_CaptureSession* session) { OH_CaptureSession_Release(session); });
}

inline CameraCaptureSession::CameraCaptureSession() = default;

inline CameraCaptureSession::CameraCaptureSession(Camera_CaptureSession* session) : PointerWrapper(session, NullDeleter)
{
}

inline bool CameraCaptureSession::Start()
{
    Camera_ErrorCode ret = OH_CaptureSession_Start(Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to start capture session", false);
    return true;
}

inline bool CameraCaptureSession::Stop()
{
    Camera_ErrorCode ret = OH_CaptureSession_Stop(Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to stop capture session", false);
    return true;
}

inline bool CameraCaptureSession::BeginConfig()
{
    Camera_ErrorCode ret = OH_CaptureSession_BeginConfig(Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to begin capture session config", false);
    return true;
}

inline bool CameraCaptureSession::CommitConfig()
{
    Camera_ErrorCode ret = OH_CaptureSession_CommitConfig(Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to commit capture session config", false);
    return true;
}

inline bool CameraCaptureSession::AddInput(const CameraInput& input)
{
    Camera_ErrorCode ret = OH_CaptureSession_AddInput(Raw(), input.Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to add input to capture session", false);
    return true;
}

inline bool CameraCaptureSession::AddPreviewOutput(const CameraPreviewOutput& output)
{
    Camera_ErrorCode ret = OH_CaptureSession_AddPreviewOutput(Raw(), output.Raw());
    NATIVE_THROW_IF_FAILED(
        ret == CAMERA_OK, ret, "OH_Camera", "Failed to add preview output to capture session", false);
    return true;
}

inline bool CameraCaptureSession::AddVideoOutput(const CameraVideoOutput& videoOutput)
{
    Camera_ErrorCode ret = OH_CaptureSession_AddVideoOutput(Raw(), videoOutput.Raw());
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to add video output to capture session", false);
    return true;
}

inline CameraManager& CameraManager::GetInstance()
{
    static CameraManager _manager;
    return _manager;
}

inline CameraManager::CameraManager()
{
    Camera_ErrorCode ret = OH_Camera_GetCameraManager(&manager_);
    NATIVE_THROW_IF_FAILED_VOID(ret == CAMERA_OK, ret, "OH_Camera", "Failed to get camera manager");
}

inline CameraManager::~CameraManager()
{
    Camera_ErrorCode ret = OH_Camera_DeleteCameraManager(manager_);
    if (ret != CAMERA_OK) {
        NativeError::Create(ret, "OH_Camera", "Failed to release camara manager").PrintToLog();
    }
}

inline CameraDevices CameraManager::GetSupportedCameras()
{
    uint32_t devicesSize = 0;
    Camera_Device* devices = nullptr; // point to an array of Camera_Device
    Camera_ErrorCode ret = OH_CameraManager_GetSupportedCameras(Raw(), &devices, &devicesSize);
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to get supported cameras", CameraDevices());
    return CameraDevices::TakeOwnership(devices, devicesSize);
}

inline CameraOutputCapability CameraManager::GetSupportedCameraOutputCapability(Camera_Device* cameraDevice)
{
    Camera_OutputCapability* outputCapability = nullptr;
    Camera_ErrorCode ret = OH_CameraManager_GetSupportedCameraOutputCapability(Raw(), cameraDevice, &outputCapability);
    NATIVE_THROW_IF_FAILED(
        ret == CAMERA_OK, ret, "OH_Camera", "Failed to get supported camera output capability",
        CameraOutputCapability());
    return CameraOutputCapability::TakeOwnership(outputCapability);
}

inline CameraSceneModes CameraManager::GetSupportedSceneModes(Camera_Device* device)
{
    uint32_t size = 0;
    Camera_SceneMode* sceneModes = nullptr;
    Camera_ErrorCode ret = OH_CameraManager_GetSupportedSceneModes(device, &sceneModes, &size);
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to get supported cameras", CameraSceneModes());
    return CameraSceneModes::TakeOwnership(sceneModes, size);
}

inline CameraInput CameraManager::CreateCameraInput(Camera_Device* cameraDevice)
{
    Camera_Input* input = nullptr;
    Camera_ErrorCode ret = OH_CameraManager_CreateCameraInput(Raw(), cameraDevice, &input);
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to create camera input", CameraInput());
    return CameraInput::TakeOwnership(input);
}

inline CameraPreviewOutput CameraManager::CreatePreviewOutput(Camera_Profile* profile, const std::string& surfaceId)
{
    Camera_PreviewOutput* output = nullptr;
    Camera_ErrorCode ret = OH_CameraManager_CreatePreviewOutput(Raw(), profile, surfaceId.c_str(), &output);
    NATIVE_THROW_IF_FAILED(
        ret == CAMERA_OK, ret, "OH_Camera", "Failed to create preview output", CameraPreviewOutput());
    return CameraPreviewOutput(output);
}

inline CameraVideoOutput CameraManager::CreateVideoOutput(Camera_VideoProfile* profile, const std::string& surfaceId)
{
    Camera_VideoOutput* output = nullptr;
    Camera_ErrorCode ret = OH_CameraManager_CreateVideoOutput(Raw(), profile, surfaceId.c_str(), &output);
    NATIVE_THROW_IF_FAILED(ret == CAMERA_OK, ret, "OH_Camera", "Failed to create preview output", CameraVideoOutput());
    return CameraVideoOutput(output);
}

inline CameraCaptureSession CameraManager::CreateCaptureSession()
{
    Camera_CaptureSession* session = nullptr;
    Camera_ErrorCode ret = OH_CameraManager_CreateCaptureSession(Raw(), &session);
    NATIVE_THROW_IF_FAILED(
        ret == CAMERA_OK, ret, "OH_Camera", "Failed to create capture session", CameraCaptureSession());
    return CameraCaptureSession(session);
}

inline Camera_Manager* CameraManager::Raw() const
{
    return manager_;
}

} // namespace ohos

#endif // WEBRTC_HELPER_CAMERA_H
