/**
 * 时间格式化工具类
 */

export class TimeUtil {
  /**
   * 将毫秒转换为 mm:ss 格式
   * @param ms 毫秒数
   * @returns 格式化后的时间字符串，如 "03:25"
   */
  static formatDuration(ms: number): string {
    if (ms < 0) {
      return '00:00';
    }
    
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * 将毫秒转换为 hh:mm:ss 格式
   * @param ms 毫秒数
   * @returns 格式化后的时间字符串，如 "01:03:25"
   */
  static formatDurationWithHour(ms: number): string {
    if (ms < 0) {
      return '00:00:00';
    }
    
    const totalSeconds = Math.floor(ms / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * 将秒数转换为 mm:ss 格式
   * @param seconds 秒数
   * @returns 格式化后的时间字符串
   */
  static formatSeconds(seconds: number): string {
    if (seconds < 0) {
      return '00:00';
    }
    
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  /**
   * 解析 mm:ss 格式的时间字符串为毫秒
   * @param timeStr 时间字符串，如 "03:25"
   * @returns 毫秒数
   */
  static parseDuration(timeStr: string): number {
    const parts = timeStr.split(':');
    if (parts.length !== 2) {
      return 0;
    }
    
    const minutes = parseInt(parts[0], 10);
    const seconds = parseInt(parts[1], 10);
    
    if (isNaN(minutes) || isNaN(seconds)) {
      return 0;
    }
    
    return (minutes * 60 + seconds) * 1000;
  }

  /**
   * 格式化当前日期时间
   * @returns 格式化后的日期时间字符串
   */
  static formatCurrentTime(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const seconds = now.getSeconds().toString().padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  /**
   * 获取相对时间描述
   * @param timestamp 时间戳（毫秒）
   * @returns 相对时间描述，如 "刚刚"、"5分钟前"、"1小时前" 等
   */
  static getRelativeTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;
    
    if (diff < 0) {
      return '未来';
    }
    
    const minute = 60 * 1000;
    const hour = 60 * minute;
    const day = 24 * hour;
    const week = 7 * day;
    const month = 30 * day;
    const year = 365 * day;
    
    if (diff < minute) {
      return '刚刚';
    } else if (diff < hour) {
      return `${Math.floor(diff / minute)}分钟前`;
    } else if (diff < day) {
      return `${Math.floor(diff / hour)}小时前`;
    } else if (diff < week) {
      return `${Math.floor(diff / day)}天前`;
    } else if (diff < month) {
      return `${Math.floor(diff / week)}周前`;
    } else if (diff < year) {
      return `${Math.floor(diff / month)}个月前`;
    } else {
      return `${Math.floor(diff / year)}年前`;
    }
  }
}
