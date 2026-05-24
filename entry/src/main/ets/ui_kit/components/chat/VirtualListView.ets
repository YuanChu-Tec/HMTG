/**
 * 虚拟列表组件
 * 基于List的高性能列表，支持大量数据渲染
 */

@ComponentV2
export struct VirtualListView {

  data: Object[] = [];
  emptyText: string = '暂无数据';
  hasMore: boolean = false;
  loading: boolean = false;
  loadMoreEnabled: boolean = true;

  @BuilderParam itemBuilder: (item: Object, index: number) => void;
  @BuilderParam emptyBuilder?: () => void;
  @BuilderParam footerBuilder?: () => void;
  @BuilderParam loadingBuilder?: () => void;

  onLoadMore?: () => void;

  /**
   * 渲染列表项
   */
  @Builder
  private renderItem(item: Object, index: number): void {
    ListItem() {
      if (this.itemBuilder) {
        this.itemBuilder(item, index);
      }
    }
  }
  
  /**
   * 构建空状态
   */
  @Builder
  private buildEmpty(): void {
    if (this.emptyBuilder) {
      this.emptyBuilder();
    } else {
      Column() {
        Text(this.emptyText)
          .fontSize(16)
          .fontColor('#999999')
          .margin({ top: 40 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    }
  }
  
  /**
   * 构建加载状态
   */
  @Builder
  private buildLoading(): void {
    if (this.loadingBuilder) {
      this.loadingBuilder();
    } else {
      Column() {
        SymbolGlyph($r('sys.symbol.arrow_2_circlepath'))
          .fontSize(40)
          .fontColor(['#999999'])
      }
      .width('100%')
      .padding(20)
      .justifyContent(FlexAlign.Center)
    }
  }
  
  /**
   * 构建底部
   */
  @Builder
  private buildFooter(): void {
    if (this.footerBuilder) {
      this.footerBuilder();
    } else if (this.loadMoreEnabled && this.hasMore && !this.loading) {
      Column() {
        Text('加载更多...')
          .fontSize(14)
          .fontColor('#666666')
          .padding(12)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
  }
  
  build() {
    List({ space: 0 }) {
      if (this.loading && this.data.length === 0) {
        this.buildLoading();
      } else if (this.data.length === 0) {
        this.buildEmpty();
      } else {
        ForEach(this.data, (item: Object, index: number) => {
          this.renderItem(item, index);
        }, (item: Object, index: number) => {
          // 使用唯一标识作为key
          const itemObj = item as Record<string, Object>;
          if (itemObj && itemObj.id) {
            return itemObj.id.toString();
          }
          return index.toString();
        })

        // 底部
        if (this.loadMoreEnabled || this.footerBuilder) {
          ListItem() {
            this.buildFooter()
          }
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .divider({
      strokeWidth: 0.5,
      color: '#F0F0F0',
      startMargin: 16,
      endMargin: 0
    })
    .onReachEnd(() => {
      if (this.loadMoreEnabled && this.hasMore && !this.loading && this.onLoadMore) {
        this.onLoadMore();
      }
    })
  }
}
