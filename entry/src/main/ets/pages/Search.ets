/**
 * 搜索页面
 * 支持实时前缀搜索和模糊搜索
 */

import { router } from '@kit.ArkUI';
import { TrackInfo } from '../models/TrackInfo';
import { Database } from '../services/Database';
import { AudioSvc } from '../services/AudioSvc';
import { SearchManager } from '../utils/TrieTree';
import { TrackItem } from '../views/TrackItem';

@Entry
@Component
struct SearchPage {
  @State private searchKeyword: string = '';
  @State private searchResults: TrackInfo[] = [];
  @State private allTracks: TrackInfo[] = [];
  @State private searchHistory: string[] = [];
  @State private isSearching: boolean = false;
  @State private hasSearched: boolean = false;

  private database: Database = Database.getInstance();
  private audioSvc: AudioSvc = AudioSvc.getInstance();
  private searchManager: SearchManager = new SearchManager();

  aboutToAppear() {
    // 加载所有歌曲并构建搜索索引
    this.loadAllTracks();
    
    // 加载搜索历史（从本地存储）
    this.loadSearchHistory();
  }

  private async loadAllTracks() {
    try {
      this.allTracks = await this.database.getAllTracks();
      this.searchManager.initialize(this.allTracks);
    } catch (err) {
      console.error('加载歌曲失败:', err);
    }
  }

  private loadSearchHistory() {
    // 这里可以从 preferences 加载历史记录
    this.searchHistory = ['周杰伦', '流行音乐', '摇滚'];
  }

  private saveSearchHistory(keyword: string) {
    if (!keyword.trim()) return;
    
    // 去重并添加到开头
    const trimmedKeyword = keyword.trim();
    const index = this.searchHistory.indexOf(trimmedKeyword);
    if (index > -1) {
      this.searchHistory.splice(index, 1);
    }
    this.searchHistory.unshift(trimmedKeyword);
    
    // 限制历史记录数量
    if (this.searchHistory.length > 10) {
      this.searchHistory = this.searchHistory.slice(0, 10);
    }
    
    // 保存到本地存储
    // TODO: 使用 preferences 保存
  }

  private onSearchInputChange(keyword: string) {
    this.searchKeyword = keyword;
    
    if (keyword.trim().length === 0) {
      this.searchResults = [];
      this.hasSearched = false;
      return;
    }

    // 实时搜索
    this.performSearch(keyword);
  }

  private performSearch(keyword: string) {
    this.isSearching = true;
    this.hasSearched = true;
    
    // 使用 TrieTree 进行前缀搜索
    let results = this.searchManager.search(keyword);
    
    // 如果前缀搜索结果太少，使用模糊搜索补充
    if (results.length < 5) {
      const fuzzyResults = this.searchManager.fuzzySearch(keyword);
      // 合并结果并去重
      const resultIds = new Set(results.map(t => t.id));
      for (const track of fuzzyResults) {
        if (!resultIds.has(track.id)) {
          results.push(track);
        }
      }
    }
    
    this.searchResults = results;
    this.isSearching = false;
  }

  private onSearchSubmit() {
    if (this.searchKeyword.trim()) {
      this.saveSearchHistory(this.searchKeyword);
      this.performSearch(this.searchKeyword);
    }
  }

  private clearSearch() {
    this.searchKeyword = '';
    this.searchResults = [];
    this.hasSearched = false;
  }

  private clearHistory() {
    this.searchHistory = [];
    // TODO: 清除本地存储
  }

  private playTrack(track: TrackInfo) {
    // 设置播放队列并播放
    this.audioSvc.setPlayQueue(this.searchResults.length > 0 ? this.searchResults : [track]);
    this.audioSvc.loadTrack(track);
  }

  private async navigateBack() {
    try {
      await router.back();
    } catch (err) {
      console.error('返回失败:', err);
    }
  }

