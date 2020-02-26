
//  IFMPlayerManger.m
//  P3KApp
//
//  Created by 王泽 on 2017/2/26.
//  Copyright © 2017年 Infomedia. All rights reserved.
//

#import "IFMPlayerManger.h"
#import "CBPeripheral+IFMProperties.h"
#import "IFMBLEDeviceStateManager.h"
#import "IFMBLEWriteManager.h"
#import "IFMDeviceStateReformer.h"
#import "IFMBLEReadManager.h"
#import "IFMBLECheckManager.h"
#import "IFMCheckCMDReformer.h"
#import "IFMRealTimeControlManager.h"
#import "IFMDeviceManager.h"
#import "IFMHeartbeatPacket.h"
#import "IFMDeviceUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface IFMPlayerManger ()<IFMDeviceManagerDelegate,IFMBLEManagerCallbackDelegate>

@property (nonatomic, assign)   Ble_RT_Info                 *sRT_Info;

@property (nonatomic, assign, readwrite) UInt8           workMode;       // 工作模式  0 : hifi,  1 : sport
@property (nonatomic, assign, readwrite) UInt8           playMode;       // 当前音乐播放模式
@property (nonatomic, assign, readwrite) UInt8           playState;      // 播放器状态 0停止,1播放,2暂停
@property (nonatomic, assign, readwrite) UInt8           batteryPercent; // 当前电池电量
@property (nonatomic, assign, readwrite) UInt8           singleLock;     // 歌曲锁定 0:正常 1:锁定
@property (nonatomic, assign, readwrite) SInt16          volnum;         // 设备音量
@property (nonatomic, assign, readwrite) UInt16          bpm;            // 当前设置BPM
@property (nonatomic, assign, readwrite) BOOL            isBpmOn;        // Bpm 是否已经打开手动;
@property (nonatomic, assign, readwrite) UInt32          mediaDbid;      // 当前秒数
@property (nonatomic, assign, readwrite) UInt16          mediaDbpos;     // 当前设置BPM
@property (nonatomic, assign, readwrite) UInt16          mediaEx;        // 当前歌曲扩展
@property (nonatomic, assign, readwrite) UInt32          playing_time;   // 当前秒数
@property (nonatomic, assign, readwrite) UInt32          total_time;     // 总时间
@property (nonatomic, assign, readwrite) UInt32          playinglist_id; // 当前播放列表 id;
@property (nonatomic, assign, readwrite) UInt32          totalSize;      // RT_info 总大小
@property (nonatomic, assign, readwrite) BOOL            isNotSupport;   // 播放不支持;
@property (nonatomic, assign, readwrite) P3K_TagHeader   ex;             // 用于扩展

@property (nonatomic, strong)   IFMCheckCMDReformer         *checkCMDReformer;

@property (nonatomic, strong)   IFMBLECheckManager          *checkRT;
@property (nonatomic, strong)   IFMBLEReadManager           *readRT;
@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlRT;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlVolnum;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlWorkMode;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlPlayMode;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlSingleLock;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlPlayState;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlBpm;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlTime;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlPlayMedia;

@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlPlayList;

@property (nonatomic, strong)   IFMBLECheckManager          *checkNotSupport_songid;
@property (nonatomic, strong)   IFMBLEReadManager           *readNotSupport_songid;
@property (nonatomic, strong)   IFMRealTimeControlManager   *writeNotSupport_songid;



@property (nonatomic, strong)   AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, readwrite)   MPVolumeView  *volumeView;
@property (nonatomic, strong, readwrite)   UISlider      *volumeSlider;
@property (nonatomic, assign)   double              startTimeInterval;
@property (nonatomic, assign)   double              currentTimeInterval;

@end

@implementation IFMPlayerManger

