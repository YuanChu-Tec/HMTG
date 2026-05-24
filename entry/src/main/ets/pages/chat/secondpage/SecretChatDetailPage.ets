// file: SecretChatDetailPage.ets - 私密聊天详情页
/**
 * 私密聊天详情页
 * 显示和编辑私密聊天信息，包括加密状态、密钥验证等
 */

import { router } from '@kit.ArkUI';
import { Chat } from '../../../models/TDLibData';
import { CoreService } from '../../../services/business/CoreService';
import { Avatar, ThemeManager } from '../../../ui_kit';
import { logger } from '../../../utils/log/LogService';
import { BusinessError, BusinessErrorCode } from '../../../utils/error/BusinessError';
import { TDLibApi, createTdLibAPIs } from '../../../services/api';

/**
 * 私密聊天状态
 */
interface SecretChatState {
  id: number;
  userId: number;
  state: 'pending' | 'ready' | 'closed';
  keyHash?: string;
  layer: number;
  ttl: number;
}

/**
 * 路由参数接口
 */
interface RouterParams {
  chatId: number;
  chatTitle: string;
}

/**
 * 私密聊天主题颜色接口
 */
interface SecretThemeColors {
  background: string;
  surface: string;
  text: string;
  textSecondary: string;
  textHint: string;
  primary: string;
  success: string;
  warning: string;
  danger: string;
  divider: string;
}

@Entry({ routeName: 'SecretChatDetailPage' })
@ComponentV2
export struct SecretChatDetailPage {
  @Local chatId: number = 0;
  @Local chat: Chat | null = null;
  @Local secretChatState: SecretChatState | null = null;
  @Local isLoading: boolean = true;
  @Local showKeyHash: boolean = false;
  @Local showTtlDialog: boolean = false;
  @Local newTtlValue: number = 30;

  private readonly TAG = 'SecretChatDetailPage';
  private CoreService: CoreService = CoreService.getInstance();
  private tdLibApi: TDLibApi | null = null;

  private theme: SecretThemeColors = {
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#000000',
    textSecondary: '#666666',
    textHint: '#999999',
    primary: '#0088CC',
    success: '#4CAF50',
    warning: '#FF9800',
    danger: '#FF4444',
    divider: '#E0E0E0'
  };

  aboutToAppear(): void {
    this.initializeTheme();
    this.initializeTdLibAPIs();
    this.loadRouteParams();
    this.loadChatInfo();
  }

  aboutToDisappear(): void {
    this.cleanup();
  }

  /**
   * 初始化主题
   */
  private initializeTheme(): void {
    const currentTheme = ThemeManager.getInstance().getCurrentTheme();
    const colors = currentTheme.tokens.colors;

    const newTheme: SecretThemeColors = {
      background: colors.surface,
      surface: colors.primary,
      text: colors.text,
      textSecondary: colors.textSecondary,
      textHint: colors.border,
      primary: colors.primary,
      success: colors.success,
      warning: colors.warning,
      danger: colors.error,
      divider: colors.divider
    };
    this.theme = newTheme;
  }

  /**
   * 初始化 TDLib APIs
   */
  private async initializeTdLibAPIs(): Promise<void> {
    try {
      this.tdLibApi = await createTdLibAPIs();
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to initialize TDLib APIs');
    }
  }

  /**
   * 加载路由参数
   */
  private loadRouteParams(): void {
    try {
      const params = router.getParams() as RouterParams;
      if (params) {
        this.chatId = Number(params.chatId) || 0;
      }
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to load route params');
    }
  }

