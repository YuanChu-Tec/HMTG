/**
 * WebRTC 引擎抽象接口
 * @module feature-calls.utils
 */

import { common } from '@kit.AbilityKit';

/**
 * ICE 服务器配置
 */
export interface IceServerConfig {
  urls: string[];
  username?: string;
  credential?: string;
}

/**
 * PeerConnection 配置
 */
export interface PeerConnectionConfig {
  iceServers: IceServerConfig[];
  iceTransportPolicy?: 'all' | 'relay';
  bundlePolicy?: 'balanced' | 'max-compat' | 'max-bundle';
  rtcpMuxPolicy?: 'require' | 'negotiate';
}

/**
 * 媒体流约束配置
 */
export interface MediaStreamConstraints {
  audio?: AudioConstraints | boolean;
  video?: VideoConstraints | boolean;
}

/**
 * 音频约束
 */
export interface AudioConstraints {
  echoCancellation?: boolean;
  noiseSuppression?: boolean;
  autoGainControl?: boolean;
  volume?: number;
}

/**
 * 数值范围约束
 */
export interface NumericRangeConstraint {
  ideal: number;
  min?: number;
  max?: number;
}

/**
 * 视频约束
 */
export interface VideoConstraints {
  facingMode?: 'user' | 'environment';
  width?: NumericRangeConstraint;
  height?: NumericRangeConstraint;
  frameRate?: NumericRangeConstraint;
}

/**
 * SDP Offer/Answer
 */
export interface SessionDescription {
  type: 'offer' | 'answer' | 'pranswer' | 'rollback';
  sdp: string;
}

/**
 * ICE Candidate
 */
export interface IceCandidate {
  candidate: string;
  sdpMid: string | null;
  sdpMLineIndex: number | null;
}

/**
 * 权限请求结果
 */
export interface PermissionResult {
  status: 'granted' | 'denied' | 'prompt';
  permission: string;
}

/**
 * WebRTC 引擎接口
 */
export interface IWebRTCEngine {
  /**
   * 初始化 WebRTC 引擎
   * @param config 配置参数
   * @returns 是否初始化成功
   */
  initialize(config: Record<string, Object>): Promise<boolean>;

  /**
   * 创建 PeerConnection
   * @param config PeerConnection 配置
   * @returns PeerConnection ID
   */
  createPeerConnection(config: PeerConnectionConfig): number;

  /**
   * 获取用户媒体流
   * @param constraints 媒体流约束
   * @returns 媒体流对象
   */
  getUserMedia(constraints: MediaStreamConstraints): Promise<Object>;

  /**
   * 关闭 PeerConnection
   * @param pcId PeerConnection ID
   */
  closePeerConnection(pcId: number): void;

  /**
   * 停止媒体流
   * @param stream 媒体流对象
   */
  stopMediaStream(stream: Object): void;

  /**
   * 释放所有资源
   */
  release(): Promise<void>;
}

/**
 * RTCPeerConnection 接口
 */
export interface IRTCPeerConnection {
  /**
   * 添加本地流
   * @param stream 媒体流对象
   */
  addLocalStream(stream: Object): void;

  /**
   * 移除本地流
   * @param stream 媒体流对象
   */
  removeLocalStream(stream: Object): void;

  /**
   * 创建 Offer
   * @returns SDP Offer
   */
  createOffer(): Promise<SessionDescription>;

  /**
   * 创建 Answer
   * @returns SDP Answer
   */
  createAnswer(): Promise<SessionDescription>;

  /**
   * 设置本地描述
   * @param description SDP 描述
   */
  setLocalDescription(description: SessionDescription): Promise<void>;

  /**
   * 设置远程描述
   * @param description SDP 描述
   */
  setRemoteDescription(description: SessionDescription): Promise<void>;

  /**
   * 添加 ICE Candidate
   * @param candidate ICE Candidate
   */
  addIceCandidate(candidate: IceCandidate): Promise<void>;

  /**
   * 关闭连接
   */
  close(): void;
}

/**
 * 权限助手接口
 */
export interface IPermissionHelper {
  /**
   * 初始化权限助手
   * @param context 应用上下文
   */
  initialize(context: common.UIAbilityContext): void;

  /**
   * 请求通话相关权限
   * @returns 权限请求结果数组
   */
  requestCallPermissions(): Promise<PermissionResult[]>;

  /**
   * 检查是否有通话权限
   * @returns 是否有权限
   */
  hasCallPermissions(): Promise<boolean>;
}

/**
 * 音频焦点助手接口
 */
export interface IAudioFocusHelper {
  /**
   * 请求音频焦点
   * @param type 音频焦点类型
   */
  requestAudioFocus(type: number): Promise<void>;

  /**
   * 放弃音频焦点
   */
  abandonAudioFocus(): Promise<void>;

  /**
   * 获取实例（单例模式）
   */
  getInstance(): IAudioFocusHelper;
}

/**
 * 音频焦点类型枚举
 */
export enum AudioFocusType {
  CALL = 3,      // 通话
  MEDIA = 2,     // 媒体播放
  NAVIGATION = 1 // 导航
}

/**
 * WebRTC 工具类（占位实现）
 * 
 * 注意：这是 WebRTC 桥接模块的占位实现
 * 实际使用时需要替换为真正的 WebRTC 引擎
 */
export class WebRTCUtils {
  private static instance: WebRTCUtils | null = null;

  protected constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): WebRTCUtils {
    if (!WebRTCUtils.instance) {
      WebRTCUtils.instance = new WebRTCUtils();
    }
    return WebRTCUtils.instance;
  }

  /**
   * 检查 WebRTC 是否可用
   */
  public async isWebRTCAvailable(): Promise<boolean> {
    // TODO: 实现 WebRTC 可用性检查
    return false;
  }

  /**
   * 获取默认 ICE 服务器配置
   */
  public getDefaultIceServers(): IceServerConfig[] {
    return [
      { urls: ['stun:stun.l.google.com:19302'] },
      { urls: ['stun:stun1.l.google.com:19302'] },
      { urls: ['stun:stun2.l.google.com:19302'] },
      { urls: ['stun:stun3.l.google.com:19302'] }
    ];
  }

  /**
   * 解析 SDP 中的编解码器信息
   */
  public parseCodecs(sdp: string): string[] {
    const codecs: string[] = [];
    const lines = sdp.split('\r\n');
    
    for (const line of lines) {
      if (line.startsWith('a=rtpmap:')) {
        const parts = line.split(' ');
        if (parts.length > 1 && parts[1].includes('/')) {
          const codecName = parts[1].split('/')[0];
          codecs.push(codecName);
        }
      }
    }
    
    return codecs;
  }

  /**
   * 修改 SDP 以优化通话质量
   */
  public modifySdpForCall(sdp: string): string {
    // TODO: 实现 SDP 优化逻辑
    // 例如：优先选择 Opus 编解码器、调整比特率等
    return sdp;
  }

  /**
   * 清理 WebRTC 资源
   */
  public async cleanup(): Promise<void> {
    // TODO: 实现资源清理逻辑
  }
}
