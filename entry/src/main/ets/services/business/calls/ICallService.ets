/**
 * 通话服务接口定义
 * @module feature-calls.services
 */

import { CallSession, CallType, CallState, CallSettings, GroupCallInfo, CallRecord } from '../../../models';
import { MediaStreamConstraints, SessionDescription, IceCandidate, IceServerConfig, IRTCPeerConnection } from '../../../utils/WebRTCUtils';

/**
 * 通话服务接口
 */
export interface ICallService {
  /**
   * 发起语音通话
   * @param userId 用户ID
   * @returns 通话信息
   */
  makeVoiceCall(userId: number): Promise<CallSession>;

  /**
   * 发起视频通话
   * @param userId 用户ID
   * @returns 通话信息
   */
  makeVideoCall(userId: number): Promise<CallSession>;

  /**
   * 接听来电
   * @param callId 通话ID
   */
  acceptCall(callId: string): Promise<void>;

  /**
   * 拒绝来电
   * @param callId 通话ID
   */
  rejectCall(callId: string): Promise<void>;

  /**
   * 挂断通话
   * @param callId 通话ID
   */
  endCall(callId: string): Promise<void>;

  /**
   * 获取当前通话
   * @returns 通话信息
   */
  getCurrentCall(): CallSession | null;

  /**
   * 切换静音状态
   * @param callId 通话ID
   * @param isMuted 是否静音
   */
  toggleMute(callId: string, isMuted: boolean): Promise<void>;

  /**
   * 切换摄像头
   * @param callId 通话ID
   * @param isEnabled 是否启用
   */
  toggleVideo(callId: string, isEnabled: boolean): Promise<void>;

  /**
   * 切换扬声器
   * @param isEnabled 是否启用
   */
  toggleSpeaker(isEnabled: boolean): Promise<void>;

  /**
   * 切换摄像头方向
   */
  switchCamera(): Promise<void>;

  /**
   * 获取通话设置
   * @returns 通话设置
   */
  getCallSettings(): CallSettings;

  /**
   * 更新通话设置
   * @param settings 通话设置
   */
  updateCallSettings(settings: CallSettings): Promise<void>;

  /**
   * 获取通话记录
   * @param limit 数量限制
   * @returns 通话记录列表
   */
  getCallHistory(limit: number): Promise<CallRecord[]>;

  /**
   * 清除通话记录
   */
  clearCallHistory(): Promise<void>;

  /**
   * 注册通话状态监听器
   * @param callback 回调函数
   */
  onCallStateChanged(callback: (callInfo: CallSession) => void): void;

  /**
   * 取消通话状态监听
   */
  offCallStateChanged(): void;

  /**
   * 注册来电监听器
   * @param callback 回调函数
   */
  onIncomingCall(callback: (callInfo: CallSession) => void): void;

  /**
   * 取消来电监听
   */
  offIncomingCall(): void;
}

/**
 * WebRTC 管理器接口
 */
export interface IWebRTCManager {
  /**
   * 初始化 WebRTC
   * @param config STUN/TURN 配置
   */
  initialize(config: IceServerConfig[]): Promise<void>;

  /**
   * 创建 PeerConnection
   * @param callId 通话 ID
   * @returns PeerConnection 实例
   */
  createPeerConnection(callId: string): Promise<IRTCPeerConnection>;

  /**
   * 创建本地视频轨道
   * @param videoElementRef 视频元素引用 ID
   * @returns 视频轨道
   */
  createLocalVideoTrack(videoElementRef: string): Promise<Object>;

  /**
   * 添加远程视频轨道
   * @param callId 通话 ID
   * @param stream 媒体流
   */
  addRemoteVideoTrack(callId: string, stream: Object): void;

  /**
   * 关闭 PeerConnection
   * @param callId 通话ID
   */
  closePeerConnection(callId: string): void;

  /**
   * 清理资源
   */
  cleanup(): void;
}

/**
 * 音频管理器接口
 */
export interface IAudioManager {
  /**
   * 初始化音频设备
   */
  initialize(): Promise<void>;

  /**
   * 开始音频捕获
   */
  startCapture(): Promise<Object>;

  /**
   * 停止音频捕获
   */
  stopCapture(): void;

  /**
   * 播放音频
   * @param stream 媒体流
   */
  playAudio(stream: Object): void;

  /**
   * 切换静音
   * @param isMuted 是否静音
   */
  setMuted(isMuted: boolean): void;

  /**
   * 切换扬声器
   * @param isEnabled 是否启用
   */
  setSpeakerEnabled(isEnabled: boolean): void;

  /**
   * 获取音量等级
   * @returns 音量等级 (0-1)
   */
  getAudioLevel(): number;

  /**
   * 清理资源
   */
  cleanup(): void;
}

/**
 * 视频管理器接口
 */
export interface IVideoManager {
  /**
   * 初始化视频设备
   */
  initialize(): Promise<void>;

  /**
   * 开始视频捕获
   * @param constraints 媒体约束
   * @returns 媒体流对象
   */
  startCapture(constraints?: MediaStreamConstraints): Promise<Object>;

  /**
   * 停止视频捕获
   */
  stopCapture(): void;

  /**
   * 切换摄像头
   * @param facingMode 摄像头朝向
   */
  switchCamera(facingMode?: 'user' | 'environment'): Promise<void>;

  /**
   * 设置视频质量
   * @param quality 质量等级
   */
  setVideoQuality(quality: 'low' | 'medium' | 'high'): void;

  /**
   * 清理资源
   */
  cleanup(): void;
}

/**
 * STUN/TURN 服务接口
 */
export interface ISTUNService {
  /**
   * 获取默认 STUN 服务器列表
   * @returns STUN 服务器配置
   */
  getDefaultSTUNServers(): IceServerConfig[];

  /**
   * 测试 STUN/TURN 连通性
   * @param server 服务器配置
   * @returns 是否可用
   */
  testConnection(server: IceServerConfig): Promise<boolean>;
}
