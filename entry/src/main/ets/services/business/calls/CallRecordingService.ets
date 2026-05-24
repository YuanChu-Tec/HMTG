/**
 * Call Recording Service
 *
 * 通话录制功能实现
 * 使用 MediaRecorder 进行通话音视频录制
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';
import { promptAction } from '@kit.ArkUI';

const DOMAIN = 0x0001;
const TAG = 'CallRecordingService';

/**
 * 媒体录制器接口
 */
interface MediaRecorderType {
  prepare: () => Promise<void>;
  start: () => Promise<void>;
  stop: () => Promise<void>;
  pause: () => void;
  resume: () => void;
  release: () => Promise<void>;
}

/**
 * 媒体录制器实现类（占位符）
 */
class MockMediaRecorder implements MediaRecorderType {
  async prepare(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Media recorder prepared');
  }

  async start(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Media recorder started');
  }

  async stop(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Media recorder stopped');
  }

  pause(): void {
    hilog.info(DOMAIN, TAG, 'Media recorder paused');
  }

  resume(): void {
    hilog.info(DOMAIN, TAG, 'Media recorder resumed');
  }

  async release(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Media recorder released');
  }
}

/**
 * 媒体录制器配置接口
 */
interface MediaRecorderProfile {
  audioBitrate: number;
  audioChannels: number;
  audioCodec: string;
  audioSampleRate: number;
  fileFormat: string;
  videoBitrate: number;
  videoCodec: string;
  videoFrameWidth: number;
  videoFrameHeight: number;
  videoFrameRate: number;
}

/**
 * 媒体录制器配置接口
 */
interface MediaRecorderConfig {
  audioSourceType: number;
  videoSourceType: number;
  profile: MediaRecorderProfile;
  url: string;
  rotation: number;
}

/**
 * 录制配置
 */
export interface RecordingConfig {
  audioEnabled: boolean;
  videoEnabled: boolean;
  outputPath: string;
  maxFileSize: number; // 字节
  maxDuration: number; // 秒
  quality: 'low' | 'medium' | 'high';
}

/**
 * 录制状态
 */
export enum RecordingState {
  IDLE = 'idle',
  PREPARING = 'preparing',
  RECORDING = 'recording',
  PAUSED = 'paused',
  STOPPING = 'stopping',
  ERROR = 'error'
}

/**
 * 录制信息
 */
export interface RecordingInfo {
  id: string;
  callId: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  filePath?: string;
  fileSize?: number;
  state: RecordingState;
}

/**
 * 通话录制服务
 */
export class CallRecordingService {
  private static instance: CallRecordingService;
  private state: RecordingState = RecordingState.IDLE;
  private config: RecordingConfig;
  private mediaRecorder?: MediaRecorderType;
  private currentRecording?: RecordingInfo;
  private recordings: RecordingInfo[] = [];

  private constructor() {
    this.config = this.getDefaultConfig();
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): CallRecordingService {
    if (!CallRecordingService.instance) {
      CallRecordingService.instance = new CallRecordingService();
    }
    return CallRecordingService.instance;
  }

  /**
   * 获取默认配置
   */
  private getDefaultConfig(): RecordingConfig {
    return {
      audioEnabled: true,
      videoEnabled: true,
      outputPath: '/data/storage/el2/base/haps/entry/files/recordings/',
      maxFileSize: 500 * 1024 * 1024, // 500 MB
      maxDuration: 3600, // 1 小时
      quality: 'medium'
    };
  }

  /**
   * 配置录制
   */
  public configure(config: Partial<RecordingConfig>): void {
    // 手动逐个属性赋值以规避 Object.assign 和展开运算符
    if (config.audioEnabled !== undefined) {
      this.config.audioEnabled = config.audioEnabled;
    }
    if (config.videoEnabled !== undefined) {
      this.config.videoEnabled = config.videoEnabled;
    }
    if (config.outputPath !== undefined) {
      this.config.outputPath = config.outputPath;
    }
    if (config.maxFileSize !== undefined) {
      this.config.maxFileSize = config.maxFileSize;
    }
    if (config.maxDuration !== undefined) {
      this.config.maxDuration = config.maxDuration;
    }
    if (config.quality !== undefined) {
      this.config.quality = config.quality;
    }
    hilog.info(DOMAIN, TAG, `Recording configured: ${JSON.stringify(this.config)}`);
  }

  /**
   * 获取当前状态
   */
  public getState(): RecordingState {
    return this.state;
  }

  /**
   * 判断是否正在录制
   */
  public isRecording(): boolean {
    return this.state === RecordingState.RECORDING;
  }

