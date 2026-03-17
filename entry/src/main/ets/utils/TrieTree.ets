/**
 * 前缀树 (Trie) 数据结构实现
 * 用于歌曲名称和歌手的快速前缀搜索
 */

import { TrackInfo } from '../models/TrackInfo';

/**
 * Trie 树节点
 */
class TrieNode {
  // 子节点映射
  children: Map<string, TrieNode> = new Map();
  // 是否是单词结尾
  isEndOfWord: boolean = false;
  // 存储关联的歌曲列表
  tracks: TrackInfo[] = [];

  constructor() {}
}

/**
 * 前缀树实现类
 */
export class TrieTree {
  private root: TrieNode;
  private caseSensitive: boolean;

  constructor(caseSensitive: boolean = false) {
    this.root = new TrieNode();
    this.caseSensitive = caseSensitive;
  }

  /**
   * 插入一个单词和关联的歌曲
   * @param word 要插入的单词
   * @param track 关联的歌曲
   */
  insert(word: string, track: TrackInfo): void {
    if (!word) {
      return;
    }

    const processedWord = this.caseSensitive ? word : word.toLowerCase();
    let current = this.root;

    for (const char of processedWord) {
      if (!current.children.has(char)) {
        current.children.set(char, new TrieNode());
      }
      current = current.children.get(char)!;
    }

    current.isEndOfWord = true;
    
    // 避免重复添加同一首歌曲
    if (!current.tracks.find(t => t.id === track.id)) {
      current.tracks.push(track);
    }
  }

  /**
   * 搜索前缀，返回所有匹配的歌曲
   * @param prefix 搜索前缀
   * @returns 匹配的歌曲列表
   */
  search(prefix: string): TrackInfo[] {
    if (!prefix) {
      return [];
    }

    const processedPrefix = this.caseSensitive ? prefix : prefix.toLowerCase();
    let current = this.root;

    // 找到前缀对应的节点
    for (const char of processedPrefix) {
      if (!current.children.has(char)) {
        return [];
      }
      current = current.children.get(char)!;
    }

    // 收集该节点下的所有歌曲
    return this.collectAllTracks(current);
  }

  /**
   * 检查是否存在某个单词
   * @param word 要检查的单词
   * @returns 是否存在
   */
  contains(word: string): boolean {
    if (!word) {
      return false;
    }

    const processedWord = this.caseSensitive ? word : word.toLowerCase();
    let current = this.root;

    for (const char of processedWord) {
      if (!current.children.has(char)) {
        return false;
      }
      current = current.children.get(char)!;
    }

    return current.isEndOfWord;
  }

  /**
   * 从歌曲列表构建前缀树
   * @param tracks 歌曲列表
   */
  buildFromTracks(tracks: TrackInfo[]): void {
    this.clear();
    
    for (const track of tracks) {
      // 插入歌曲名
      if (track.title) {
        this.insert(track.title, track);
        // 插入歌曲名的每个子串（用于模糊搜索）
        for (let i = 1; i < track.title.length; i++) {
          this.insert(track.title.substring(i), track);
        }
      }
      
      // 插入歌手名
      if (track.artist && track.artist !== '未知歌手') {
        this.insert(track.artist, track);
      }
      
      // 插入专辑名
      if (track.album && track.album !== '未知专辑') {
        this.insert(track.album, track);
      }
    }
  }

  /**
   * 清空前缀树
   */
  clear(): void {
    this.root = new TrieNode();
  }

  /**
   * 获取前缀树中所有歌曲数量
   * @returns 歌曲数量
   */
  getTrackCount(): number {
    const allTracks = this.collectAllTracks(this.root);
    const uniqueIds = new Set(allTracks.map(t => t.id));
    return uniqueIds.size;
  }

  /**
   * 递归收集节点下的所有歌曲
   */
  private collectAllTracks(node: TrieNode): TrackInfo[] {
    const result: TrackInfo[] = [];
    const visited = new Set<number>(); // 用于去重

    this.collectTracksRecursive(node, result, visited);
    return result;
  }

