/**
 * Components UI 组件库统一导出入口
 * 
 * 架构说明:
 * - auth/: 认证相关组件
 * - bots/: Bot 相关组件
 * - call/: 通话相关组件
 * - channels/: 频道相关组件
 * - chat/: 聊天相关组件（消息、输入、列表）
 * - contacts/: 联系人相关组件
 * - groups/: 群组相关组件
 * - media/: 媒体播放相关组件
 * - monetization/: 商业化相关组件
 * - privacy/: 隐私相关组件
 * - settings/: 设置相关组件
 * - stickers/: 贴纸相关组件
 * - stories/: 故事相关组件
 * 
 * 使用方式:
 * 1. 全量导入：import { ChatListItem, MessageBubble } from '../components'
 * 2. 按模块导入：import { ChatListItem } from '../components/chat'
 * 3. 按需导入：import { MessageBubble } from '../components/chat/MessageBubble'
 */

// ==================== Auth Components - 认证组件 ====================
export { CodeInputField } from './auth/CodeInputField';
export { CountdownButton } from './auth/CountdownButton';
export { PasswordStrengthMeter } from './auth/PasswordStrengthMeter';
export { PhoneInputField } from './auth/PhoneInputField';
export { TermsOfService } from './auth/TermsOfService';

// ==================== Bots Components - Bot 组件 ====================
export { BotMessageView } from './bots/BotMessageView';
export { CommandButton } from './bots/CommandButton';
export { GameView } from './bots/GameView';
export { InlineKeyboard } from './bots/InlineKeyboard';

// ==================== Call Components - 通话组件 ====================
export { AudioWaveform } from './call/AudioWaveform';
export { CallControls } from './call/CallControls';
export { VideoView } from './call/VideoView';

// ==================== Channels Components - 频道组件 ====================
export { ChannelCard } from './channels/ChannelCard';
export { ChannelGridItem } from './channels/ChannelGridItem';
export { ChannelListItem } from './channels/ChannelListItem';
export { PostItem } from './channels/PostItem';

// ==================== Chat Components - 聊天组件 ====================
// 聊天列表和消息
export { ChatListItem } from './chat/chat/ChatListItem';
export { DateSeparator } from './chat/chat/DateSeparator';
export { SecretChatIndicator } from './chat/chat/SecretChatIndicator';
export { UnreadBadge } from './chat/chat/UnreadBadge';

// 消息输入
export { AttachmentMenu } from './chat/input/AttachmentMenu';
export { EmojiPanel } from './chat/input/EmojiPanel';
export { MessageInputBar } from './chat/input/MessageInputBar';
export { VoiceInput } from './chat/input/VoiceInput';

// 消息类型视图
export { ContactMessageView } from './chat/message/ContactMessageView';
export { FileMessageView } from './chat/message/FileMessageView';
export { ImageMessageView } from './chat/message/ImageMessageView';
export { LocationMessageView } from './chat/message/LocationMessageView';
export { MessageStatusIndicator } from './chat/message/MessageStatusIndicator';
export { ReactionMessageView } from './chat/message/ReactionMessageView';
export { StickerMessageView } from './chat/message/StickerMessageView';
export { SystemMessageView } from './chat/message/SystemMessageView';
export { VideoMessageView } from './chat/message/VideoMessageView';
export { VoiceMessageView } from './chat/message/VoiceMessageView';

// 消息气泡
export { FileMessageBubble } from './chat/FileMessageBubble';
export { ImageMessageBubble } from './chat/ImageMessageBubble';
export { MessageBubble } from './chat/MessageBubble';
export { MessageInput } from './chat/MessageInput';
export { VoiceMessageBubble } from './chat/VoiceMessageBubble';

// ==================== Contacts Components - 联系人组件 ====================
export { ContactAvatar } from './contacts/ContactAvatar';
export { ContactListItem } from './contacts/ContactListItem';
export { QuickIndexBar } from './contacts/QuickIndexBar';
export { SectionHeader } from './contacts/SectionHeader';

// ==================== Groups Components - 群组组件 ====================
export { GroupAvatar } from './groups/GroupAvatar';
export { InviteLinkCard } from './groups/InviteLinkCard';
export { MemberItem } from './groups/MemberItem';

// ==================== Media Components - 媒体组件 ====================
export { MediaPreview } from './media/MediaPreview';
export { PlayerControls } from './media/PlayerControls';
export { VideoPlayer } from './media/VideoPlayer';

// ==================== Monetization Components - 商业化组件 ====================
export { RevenueCard } from './monetization/RevenueCard';
export { WithdrawalForm } from './monetization/WithdrawalForm';

// ==================== Privacy Components - 隐私组件 ====================
export { PrivacyToggle } from './privacy/PrivacyToggle';
export { SecurityLevel } from './privacy/SecurityLevel';

// ==================== Settings Components - 设置组件 ====================
export { CacheUsageCard } from './settings/CacheUsageCard';
export { DataUsageCard } from './settings/DataUsageCard';
export { SettingItem } from './settings/SettingItem';
export { SliderSetting } from './settings/SliderSetting';
export { SwitchSetting } from './settings/SwitchSetting';

// ==================== Stickers Components - 贴纸组件 ====================
export { StickerGrid } from './stickers/StickerGrid';
export { StickerPanel } from './stickers/StickerPanel';

// ==================== Stories Components - 故事组件 ====================
export { StoryFilter } from './stories/StoryFilter';
export { StoryProgress } from './stories/StoryProgress';
export { StoryReaction } from './stories/StoryReaction';