+ (instancetype)sharedInstance {
    static IFMPlayerManger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.sRT_Info = malloc(sizeof(Ble_RT_Info));
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.volumeView = [MPVolumeView new];
        
        for (UIView *view in _volumeView.subviews) {
            if ([view isKindOfClass:[UISlider class]]) {
                self.volumeSlider = (UISlider*)view;
                break;
            }
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
        self.startTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        self.currentTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    }
    
    return self;
}

//- (void)startPlaySilenceAudio {
//    if (self.audioPlayer == nil) {
//        
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"silence" ofType:@"mp3"];
//        NSURL *url = [NSURL fileURLWithPath:path];
//        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//        self.audioPlayer.numberOfLoops = INT_MAX;
//    }
//    [self.audioPlayer play];
//    [self setSystemNowPlayingInfoWithAudio:@{@"Title": @"Lotoo Pico", @"Subtitle": @"世界,\"音\"我而动"} duration:0 elapsedPlaybackTime:0];
//}

//- (void)stopPlaySilenceAudio {
//    if (self.audioPlayer) {
//        [self.audioPlayer stop];
//        self.audioPlayer = nil;
//    }
//    [self setSystemNowPlayingInfoWithAudio:nil duration:0 elapsedPlaybackTime:0];
//}





- (void)fillRTInfoWithData:(NSData *)data {
    
    
    self.sRT_Info = NULL;
    self.sRT_Info = (Ble_RT_Info *)[data bytes];
    
    BOOL isYes = NO;
    
    if (self.sRT_Info->t_len < sizeof(Ble_RT_Info) - sizeof(P3K_TagHeader) || self.sRT_Info->t_len > 10000) {
        return;
    }
    
    xU32 num = [IFMDeviceUtils sumBleRtInfoWithPinfo:(xU8 *)self.sRT_Info len:self.sRT_Info->t_len - 4];
    
    P3K_TagHeader * pP3K_TagHeader = NULL;
    
    xU32 len = 0;
    len = self.sRT_Info->t_len - ((xU32)self.sRT_Info->hd - (xU32)self.sRT_Info);
    
    pP3K_TagHeader = (P3K_TagHeader *)[IFMDeviceUtils getHeartTagData:(xU8 *)self.sRT_Info->hd buffsize:(xU32)(len) tagMagic:P3K_BLE_RT_INFO_SUM];
    
    if (pP3K_TagHeader != NULL) {
        
        if (num == *((xU32 *)(pP3K_TagHeader + 1))) {
            isYes = YES;
        }
    }
    
    if (!isYes) {
        return;
    }
    
    self.workMode = self.sRT_Info->workmode;
    self.playMode = self.sRT_Info->playmode;
    self.playState = self.sRT_Info->playstate;
    self.singleLock = self.sRT_Info->single_lock;
//    self.batteryPercent = self.sRT_Info->battery_percent;
    if (self.volnum != self.sRT_Info->hp_volnum) {
        self.volnum = self.sRT_Info->hp_volnum;
        float volume = [self covertSystemVolumeFromPicoVolume:self.volnum];
        self.volumeSlider.value = volume;
    }
    self.bpm = self.sRT_Info->bpm & (~P3K_BPM_SWITCH_ON);
    self.isBpmOn = self.sRT_Info->bpm & P3K_BPM_SWITCH_ON;
    self.total_time = self.sRT_Info->total_time / 1000;
    self.playing_time = self.sRT_Info->playing_time / 1000;
    
    self.playinglist_id = self.sRT_Info->playinglist_id;
    self.mediaDbpos = self.sRT_Info->song_item.dbpos;
    self.mediaDbid = self.sRT_Info->song_item.dbid;
    self.mediaEx = self.sRT_Info->song_item.pad[1];
    self.totalSize = self.sRT_Info->t_len;
    self.isNotSupport = (self.sRT_Info->play_error_state) & PLAY_ERROR_STATE_UNSUPPORT_SONG;
    self.ex = self.sRT_Info->hd[1];
    NSLog(@"workmode:%d",self.workMode);
    NSLog(@"playState:%d",self.playState);
    NSLog(@"playMode:%d",self.playMode);
    NSLog(@"volnum:%d",self.volnum);
    NSLog(@"playinglist_id:%d",self.playinglist_id);
    NSLog(@"bpm:%d",self.bpm);
    NSLog(@"bpm开关 %d",self.isBpmOn);
    
    if (self.isNotSupport) {
        [self.checkNotSupport_songid setupObjectId:DEVICE_OBJECTID_UNSUPPORT_SONG_DBID];
        [self.checkNotSupport_songid execute];
    }
    
}