  /**
   * 递归收集歌曲
   */
  private collectTracksRecursive(node: TrieNode, result: TrackInfo[], visited: Set<number>): void {
    // 添加当前节点的歌曲
    for (const track of node.tracks) {
      if (!visited.has(track.id)) {
        visited.add(track.id);
        result.push(track);
      }
    }

    // 递归处理子节点
    for (const childNode of node.children.values()) {
      this.collectTracksRecursive(childNode, result, visited);
    }
  }

  /**
   * 获取以指定前缀开头的所有单词
   * @param prefix 前缀
   * @returns 单词列表
   */
  getWordsWithPrefix(prefix: string): string[] {
    if (!prefix) {
      return [];
    }

    const processedPrefix = this.caseSensitive ? prefix : prefix.toLowerCase();
    let current = this.root;

    for (const char of processedPrefix) {
      if (!current.children.has(char)) {
        return [];
      }
      current = current.children.get(char)!;
    }

    const words: string[] = [];
    this.collectWords(current, processedPrefix, words);
    return words;
  }

  /**
   * 递归收集单词
   */
  private collectWords(node: TrieNode, currentWord: string, words: string[]): void {
    if (node.isEndOfWord) {
      words.push(currentWord);
    }

    for (const entry of node.children.entries()) {
      const char: string = entry[0];
      const childNode: TrieNode = entry[1];
      this.collectWords(childNode, currentWord + char, words);
    }
  }
}

/**
 * 搜索管理器
 * 封装 TrieTree 提供更高级的搜索功能
 */
export class SearchManager {
  private trieTree: TrieTree;
  private allTracks: TrackInfo[] = [];

  constructor() {
    this.trieTree = new TrieTree(false);
  }

  /**
   * 初始化搜索管理器
   * @param tracks 所有歌曲列表
   */
  initialize(tracks: TrackInfo[]): void {
    this.allTracks = [...tracks];
    this.trieTree.buildFromTracks(tracks);
  }

  /**
   * 前缀搜索
   * @param keyword 搜索关键词
   * @returns 匹配的歌曲列表
   */
  search(keyword: string): TrackInfo[] {
    if (!keyword || keyword.trim().length === 0) {
      return [];
    }

    const trimmedKeyword = keyword.trim().toLowerCase();
    return this.trieTree.search(trimmedKeyword);
  }

  /**
   * 模糊搜索（包含匹配）
   * @param keyword 搜索关键词
   * @returns 匹配的歌曲列表
   */
  fuzzySearch(keyword: string): TrackInfo[] {
    if (!keyword || keyword.trim().length === 0) {
      return [];
    }

    const trimmedKeyword = keyword.trim().toLowerCase();
    return this.allTracks.filter(track => {
      return track.title.toLowerCase().includes(trimmedKeyword) ||
             track.artist.toLowerCase().includes(trimmedKeyword) ||
             track.album.toLowerCase().includes(trimmedKeyword);
    });
  }

  /**
   * 添加新歌曲到搜索索引
   * @param track 歌曲
   */
  addTrack(track: TrackInfo): void {
    this.allTracks.push(track);
    if (track.title) {
      this.trieTree.insert(track.title, track);
    }
    if (track.artist) {
      this.trieTree.insert(track.artist, track);
    }
    if (track.album) {
      this.trieTree.insert(track.album, track);
    }
  }

  /**
   * 从搜索索引移除歌曲
   * @param trackId 歌曲ID
   */
  removeTrack(trackId: number): void {
    const index = this.allTracks.findIndex(t => t.id === trackId);
    if (index > -1) {
      this.allTracks.splice(index, 1);
      // 重建索引
      this.trieTree.buildFromTracks(this.allTracks);
    }
  }

  /**
   * 清空搜索索引
   */
  clear(): void {
    this.allTracks = [];
    this.trieTree.clear();
  }
}
