/**
 * 菜单项接口
 * 用于展开菜单、气泡菜单等组件
 */
export interface MenuItem {
  text: string;
  action: () => void;
}

/**
 * 菜单位置选项
 */
export interface MenuPosition {
  x: string | number;
  y: string | number;
}

/**
 * 构建展开菜单组件
 * @param menuItems 菜单项数组
 * @param position 菜单位置（默认为右上角）
 * @param onDismiss 菜单关闭回调
 */
@Builder
export function buildExpandedMenu(
  menuItems: MenuItem[],
  position: MenuPosition = { x: '100%', y: 56 },
  onDismiss?: () => void
) {
  Column() {
    Column({ space: 0 }) {
      // 动态渲染菜单项
      ForEach(menuItems, (menuItem: MenuItem, itemIndex: number) => {
        // 菜单项
        Row() {
          Text(menuItem.text)
            .fontSize(16)
            .fontColor('#000000')
            .layoutWeight(1)
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          menuItem.action();
          onDismiss?.();
        })
        // 在第一个菜单项下方添加分隔线（灰条）
        if (itemIndex === 0 && menuItems.length > 1) {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#F2F2F7')
        }
      }, (menuItem: MenuItem, itemIndex: number) => itemIndex.toString())
    }
    .width(200)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.2)',
      offsetY: 4
    })
  }
  .position({ x: position.x, y: position.y })
  .translate({ x: typeof position.x === 'string' && position.x === '100%' ? -220 : 0, y: 0 })
  .zIndex(101)
}

/**
 * 构建菜单遮罩层（透明背景，点击关闭）
 * @param onDismiss 点击遮罩层时的回调
 */
@Builder
export function buildMenuOverlay(onDismiss: () => void) {
  Column()
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0)')
    .onClick(() => {
      onDismiss();
    })
}

/**
 * 构建完整的菜单弹窗（包含遮罩层和菜单）
 * @param menuItems 菜单项数组
 * @param position 菜单位置
 * @param onDismiss 菜单关闭回调
 */
@Builder
export function buildMenuPopup(
  menuItems: MenuItem[],
  position: MenuPosition = { x: '100%', y: 56 },
  onDismiss: () => void
) {
  Stack() {
    // 透明遮罩层
    buildMenuOverlay(onDismiss)

    // 菜单内容
    buildExpandedMenu(menuItems, position, onDismiss)
  }
  .width('100%')
  .height('100%')
  .zIndex(100)
}
