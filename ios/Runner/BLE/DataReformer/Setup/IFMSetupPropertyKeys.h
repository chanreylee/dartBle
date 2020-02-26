//
//  IFMSetupPropertyKeys.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/25.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#ifndef IFMSetupPropertyKeys_h
#define IFMSetupPropertyKeys_h

#import <Foundation/Foundation.h>

/*
 此结构体版本，做版本兼容时会用到
 xU32
 */
extern NSString * const kIFMSetupPropertyKey_Version;

/*
 软件版本  固件版本
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_Software;

/*
 硬件版本
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_Hardware;

/*
 loader版本
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_LoaderVersion;

/*
 baseloader版本
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_Baseloader;

/*
 gps版本
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_GPSVersion;

/*
 蓝牙芯片版本
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_BLEVersion;

/*
 音频文件数
 xU32
 */
extern NSString * const kIFMSetupPropertyKey_FileCount;

/*
 磁盘容量
 xU64
 */
extern NSString * const kIFMSetupPropertyKey_DiskCapacity;

/*
 剩余容量
 xU64
 */
extern NSString * const kIFMSetupPropertyKey_RemainCapacity;

/*
 产品型号(字符串)
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_DevModel;

/*
 设备序列号(字符串)
 NSString
 */
extern NSString * const kIFMSetupPropertyKey_SerialNo;

/*
 是否打开自动语音播报(每公里自动播报，以及运动计划提示)
 BOOL
 */
extern NSString * const kIFMSetupPropertyKey_AutoVoice;

/*
 语音播报内容选项 时间
 BOOL
 */
extern NSString * const kIFMSetupPropertyKey_VoiceContent_Time;

/*
 语音播报内容选项 距离
 BOOL
 */
extern NSString * const kIFMSetupPropertyKey_VoiceContent_Distance;

/*
 语音播报内容选项 配速
 BOOL
 */
extern NSString * const kIFMSetupPropertyKey_VoiceContent_Pace;

/*
 语音播报内容选项 步频
 BOOL
 */
extern NSString * const kIFMSetupPropertyKey_VoiceContent_Frequency;


#endif /* IFMSetupPropertyKeys_h */
