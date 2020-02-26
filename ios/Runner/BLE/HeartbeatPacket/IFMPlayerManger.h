//
//  IFMPlayerManger.h
//  P3KApp
//
//  Created by 王泽 on 2017/2/26.
//  Copyright © 2017年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define PauseSport  @"PauseSport"

@class IFMPlayerManger;
@protocol IFMPlayerMangerDelegate <NSObject>
@optional
- (void)notSupportCallback;

@end

@interface IFMPlayerManger : NSObject

@property (nonatomic, assign, readonly) UInt8           workMode;       // 工作模式  0 : hifi,  1 : sport
@property (nonatomic, assign, readonly) UInt8           playMode;       // 当前音乐播放模式
@property (nonatomic, assign, readonly) UInt8           playState;      // 播放器状态 0停止,1播放,2暂停
@property (nonatomic, assign, readonly) UInt8           batteryPercent; // 当前电池电量
@property (nonatomic, assign, readonly) UInt8           singleLock;     // 0  1是单曲锁定
@property (nonatomic, assign, readonly) SInt16          volnum;         // 设备音量
@property (nonatomic, assign, readonly) UInt16          bpm;            // 当前设置BPM
@property (nonatomic, assign, readonly) BOOL            isBpmOn;        // Bpm 是否已经打开手动;
@property (nonatomic, assign, readonly) UInt32          mediaDbid;      // 当前歌曲id
@property (nonatomic, assign, readonly) UInt16          mediaDbpos;     // 当前歌曲pos
@property (nonatomic, assign, readonly) UInt16          mediaEx;        // 当前歌曲扩展
@property (nonatomic, assign, readonly) UInt32          playing_time;   // 当前秒数
@property (nonatomic, assign, readonly) UInt32          total_time;     // 总时间
@property (nonatomic, assign, readonly) UInt32          playinglist_id; // 当前播放列表 id;
@property (nonatomic, assign, readonly) UInt32          totalSize;      // RT_info 总大小
@property (nonatomic, assign, readonly) BOOL            isNotSupport;   // 播放不支持;
@property (nonatomic, assign, readonly) P3K_TagHeader   ex;             // 用于扩展

@property (nonatomic, weak) id <IFMPlayerMangerDelegate> delegate;

@property (nonatomic, strong, readonly) MPVolumeView    *volumeView;

+ (instancetype)sharedInstance;

//- (void)startPlaySilenceAudio;
//- (void)stopPlaySilenceAudio;

- (void)fillRTInfoWithData:(NSData *)data;

//更改音量
- (void)setupVolnum:(SInt16)num;

//更改工作模式 HIFI SPORT
- (void)setupWorkMode:(UInt8)workMode;

//更改播放模式; 0 顺序 , 1 随机  ,3全盘播放;
- (void)setupPlayMode:(UInt8)playMode;

//设置单曲锁定 非零就是锁定;
- (void)setupSingleLock:(UInt8)islock;

//修改播放状态
- (void)setupPlayState:(UInt8)playState;

//设置BPM
- (void)setupBpm:(UInt16)Bpm isOn:(BOOL)isOn;

//设置当前播放秒数
- (void)setupTime:(UInt32)time;

//跳转指定歌曲 附加当前列表第几个
- (void)playMediaId:(UInt32)dbid pos:(UInt16)dbpos index:(UInt16)index;

//跳转指定列表 第几个歌曲
- (void)playListId:(UInt32)dbid pos:(UInt16)dbpos index:(UInt16)index;

@end