  @Builder
  SearchHistoryItem(keyword: string) {
    Row() {
      Image($r('app.media.startIcon'))
        .width(20)
        .height(20)
        .fillColor('#999999')
        .margin({ right: 12 })

      Text(keyword)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)

      Button() {
        Image($r('app.media.startIcon'))
          .width(16)
          .height(16)
          .fillColor('#CCCCCC')
      }
      .type(ButtonType.Circle)
      .backgroundColor('transparent')
      .width(32)
      .height(32)
      .onClick(() => {
        // 从历史记录中删除
        const index = this.searchHistory.indexOf(keyword);
        if (index > -1) {
          this.searchHistory.splice(index, 1);
        }
      })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 8 })
    .onClick(() => {
      this.searchKeyword = keyword;
      this.onSearchSubmit();
    })
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        // 返回按钮
        Button() {
          Image($r('app.media.startIcon'))
            .width(24)
            .height(24)
            .fillColor('#333333')
        }
        .type(ButtonType.Circle)
        .backgroundColor('transparent')
        .width(44)
        .height(44)
        .onClick(() => this.navigateBack())

        // 搜索输入框
        Row() {
          Image($r('app.media.startIcon'))
            .width(20)
            .height(20)
            .fillColor('#999999')
            .margin({ left: 12 })

          TextInput({ placeholder: '搜索歌曲、歌手、专辑', text: this.searchKeyword })
            .placeholderColor('#999999')
            .fontSize(14)
            .height(40)
            .backgroundColor('transparent')
            .layoutWeight(1)
            .onChange((value: string) => {
              this.onSearchInputChange(value);
            })
            .onSubmit(() => {
              this.onSearchSubmit();
            })

          if (this.searchKeyword.length > 0) {
            Button() {
              Image($r('app.media.startIcon'))
                .width(16)
                .height(16)
                .fillColor('#999999')
            }
            .type(ButtonType.Circle)
            .backgroundColor('transparent')
            .width(32)
            .height(32)
            .margin({ right: 4 })
            .onClick(() => this.clearSearch())
          }
        }
        .height(40)
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .margin({ left: 8, right: 8 })

        // 搜索按钮
        Button() {
          Text('搜索')
            .fontSize(14)
            .fontColor('#FF4081')
        }
        .type(ButtonType.Capsule)
        .backgroundColor('transparent')
        .height(40)
        .onClick(() => this.onSearchSubmit())
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 8 })
      .backgroundColor('#FFFFFF')

      // 搜索内容区域
      if (this.hasSearched) {
        // 搜索结果
        if (this.searchResults.length > 0) {
          List({ space: 0 }) {
            // 结果统计
            ListItem() {
              Text(`找到 ${this.searchResults.length} 首歌曲`)
                .fontSize(14)
                .fontColor('#999999')
                .padding({ left: 16, right: 16, top: 12, bottom: 8 })
            }

            // 歌曲列表
            ForEach(this.searchResults, (track: TrackInfo, index: number) => {
              ListItem() {
                TrackItem({
                  track: track,
                  index: index + 1,
                  isPlaying: this.audioSvc.getCurrentTrack()?.id === track.id && this.audioSvc.isPlaying(),
                  onTrackClick: (t: TrackInfo): void => { this.playTrack(t); }
                })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .divider({ strokeWidth: 0.5, color: '#EEEEEE' })
        } else {
          // 无结果
          Column() {
            Image($r('app.media.startIcon'))
              .width(80)
              .height(80)
              .fillColor('#CCCCCC')
              .margin({ bottom: 16 })

            Text('未找到相关歌曲')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ bottom: 8 })

            Text('换个关键词试试吧')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      } else {
        // 搜索历史和推荐
        Scroll() {
          Column({ space: 16 }) {
            // 搜索历史
            if (this.searchHistory.length > 0) {
              Column({ space: 0 }) {
                Row() {
                  Text('搜索历史')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')

                  Button() {
                    Text('清除')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .type(ButtonType.Capsule)
                  .backgroundColor('transparent')
                  .height(32)
                  .onClick(() => this.clearHistory())
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left: 16, right: 8, top: 16, bottom: 8 })

                // 历史记录标签
                Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                  ForEach(this.searchHistory, (keyword: string) => {
                    Button() {
                      Text(keyword)
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .type(ButtonType.Capsule)
                    .backgroundColor('#F5F5F5')
                    .height(32)
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => {
                      this.searchKeyword = keyword;
                      this.onSearchSubmit();
                    })
                  })
                }
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 16 })
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ left: 16, right: 16 })
            }

            // 热门搜索
            Column({ space: 0 }) {
              Text('热门搜索')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('100%')
                .padding({ left: 16, right: 16, top: 16, bottom: 12 })

              Column({ space: 0 }) {
                ForEach(['周杰伦', '林俊杰', '薛之谦', '邓紫棋', '陈奕迅', 'Taylor Swift'], (keyword: string, index: number) => {
                  Row() {
                    Text((index + 1).toString())
                      .fontSize(14)
                      .fontWeight(index < 3 ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(index < 3 ? '#FF4081' : '#999999')
                      .width(24)

                    Text(keyword)
                      .fontSize(14)
                      .fontColor('#333333')
                      .layoutWeight(1)

                    Image($r('app.media.startIcon'))
                      .width(16)
                      .height(16)
                      .fillColor('#CCCCCC')
                  }
                  .width('100%')
                  .height(48)
                  .padding({ left: 16, right: 16 })
                  .onClick(() => {
                    this.searchKeyword = keyword;
                    this.onSearchSubmit();
                  })
                })
              }
            }
            .width('100%')
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .margin({ left: 16, right: 16 })
          }
          .width('100%')
          .padding({ top: 8, bottom: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