  /**
   * 开始录制
   */
  public async startRecording(callId: string, context: common.UIAbilityContext): Promise<RecordingInfo | null> {
    try {
      hilog.info(DOMAIN, TAG, `Starting recording for call ${callId}`);

      if (this.state === RecordingState.RECORDING) {
        hilog.warn(DOMAIN, TAG, 'Recording already active');
        return null;
      }

      this.state = RecordingState.PREPARING;

      // 1. 检查并请求录制权限
      const hasPermission = await this.checkRecordingPermission(context);
      if (!hasPermission) {
        hilog.error(DOMAIN, TAG, 'Recording permission denied');
        this.state = RecordingState.ERROR;
        return null;
      }

      // 2. 创建输出目录
      await this.ensureOutputDirectory();

      // 3. 生成输出文件路径
      const filePath = await this.generateOutputFilePath(callId);

      // 4. 创建媒体录制器
      this.mediaRecorder = await this.createMediaRecorder(filePath);

      if (!this.mediaRecorder) {
        throw new Error('Failed to create media recorder');
      }

      // 5. 配置录制参数
      await this.configureMediaRecorder(this.mediaRecorder);

      // 6. 准备录制
      await this.mediaRecorder.prepare();

      // 7. 启动录制
      await this.mediaRecorder.start();

      // 8. 创建录制信息
      this.currentRecording = {
        id: `recording-${Date.now()}`,
        callId: callId,
        startTime: Date.now(),
        filePath: filePath,
        state: RecordingState.RECORDING
      };

      // 9. 添加到录制列表
      this.recordings.push(this.currentRecording);

      this.state = RecordingState.RECORDING;
      hilog.info(DOMAIN, TAG, 'Recording started successfully');

      // 10. 显示录制提示
      this.showRecordingNotification(true);

      return this.currentRecording;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to start recording: ${error}`);
      this.state = RecordingState.ERROR;
      return null;
    }
  }

  /**
   * 停止录制
   */
  public async stopRecording(): Promise<RecordingInfo | null> {
    try {
      hilog.info(DOMAIN, TAG, 'Stopping recording');

      if (this.state !== RecordingState.RECORDING && this.state !== RecordingState.PAUSED) {
        hilog.warn(DOMAIN, TAG, 'No active recording to stop');
        return null;
      }

      this.state = RecordingState.STOPPING;

      if (!this.mediaRecorder || !this.currentRecording) {
        throw new Error('No active recorder or recording info');
      }

      // 停止录制
      await this.mediaRecorder.stop();

      // 释放录制器
      await this.mediaRecorder.release();
      this.mediaRecorder = undefined;

      // 更新录制信息
      this.currentRecording.endTime = Date.now();
      this.currentRecording.duration = this.currentRecording.endTime - this.currentRecording.startTime;
      this.currentRecording.state = RecordingState.IDLE;

      // 获取文件大小
      if (this.currentRecording.filePath) {
        this.currentRecording.fileSize = await this.getFileSize(this.currentRecording.filePath);
      }

      this.state = RecordingState.IDLE;
      hilog.info(DOMAIN, TAG, `Recording stopped. Duration: ${this.currentRecording.duration}ms`);

      // 显示录制结束提示
      this.showRecordingNotification(false);

      return this.currentRecording;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to stop recording: ${error}`);
      this.state = RecordingState.ERROR;
      return null;
    }
  }

  /**
   * 暂停录制
   */
  public pauseRecording(): boolean {
    try {
      hilog.info(DOMAIN, TAG, 'Pausing recording');

      if (this.state !== RecordingState.RECORDING) {
        hilog.warn(DOMAIN, TAG, 'Cannot pause: not recording');
        return false;
      }

      if (!this.mediaRecorder) {
        throw new Error('No active recorder');
      }

      // 暂停录制
      this.mediaRecorder.pause();

      this.state = RecordingState.PAUSED;
      hilog.info(DOMAIN, TAG, 'Recording paused');

      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to pause recording: ${error}`);
      return false;
    }
  }

  /**
   * 恢复录制
   */
  public resumeRecording(): boolean {
    try {
      hilog.info(DOMAIN, TAG, 'Resuming recording');

      if (this.state !== RecordingState.PAUSED) {
        hilog.warn(DOMAIN, TAG, 'Cannot resume: not paused');
        return false;
      }

      if (!this.mediaRecorder) {
        throw new Error('No active recorder');
      }

      // 恢复录制
      this.mediaRecorder.resume();

      this.state = RecordingState.RECORDING;
      hilog.info(DOMAIN, TAG, 'Recording resumed');

      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to resume recording: ${error}`);
      return false;
    }
  }

  /**
   * 获取当前录制信息
   */
  public getCurrentRecording(): RecordingInfo | undefined {
    return this.currentRecording;
  }

  /**
   * 获取所有录制列表
   */
  public getRecordings(): RecordingInfo[] {
    return [...this.recordings];
  }

  /**
   * 删除录制
   */
  public async deleteRecording(recordingId: string): Promise<boolean> {
    try {
      hilog.info(DOMAIN, TAG, `Deleting recording ${recordingId}`);

      const recording = this.recordings.find(r => r.id === recordingId);
      if (!recording) {
        hilog.warn(DOMAIN, TAG, `Recording ${recordingId} not found`);
        return false;
      }

      // 删除文件
      if (recording.filePath) {
        await fileIo.unlink(recording.filePath);
      }

      // 从列表中移除
      this.recordings = this.recordings.filter(r => r.id !== recordingId);

      hilog.info(DOMAIN, TAG, `Recording ${recordingId} deleted`);
      return true;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to delete recording: ${error}`);
      return false;
    }
  }

  /**
   * 清理资源
   */
  public async cleanup(): Promise<void> {
    hilog.info(DOMAIN, TAG, 'Cleaning up recording service');

    if (this.state === RecordingState.RECORDING || this.state === RecordingState.PAUSED) {
      await this.stopRecording();
    }

    this.mediaRecorder = undefined;
    this.currentRecording = undefined;
    this.state = RecordingState.IDLE;
  }

  /**
   * 检查录制权限
   */
  private async checkRecordingPermission(context: common.UIAbilityContext): Promise<boolean> {
    try {
      // 在实际场景中，这里会检查录制权限
      // 使用 @ohos.abilityAccessCtrl 检查权限状态

      hilog.info(DOMAIN, TAG, 'Recording permission check');
      return true; // 假设已有权限
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to check recording permission: ${error}`);
      return false;
    }
  }

  /**
   * 确保输出目录存在
   */
  private async ensureOutputDirectory(): Promise<void> {
    try {
      const dirPath = this.config.outputPath;

      // 检查目录是否存在
      try {
        const stat = await fileIo.stat(dirPath);
        if (!stat.isDirectory()) {
          throw new Error(`${dirPath} is not a directory`);
        }
      } catch (error) {
        // 目录不存在，创建它
        await fileIo.mkdir(dirPath);
        hilog.info(DOMAIN, TAG, `Created directory: ${dirPath}`);
      }
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to ensure output directory: ${error}`);
      throw new Error(String(error));
    }
  }

  /**
   * 生成输出文件路径
   */
  private async generateOutputFilePath(callId: string): Promise<string> {
    const timestamp = Date.now();
    const fileName = `call_${callId}_${timestamp}.mp4`;
    const filePath = this.config.outputPath + fileName;
    hilog.info(DOMAIN, TAG, `Generated output file path: ${filePath}`);
    return filePath;
  }

  /**
   * 创建媒体录制器
   */
  private async createMediaRecorder(filePath: string): Promise<MediaRecorderType> {
    try {
      hilog.info(DOMAIN, TAG, 'Creating media recorder');

      // 在实际场景中，这里会创建媒体录制器
      // 使用 @ohos.multimedia.media.createAVRecorder
      const mediaRecorder = new MockMediaRecorder();

      return mediaRecorder;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to create media recorder: ${error}`);
      throw new Error(String(error));
    }
  }

  /**
   * 配置媒体录制器
   */
  private async configureMediaRecorder(mediaRecorder: MediaRecorderType): Promise<void> {
    try {
      hilog.info(DOMAIN, TAG, 'Configuring media recorder');

      // 在实际场景中，这里会配置录制参数
      // 例如：设置视频编码器、音频编码器、输出格式等

      const config: MediaRecorderConfig = {
        audioSourceType: 1, // 音频源类型
        videoSourceType: 1, // 视频源类型
        profile: {
          audioBitrate: 128000,
          audioChannels: 2,
          audioCodec: 'audio/mp4a-latm',
          audioSampleRate: 48000,
          fileFormat: 'mp4',
          videoBitrate: this.getVideoBitrate(),
          videoCodec: 'video/avc',
          videoFrameWidth: 1920,
          videoFrameHeight: 1080,
          videoFrameRate: 30
        },
        url: this.currentRecording?.filePath || '',
        rotation: 0
      };

      // mediaRecorder.initialize(config);
      hilog.info(DOMAIN, TAG, `Media recorder config: ${JSON.stringify(config)}`);
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to configure media recorder: ${error}`);
      throw new Error(String(error));
    }
  }

  /**
   * 获取视频比特率
   */
  private getVideoBitrate(): number {
    switch (this.config.quality) {
      case 'low':
        return 1000000; // 1 Mbps
      case 'medium':
        return 2000000; // 2 Mbps
      case 'high':
        return 5000000; // 5 Mbps
      default:
        return 2000000;
    }
  }

  /**
   * 获取文件大小
   */
  private async getFileSize(filePath: string): Promise<number> {
    try {
      const stat = await fileIo.stat(filePath);
      return stat.size;
    } catch (error) {
      hilog.error(DOMAIN, TAG, `Failed to get file size: ${error}`);
      return 0;
    }
  }

  /**
   * 显示录制通知
   */
  private showRecordingNotification(isRecording: boolean): void {
    const message = isRecording ? '开始录制' : '录制结束';

    promptAction.showToast({
      message,
      duration: 2000,
      bottom: '50%'
    });
  }
}

/**
 * 导出单例实例
 */
export const callRecordingService = CallRecordingService.getInstance();