//更改音量
- (void)setupVolnum:(SInt16)num {
    
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    NSLog(@"setupVolnum -----------: %d",num);
    NSLog(@"self.volnum -----------: %d",self.volnum);
    NSData *data = [[NSData alloc] initWithBytes:&num length:sizeof(SInt16)];
    [self.realTimeControlVolnum setupEventType:CONTROL_OFFSET_VOLNUM];
    [self.realTimeControlVolnum setupLength:sizeof(SInt16)];
    [self.realTimeControlVolnum setupData:data];
    [self.realTimeControlVolnum execute];
}

//更改工作模式 HIFI SPORT
- (void)setupWorkMode:(UInt8)workMode {
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    NSData *data = [[NSData alloc] initWithBytes:&workMode length:sizeof(UInt8)];
    [self.realTimeControlWorkMode setupEventType:CONTROL_OFFSET_WORKMODE];
    [self.realTimeControlWorkMode setupLength:sizeof(UInt8)];
    [self.realTimeControlWorkMode setupData:data];
    [self.realTimeControlWorkMode execute];
    
}

//更改播放模式 0顺序 1随机  2全部播放
- (void)setupPlayMode:(UInt8)playMode {
    
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    
    if (self.playMode == playMode) {
        return;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:&playMode length:sizeof(UInt8)];
    [self.realTimeControlPlayMode setupEventType:CONTROL_OFFSET_PLAYMODE];
    [self.realTimeControlPlayMode setupLength:sizeof(UInt8)];
    [self.realTimeControlPlayMode setupData:data];
    [self.realTimeControlPlayMode execute];

}

- (void)setupSingleLock:(UInt8)islock {
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    NSData *data = [[NSData alloc] initWithBytes:&islock length:sizeof(UInt8)];
    [self.realTimeControlSingleLock setupEventType:CONTROL_OFFSET_SINGLE_LOCK];
    [self.realTimeControlSingleLock setupLength:sizeof(UInt8)];
    [self.realTimeControlSingleLock setupData:data];
    [self.realTimeControlSingleLock execute];

}

//修改播放状态 0停止 1播放  2暂停
- (void)setupPlayState:(UInt8)playState {
    
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:&playState length:sizeof(UInt8)];
    [self.realTimeControlPlayState setupEventType:CONTROL_OFFSET_PLAYSTATE];
    [self.realTimeControlPlayState setupLength:sizeof(UInt8)];
    [self.realTimeControlPlayState setupData:data];
    [self.realTimeControlPlayState execute];

}

//设置BPM
- (void)setupBpm:(UInt16)Bpm isOn:(BOOL)isOn{
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    
    if (isOn) {
        Bpm |= P3K_BPM_SWITCH_ON;
    } else {
        Bpm &= ~P3K_BPM_SWITCH_ON;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:&Bpm length:sizeof(UInt16)];
    [self.realTimeControlBpm setupEventType:CONTROL_OFFSET_BPMSET];
    [self.realTimeControlBpm setupLength:sizeof(UInt16)];
    [self.realTimeControlBpm setupData:data];
    [self.realTimeControlBpm execute];

}

//设置当前播放秒数
- (void)setupTime:(UInt32)time {
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:&time length:sizeof(UInt32)];
    [self.realTimeControlTime setupEventType:CONTROL_OFFSET_SEEK];
    [self.realTimeControlTime setupLength:sizeof(UInt32)];
    [self.realTimeControlTime setupData:data];
    [self.realTimeControlTime execute];

}

