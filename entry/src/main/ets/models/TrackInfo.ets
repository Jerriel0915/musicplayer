/**
 * 歌曲信息实体类
 * 对应数据库 track 表
 */

import { relationalStore } from '@kit.ArkData';

/**
 * TrackInfo 构造选项接口
 */
export interface TrackInfoOptions {
  id?: number;
  title?: string;
  artist?: string;
  album?: string;
  duration?: number;
  filePath?: string;
  coverUri?: string;
  addedAt?: number;
}

export class TrackInfo {
  // 唯一标识
  id: number = -1;
  // 歌曲名
  title: string = '';
  // 歌手名
  artist: string = '未知歌手';
  // 专辑名
  album: string = '未知专辑';
  // 时长 (毫秒)
  duration: number = 0;
  // 物理文件绝对路径
  filePath: string = '';
  // 封面图片沙箱路径
  coverUri: string = '';
  // 入库时间戳
  addedAt: number = Date.now();

  constructor(options?: TrackInfoOptions) {
    if (options) {
      this.id = options.id ?? -1;
      this.title = options.title ?? '';
      this.artist = options.artist ?? '未知歌手';
      this.album = options.album ?? '未知专辑';
      this.duration = options.duration ?? 0;
      this.filePath = options.filePath ?? '';
      this.coverUri = options.coverUri ?? '';
      this.addedAt = options.addedAt ?? Date.now();
    }
  }

  /**
   * 从 RDB 结果集转换为 TrackInfo 对象
   */
  static fromResultSet(resultSet: relationalStore.ResultSet): TrackInfo {
    const trackInfo = new TrackInfo();
    trackInfo.id = resultSet.getLong(resultSet.getColumnIndex('id'));
    trackInfo.title = resultSet.getString(resultSet.getColumnIndex('title'));
    trackInfo.artist = resultSet.getString(resultSet.getColumnIndex('artist'));
    trackInfo.album = resultSet.getString(resultSet.getColumnIndex('album'));
    trackInfo.duration = resultSet.getLong(resultSet.getColumnIndex('duration'));
    trackInfo.filePath = resultSet.getString(resultSet.getColumnIndex('file_path'));
    trackInfo.coverUri = resultSet.getString(resultSet.getColumnIndex('cover_uri'));
    trackInfo.addedAt = resultSet.getLong(resultSet.getColumnIndex('added_at'));
    return trackInfo;
  }

  /**
   * 转换为 RDB 插入/更新数据
   */
  toValuesBucket(): relationalStore.ValuesBucket {
    const bucket: relationalStore.ValuesBucket = {
      'title': this.title,
      'artist': this.artist,
      'album': this.album,
      'duration': this.duration,
      'file_path': this.filePath,
      'cover_uri': this.coverUri,
      'added_at': this.addedAt
    };
    
    if (this.id > 0) {
      bucket['id'] = this.id;
    }
    
    return bucket;
  }

  /**
   * 获取格式化的时长字符串 (mm:ss)
   */
  get formattedDuration(): string {
    const totalSeconds = Math.floor(this.duration / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * 获取完整的显示标题
   */
  get displayTitle(): string {
    return `${this.title} - ${this.artist}`;
  }

  /**
   * 获取用于搜索的关键词
   */
  get searchKeywords(): string[] {
    const keywords: string[] = [];
    if (this.title) {
      keywords.push(this.title.toLowerCase());
    }
    if (this.artist) {
      keywords.push(this.artist.toLowerCase());
    }
    if (this.album) {
      keywords.push(this.album.toLowerCase());
    }
    return keywords;
  }
}