  /**
   * 加载聊天信息
   */
  private async loadChatInfo(): Promise<void> {
    if (this.chatId === 0) {
      this.isLoading = false;
      return;
    }

    this.isLoading = true;

    try {
      const chat = await this.CoreService.getChat(this.chatId);
      if (chat) {
        this.chat = chat;
        await this.loadSecretChatState();
      }
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to load chat info');
      throw new BusinessError(BusinessErrorCode.CHAT_NOT_FOUND, '加载聊天信息失败', '加载聊天信息失败');
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载私密聊天状态
   */
  private async loadSecretChatState(): Promise<void> {
    if (!this.chat || !this.chat.secretChatId || !this.tdLibApi) {
      return;
    }

    try {
      const result = await this.tdLibApi.getSecretChat(this.chat.secretChatId);
      
      if (result) {
        // 使用 JSON 序列化/反序列化方式来创建纯数据对象，避免类型转换问题
        const jsonStr = JSON.stringify(result);
        const resultObj: Record<string, Object> = JSON.parse(jsonStr);
        const typeObj = resultObj['type'] as Record<string, Object> | undefined;

        if (typeObj) {
          const stateValue = typeObj['state'] as string || 'pending';
          this.secretChatState = {
            id: this.chat.secretChatId,
            userId: this.chat.id,
            state: stateValue === 'ready' ? 'ready' :
                   stateValue === 'closed' ? 'closed' : 'pending',
            layer: (typeObj['layer'] as number) || 0,
            ttl: (typeObj['ttl'] as number) || 0
          };
        }
      }
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to load secret chat state');
    }
  }

  /**
   * 关闭私密聊天
   */
  private async closeSecretChat(): Promise<void> {
    if (!this.tdLibApi || !this.chat?.secretChatId) {
      return;
    }

    try {
      await this.tdLibApi.closeSecretChat(this.chat.secretChatId);
      if (this.secretChatState) {
        this.secretChatState.state = 'closed';
      }
      router.back();
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to close secret chat');
      throw new BusinessError(BusinessErrorCode.OPERATION_FAILED, '关闭聊天失败', '关闭聊天失败');
    }
  }

  /**
   * 设置消息自动销毁时间
   * 注意：此功能需要 TDLib 后端支持
   */
  private async setTtl(seconds: number): Promise<void> {
    if (!this.tdLibApi || !this.chatId) {
      return;
    }
  
    try {
      await this.tdLibApi.setChatMessageAutoDeleteTime(this.chatId, seconds);
      if (this.secretChatState) {
        this.secretChatState.ttl = seconds;
      }
      this.showTtlDialog = false;
    } catch (error) {
      logger.error(0x0001, this.TAG, 'Failed to set TTL', error);
      throw new BusinessError(BusinessErrorCode.OPERATION_FAILED, '设置自动销毁时间失败', '设置自动销毁时间失败');
    }
  }

  /**
   * 获取状态文本
   */
  private getStateText(): string {
    if (!this.secretChatState) {
      return '未知';
    }

    switch (this.secretChatState.state) {
      case 'pending':
        return '等待对方确认';
      case 'ready':
        return '加密会话已建立';
      case 'closed':
        return '会话已关闭';
      default:
        return '未知';
    }
  }

  /**
   * 获取状态颜色
   */
  private getStateColor(): string {
    if (!this.secretChatState) {
      return this.theme.textSecondary;
    }

    switch (this.secretChatState.state) {
      case 'pending':
        return this.theme.warning;
      case 'ready':
        return this.theme.success;
      case 'closed':
        return this.theme.danger;
      default:
        return this.theme.textSecondary;
    }
  }

  /**
   * 格式化 TTL
   */
  private formatTtl(seconds: number): string {
    if (seconds === 0) {
      return '不自动销毁';
    }

    if (seconds < 60) {
      return `${seconds}秒`;
    } else if (seconds < 3600) {
      const mins = Math.floor(seconds / 60);
      return `${mins}分钟`;
    } else if (seconds < 86400) {
      const hours = Math.floor(seconds / 3600);
      return `${hours}小时`;
    } else {
      const days = Math.floor(seconds / 86400);
      return `${days}天`;
    }
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    // 清理逻辑
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader()

      // 内容区域
      if (this.isLoading) {
        this.buildLoadingView()
      } else if (!this.chat || !this.secretChatState) {
        this.buildEmptyView()
      } else {
        Scroll() {
          Column() {
            // 用户信息
            this.buildUserInfo()

            Divider()
              .color(this.theme.divider)
              .margin({ top: 16 })

            // 加密状态
            this.buildEncryptionStatus()

            Divider()
              .color(this.theme.divider)
              .margin({ top: 16 })

            // 密钥信息
            this.buildKeyInfo()

            Divider()
              .color(this.theme.divider)
              .margin({ top: 16 })

            // 消息设置
            this.buildMessageSettings()

            Divider()
              .color(this.theme.divider)
              .margin({ top: 16 })

            // 操作按钮
            this.buildActionButtons()
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.theme.background)
  }

  @Builder
  buildHeader() {
    Row() {
      Text('私密聊天信息')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.theme.text)

      Blank()
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      router.back();
    })
  }

  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color(this.theme.primary)

      Text('加载中...')
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildEmptyView() {
    Column() {
      Text('聊天不存在')
        .fontSize(16)
        .fontColor(this.theme.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildUserInfo() {
    Row() {
      if (this.chat?.avatar && this.chat.avatar.length > 0) {
        Avatar({
          source: this.chat.avatar,
          name: this.chat.title,
          avatarSize: 64
        })
      } else {
        Text(this.chat?.title?.charAt(0) || '?')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.theme.primary)
          .width(64)
          .height(64)
          .textAlign(TextAlign.Center)
          .borderRadius(32)
          .backgroundColor(this.theme.surface)
      }

      Column() {
        Text(this.chat?.title || '')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme.text)
          .margin({ bottom: 4 })

        Text(`ID: ${this.chatId}`)
          .fontSize(14)
          .fontColor(this.theme.textSecondary)
      }
      .layoutWeight(1)
      .margin({ left: 16 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  buildEncryptionStatus() {
    Column() {
      Row() {
        Text('🔒')
          .fontSize(24)
          .margin({ right: 8 })

        Text('加密状态')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme.text)

        Blank()

        Text(this.getStateText())
          .fontSize(14)
          .fontColor(this.getStateColor())
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)

      if (this.secretChatState) {
        Row() {
          Text(`加密层: ${this.secretChatState.layer}`)
            .fontSize(14)
            .fontColor(this.theme.textSecondary)
            .layoutWeight(1)

          if (this.secretChatState.ttl > 0) {
            Text(`自动销毁: ${this.formatTtl(this.secretChatState.ttl)}`)
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
          } else {
            Text('消息自动销毁: 关闭')
              .fontSize(14)
              .fontColor(this.theme.textSecondary)
          }
        }
        .width('100%')
        .height(32)
      }
    }
    .width('100%')
  }

  @Builder
  buildKeyInfo() {
    Column() {
      Row() {
        Text('🔑')
          .fontSize(24)
          .margin({ right: 8 })

        Text('密钥信息')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme.text)

        Blank()
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)

      if (this.showKeyHash && this.secretChatState?.keyHash) {
        Text(this.secretChatState.keyHash)
          .fontSize(12)
          .fontColor(this.theme.textSecondary)
          .width('100%')
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      } else {
        Text('密钥哈希用于验证加密连接')
          .fontSize(14)
          .fontColor(this.theme.textHint)
          .width('100%')
      }

      Row() {
        Text('显示密钥哈希')
          .fontSize(14)
          .fontColor(this.theme.primary)
          .onClick(() => {
            this.showKeyHash = !this.showKeyHash;
          })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
  }

  @Builder
  buildMessageSettings() {
    Column() {
      Row() {
        Text('⏱️')
          .fontSize(24)
          .margin({ right: 8 })

        Text('消息设置')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.theme.text)

        Blank()
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)

      Row() {
        Text('消息自动销毁时间')
          .fontSize(14)
          .fontColor(this.theme.textSecondary)
          .layoutWeight(1)

        if (this.secretChatState) {
          Text(this.formatTtl(this.secretChatState.ttl))
            .fontSize(14)
            .fontColor(this.theme.text)
        }

        Text('更改')
          .fontSize(14)
          .fontColor(this.theme.primary)
          .margin({ left: 8 })
          .onClick(() => {
            this.showTtlDialog = true;
          })
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
  }

  @Builder
  buildActionButtons() {
    Column() {
      Button('设置消息自动销毁')
        .fontSize(16)
        .fontColor(this.theme.primary)
        .backgroundColor(Color.Transparent)
        .width('100%')
        .height(48)
        .onClick(() => {
          this.showTtlDialog = true;
        })

      Divider()
        .color(this.theme.divider)

      Button('关闭私密聊天')
        .fontSize(16)
        .fontColor(this.theme.danger)
        .backgroundColor(Color.Transparent)
        .width('100%')
        .height(48)
        .onClick(() => {
          this.closeSecretChat();
        })
    }
    .width('100%')
  }
}