//跳转指定歌曲 附加当前列表第几个
- (void)playMediaId:(UInt32)dbid pos:(UInt16)dbpos index:(UInt16)index {
    
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    P3k_PLaylist_Item pLaylist_Item;
    memset(&pLaylist_Item, 0, sizeof(P3k_PLaylist_Item));
    
    pLaylist_Item.dbid = dbid;
    pLaylist_Item.dbpos = dbpos;
    pLaylist_Item.pad[0] = index;
    
    NSData *data = [[NSData alloc] initWithBytes:&pLaylist_Item length:sizeof(pLaylist_Item)];
    [self.realTimeControlPlayMedia setupEventType:CONTROL_OFFSET_SELECTSONG];
    [self.realTimeControlPlayMedia setupLength:sizeof(pLaylist_Item)];
    [self.realTimeControlPlayMedia setupData:data];
    [self.realTimeControlPlayMedia execute];

}

//跳转指定列表 第几个歌曲
- (void)playListId:(UInt32)dbid pos:(UInt16)dbpos index:(UInt16)index {
    if ([IFMHeartbeatPacket sharedInstance].isProcess) {
        return;
    }
    P3k_PLaylist_Item pLaylist_Item;
    memset(&pLaylist_Item, 0, sizeof(P3k_PLaylist_Item));
    
    pLaylist_Item.dbid = dbid;
    pLaylist_Item.dbpos = dbpos;
    pLaylist_Item.pad[0] = index;
    
    NSData *data = [[NSData alloc] initWithBytes:&pLaylist_Item length:sizeof(pLaylist_Item)];
    [self.realTimeControlPlayList setupEventType:CONTROL_OFFSET_SELECTPLIST];
    [self.realTimeControlPlayList setupLength:sizeof(pLaylist_Item)];
    [self.realTimeControlPlayList setupData:data];
    [self.realTimeControlPlayList execute];

}


- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    
    if (manager == self.checkRT) {
        
        
        
    }  else if (manager == self.readRT) {
        
    } else if (manager == self.realTimeControlRT) {
        
    } else if (manager == self.realTimeControlVolnum) {
        
        
    } else if (manager == self.realTimeControlWorkMode) {
        
        
    } else if (manager == self.realTimeControlPlayMode) {
        
        
    } else if (manager == self.realTimeControlSingleLock) {
        
        
    } else if (manager == self.realTimeControlPlayState) {
        
        if (self.workMode == 1) {
            if (self.playState == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PauseSport object:nil];
            }
        }
        
    } else if (manager == self.realTimeControlBpm) {
        
        
    } else if (manager == self.realTimeControlTime) {
        
        
        
    } else if (manager == self.realTimeControlPlayMedia) {
        
        NSLog(@"");
    } else if (manager == self.realTimeControlPlayList) {
        
        NSLog(@"");
    } else if (manager == self.checkNotSupport_songid) {
        
        NSNumber *number = [manager fetchDataWithReformer:self.checkCMDReformer];
        
        [self.readNotSupport_songid setupObjectId:DEVICE_OBJECTID_UNSUPPORT_SONG_DBID];
        [self.readNotSupport_songid setupLength:[number intValue]];
        [self.readNotSupport_songid execute];
        
    
    } else if (manager == self.readNotSupport_songid) {
    
        P3k_ID_Modify_List *playlist = (P3k_ID_Modify_List* )[manager.rawData bytes];
        
        NSLog(@"%x",playlist->id[0]);
        NSLog(@"%x",playlist->id[1]);
        NSLog(@"%x",playlist->id[2]);
        
        NSMutableArray *listArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < playlist->id_num; i ++ ) {
            [listArr addObject:@(playlist->id[i])];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FoundThatCanNotPlaySongs" object:listArr];
        
        int tempKey = 1;
        NSData *data = [NSData dataWithBytes:&tempKey length:sizeof(int)];
        [self.writeNotSupport_songid setupObjectId:DEVICE_OBJECTID_UNSUPPORT_SONG_DBID];
        [self.writeNotSupport_songid setupLength:sizeof(int)];
        [self.writeNotSupport_songid setupData:data];
        [self.writeNotSupport_songid execute];

    } else if (manager == self.writeNotSupport_songid) {
        
    }
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    
    if (manager == self.checkRT) {
        
    } else if (manager == self.readRT) {
        
    } else if (manager == self.realTimeControlRT) {
        
    } else if (manager == self.realTimeControlVolnum) {
        
    } else if (manager == self.realTimeControlWorkMode) {
        
    } else if (manager == self.realTimeControlPlayMode) {
        
    } else if (manager == self.realTimeControlSingleLock) {
       
    } else if (manager == self.realTimeControlPlayState) {
        
    } else if (manager == self.realTimeControlBpm) {
        
    } else if (manager == self.realTimeControlTime) {
        
    } else if (manager == self.realTimeControlPlayMedia) {
        NSLog(@"");
    } else if (manager == self.realTimeControlPlayList) {
        NSLog(@"");
    } else if (manager == self.checkNotSupport_songid) {
        
    } else if (manager == self.readNotSupport_songid) {
        
    } else if (manager == self.writeNotSupport_songid) {
        
    }


}

