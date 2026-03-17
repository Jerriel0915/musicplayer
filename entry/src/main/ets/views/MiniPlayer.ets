/**
 * 底部迷你播放条组件
 */

import { TrackInfo } from '../models/TrackInfo';
import { AudioSvc } from '../services/AudioSvc';
import { PlayMode } from '../constants/AppConstants';
import { emitter } from '@kit.BasicServicesKit';

@Component
export struct MiniPlayer {
  // 当前播放歌曲
  @State currentTrack: TrackInfo | null = null;
  // 是否正在播放
  @State isPlaying: boolean = false;
  // 播放模式
  @State playMode: PlayMode = PlayMode.ORDER;
  // 点击展开全屏播放器回调
  onExpand?: () => void;

  private audioSvc: AudioSvc = AudioSvc.getInstance();

  aboutToAppear() {
    // 初始化状态
    this.updateState();
    
    // 监听播放状态变化
    emitter.on({ eventId: 2 }, () => {
      console.info('MiniPlayer 收到播放状态变化事件');
      this.updateState();
    });
    
    // 监听歌曲变化
    emitter.on({ eventId: 1 }, () => {
      console.info('MiniPlayer 收到歌曲变化事件');
      this.updateState();
    });
  }

  private updateState() {
    this.currentTrack = this.audioSvc.getCurrentTrack();
    this.isPlaying = this.audioSvc.isPlaying();
    this.playMode = this.audioSvc.getPlayMode();
    console.info(`MiniPlayer 状态更新: isPlaying=${this.isPlaying}, track=${this.currentTrack?.title}`);
  }

  build() {
    Row() {
      // 左侧：封面和歌曲信息
      Row() {
        // 封面
        Stack() {
          if (this.currentTrack?.coverUri) {
            Image(this.currentTrack.coverUri)
              .width(40)
              .height(40)
              .borderRadius(4)
              .objectFit(ImageFit.Cover)
          } else {
            Column() {
              Image($r('app.media.icon_music_note'))
                .width(24)
                .height(24)
                .fillColor('#CCCCCC')
            }
            .width(40)
            .height(40)
            .backgroundColor('#F0F0F0')
            .borderRadius(4)
            .justifyContent(FlexAlign.Center)
          }

          // 旋转动画（播放时）
          if (this.isPlaying) {
            Column()
              .width(40)
              .height(40)
              .border({
                width: 2,
                color: '#FF4081',
                style: BorderStyle.Solid
              })
              .borderRadius(4)
              .animation({
                duration: 3000,
                iterations: -1,
                curve: Curve.Linear
              })
          }
        }

        // 歌曲信息
        Column() {
          Text(this.currentTrack?.title || '未在播放')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Text(this.currentTrack?.artist || '点击选择歌曲')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }
      .layoutWeight(1)
      .onClick(() => {
        if (this.onExpand) {
          this.onExpand();
        }
      })

      // 右侧：控制按钮
      Row({ space: 8 }) {
        // 播放/暂停按钮
        Button() {
          Image(this.isPlaying ? $r('app.media.icon_pause') : $r('app.media.icon_play'))
            .width(28)
            .height(28)
            .fillColor('#333333')
        }
        .type(ButtonType.Circle)
        .backgroundColor('transparent')
        .width(44)
        .height(44)
        .onClick(() => {
          if (this.isPlaying) {
            this.audioSvc.pause();
          } else {
            this.audioSvc.play();
          }
          // 不立即更新状态，等待事件通知保持同步
        })

        // 下一首按钮
        Button() {
          Image($r('app.media.icon_next'))
            .width(24)
            .height(24)
            .fillColor('#666666')
        }
        .type(ButtonType.Circle)
        .backgroundColor('transparent')
        .width(44)
        .height(44)
        .onClick(() => {
          this.audioSvc.next();
          // 不立即更新状态，等待事件通知保持同步
        })

        // 播放列表按钮
        Button() {
          Image($r('app.media.icon_playlist'))
            .width(24)
            .height(24)
            .fillColor('#666666')
        }
        .type(ButtonType.Circle)
        .backgroundColor('transparent')
        .width(44)
        .height(44)
        .onClick(() => {
          // 显示播放列表（可以通过事件通知父组件）
        })
      }
    }
    .width('100%')
    .height(60)
    .padding({ left: 16, right: 8 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
  }
}
