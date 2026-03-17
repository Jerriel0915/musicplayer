/**
 * 播放进度条组件
 */

import { TimeUtil } from '../utils/TimeUtil';

@Component
export struct ProgressBar {
  // 当前时间（毫秒）
  @Prop @Watch('onProgressChange') currentTime: number = 0;
  // 总时长（毫秒）
  @Prop @Watch('onProgressChange') duration: number = 0;
  // 是否可拖动
  @Prop seekable: boolean = true;
  // 进度条高度
  @Prop barHeight: number = 4;
  // 滑块大小
  @Prop thumbSize: number = 12;
  // 进度条颜色
  @Prop progressColor: ResourceColor = '#FF4081';
  // 背景颜色
  @Prop barBgColor: ResourceColor = 'rgba(255,255,255,0.3)';
  // 拖动回调
  onSeek?: (position: number) => void;
  // 内部状态
  @State private isDragging: boolean = false;
  @State private dragProgress: number = 0;
  @State private progressValue: number = 0;

  // 监听进度变化
  private onProgressChange() {
    const newProgress = this.duration > 0 ? this.currentTime / this.duration : 0;
    this.progressValue = newProgress;
    console.info(`ProgressBar 进度更新: ${this.currentTime}/${this.duration} = ${newProgress}`);
  }

  build() {
    Row() {
      // 当前时间
      Text(TimeUtil.formatDuration(this.isDragging ? this.dragProgress * this.duration : this.currentTime))
        .fontSize(12)
        .fontColor('#FFFFFF')
        .width(45)
        .textAlign(TextAlign.Start)

      // 进度条容器
      Stack({ alignContent: Alignment.Start }) {
        // 背景条
        Row()
          .width('100%')
          .height(this.barHeight)
          .backgroundColor(this.barBgColor)
          .borderRadius(this.barHeight / 2)

        // 进度条（带滑块）
        Row() {
          // 已播放部分
          Row()
            .layoutWeight(1)
            .height(this.barHeight)
            .backgroundColor(this.progressColor)
            .borderRadius(this.barHeight / 2)

          // 滑块
          Row()
            .width(this.thumbSize)
            .height(this.thumbSize)
            .backgroundColor('#FFFFFF')
            .borderRadius(this.thumbSize / 2)
            .shadow({ radius: 2, color: 'rgba(0,0,0,0.3)' })
            .margin({ left: -this.thumbSize / 2 })
            .visibility(this.seekable ? Visibility.Visible : Visibility.Hidden)
        }
        .width(`${(this.isDragging ? this.dragProgress : this.progressValue) * 100}%`)
        .height('100%')
      }
      .width(0)
      .layoutWeight(1)
      .height(20)
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            if (this.seekable) {
              this.isDragging = true;
              this.dragProgress = this.progressValue;
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            if (this.seekable && this.isDragging) {
              // 计算新的进度
              const componentWidth = event.target.area.width as number;
              if (componentWidth > 0 && event.fingerList.length > 0) {
                // 通过fingerList获取相对于组件左上角的坐标
                const fingerInfo = event.fingerList[0];
                const currentX = fingerInfo.localX as number;
                const newProgress = Math.max(0, Math.min(1, currentX / componentWidth));
                this.dragProgress = newProgress;
              }
            }
          })
          .onActionEnd(() => {
            if (this.seekable && this.isDragging) {
              this.isDragging = false;
              // 触发回调
              if (this.onSeek && this.duration > 0) {
                this.onSeek(this.dragProgress * this.duration);
              }
            }
          })
      )
      .onClick((event: ClickEvent) => {
        if (this.seekable && this.duration > 0) {
          const componentWidth = event.target.area.width as number;
          if (componentWidth > 0) {
            const clickProgress = event.x / componentWidth;
            if (this.onSeek) {
              this.onSeek(clickProgress * this.duration);
            }
          }
        }
      })

      // 总时长
      Text(TimeUtil.formatDuration(this.duration))
        .fontSize(12)
        .fontColor('#FFFFFF')
        .width(45)
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .height(30)
    .padding({ left: 16, right: 16 })
  }
}