#pragma mark - getter & setter methods

- (IFMCheckCMDReformer*)checkCMDReformer {
    if (!_checkCMDReformer) {
        _checkCMDReformer = [IFMCheckCMDReformer new];
    }
    
    return _checkCMDReformer;
}


- (IFMBLECheckManager *)checkRT {
    
    if (!_checkRT) {
        _checkRT = [[IFMBLECheckManager alloc] init];
        _checkRT.delegate = self;
    }
    return _checkRT;
}


- (IFMBLEReadManager *)readRT {
    
    if (!_readRT) {
        _readRT = [[IFMBLEReadManager alloc] init];
        _readRT.delegate = self;
    }
    return _readRT;
}


- (IFMRealTimeControlManager *)realTimeControlRT {
    
    if (!_realTimeControlRT) {
        _realTimeControlRT = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlRT.delegate = self;
    }
    return _realTimeControlRT;
}


- (IFMRealTimeControlManager *)realTimeControlVolnum {
    
    if (!_realTimeControlVolnum) {
        _realTimeControlVolnum = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlVolnum.delegate = self;
    }
    return _realTimeControlVolnum;
}


- (IFMRealTimeControlManager *)realTimeControlWorkMode {
    
    if (!_realTimeControlWorkMode) {
        _realTimeControlWorkMode = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlWorkMode.delegate = self;
    }
    return _realTimeControlWorkMode;
}


- (IFMRealTimeControlManager *)realTimeControlPlayMode {
    
    if (!_realTimeControlPlayMode) {
        _realTimeControlPlayMode = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlPlayMode.delegate = self;
    }
    return _realTimeControlPlayMode;
}


- (IFMRealTimeControlManager *)realTimeControlSingleLock {
    
    if (!_realTimeControlSingleLock) {
        _realTimeControlSingleLock = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlSingleLock.delegate = self;
    }
    return _realTimeControlSingleLock;
}


- (IFMRealTimeControlManager *)realTimeControlPlayState {
    
    if (!_realTimeControlPlayState) {
        _realTimeControlPlayState = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlPlayState.delegate = self;
    }
    return _realTimeControlPlayState;
}


- (IFMRealTimeControlManager *)realTimeControlBpm {
    
    if (!_realTimeControlBpm) {
        _realTimeControlBpm = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlBpm.delegate = self;
    }
    return _realTimeControlBpm;
}

- (IFMRealTimeControlManager *)realTimeControlTime {
    
    if (!_realTimeControlTime) {
        _realTimeControlTime = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlTime.delegate = self;
    }
    return _realTimeControlTime;
}


- (IFMRealTimeControlManager *)realTimeControlPlayMedia {
    
    if (!_realTimeControlPlayMedia) {
        _realTimeControlPlayMedia = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlPlayMedia.delegate = self;
    }
    return _realTimeControlPlayMedia;
}


- (IFMRealTimeControlManager *)realTimeControlPlayList {
    
    if (!_realTimeControlPlayList) {
        _realTimeControlPlayList = [[IFMRealTimeControlManager alloc] init];
        _realTimeControlPlayList.delegate = self;
    }
    return _realTimeControlPlayList;
}


- (IFMBLECheckManager *)checkNotSupport_songid {
    
    if (!_checkNotSupport_songid) {
        _checkNotSupport_songid = [[IFMBLECheckManager alloc] init];
        _checkNotSupport_songid.delegate = self;
    }
    return _checkNotSupport_songid;
}


- (IFMBLEReadManager *)readNotSupport_songid {
    
    if (!_readNotSupport_songid) {
        _readNotSupport_songid = [[IFMBLEReadManager alloc] init];
        _readNotSupport_songid.delegate = self;
    }
    return _readNotSupport_songid;
}

- (IFMRealTimeControlManager *)writeNotSupport_songid {
    
    if (!_writeNotSupport_songid) {
        _writeNotSupport_songid = [[IFMRealTimeControlManager alloc] init];
        _writeNotSupport_songid.delegate = self;
    }
    return _writeNotSupport_songid;
}

- (float)covertSystemVolumeFromPicoVolume:(SInt16)picoVolume {
    int step =  (int)((float)picoVolume / 36.0 * 17);
    return step * 0.0625;
}

- (void)volumeChanged:(NSNotification*)notification {
    
    self.currentTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    
    float sysVolume = [notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];

    NSLog(@"sysVolume -----------: %lf",sysVolume);


    SInt16 picoVolume = self.volnum;
    float volume = [self covertSystemVolumeFromPicoVolume:picoVolume];
    
    if ((self.currentTimeInterval - self.startTimeInterval) < 100) {
        self.volumeSlider.value = volume;
        return;
    } else {
        self.startTimeInterval = self.currentTimeInterval;
    }
    
    if (sysVolume == 0.0) {
        self.volnum = 0;
        [self setupVolnum:0];
        return;
    } else if (sysVolume == 1.0) {
        self.volnum = 35;
        [self setupVolnum:35];
        return;
    }
    
    if (sysVolume == self.volumeSlider.value || volume == self.volumeSlider.value) {
        return;
    }

    float curVolume = self.volumeSlider.value;
    if (sysVolume > curVolume) {
        picoVolume += 2;
        volume += 0.0625;
    } else if (sysVolume < curVolume) {
        picoVolume -= 2;
        volume -= 0.0625;
    }

    self.volnum = picoVolume;
    [self setupVolnum:picoVolume];
    self.volumeSlider.value = volume;
    NSLog(@"self.volumeSlider.value --------:%lf",self.volumeSlider.value);

}

- (void)setSystemNowPlayingInfoWithAudio:(NSDictionary*)audio duration:(double)duration elapsedPlaybackTime:(double)elapsedPlaybackTime {
    if (audio == nil) {
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        return;
    }
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary *mDic = [NSMutableDictionary new];
        NSString *title = audio[@"Title"];
        NSString *subtitle = audio[@"Subtitle"];
        mDic[MPMediaItemPropertyTitle] = title;
        mDic[MPMediaItemPropertyAlbumTitle] = subtitle;
        
        [mDic setObject:@(duration) forKey:MPMediaItemPropertyPlaybackDuration];
        [mDic setObject:@(elapsedPlaybackTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        UIImage *image = [UIImage imageNamed:@"dl_2_1"];
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        mDic[MPMediaItemPropertyArtwork] = artwork;
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mDic];
    }
}

@end
