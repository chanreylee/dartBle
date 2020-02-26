//
//  IFMSetupDataReformer.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/25.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMSetupDataReformer.h"
#import "IFMSetupPropertyKeys.h"

/*
 此结构体版本，做版本兼容时会用到
 xU32
 */
NSString * const kIFMSetupPropertyKey_Version = @"kIFMSetupPropertyKey_Version";

/*
 软件版本  固件版本
 NSString
 */
NSString * const kIFMSetupPropertyKey_Software = @"kIFMSetupPropertyKey_Software";

/*
 硬件版本
 NSString
 */
NSString * const kIFMSetupPropertyKey_Hardware = @"kIFMSetupPropertyKey_Hardware";

/*
 loader版本
 NSString
 */
NSString * const kIFMSetupPropertyKey_LoaderVersion = @"kIFMSetupPropertyKey_LoaderVersion";

/*
 baseloader版本
 NSString
 */
NSString * const kIFMSetupPropertyKey_Baseloader = @"kIFMSetupPropertyKey_Baseloader";

/*
 gps版本
 NSString
 */
NSString * const kIFMSetupPropertyKey_GPSVersion = @"kIFMSetupPropertyKey_GPSVersion";

/*
 蓝牙芯片版本
 NSString
 */
NSString * const kIFMSetupPropertyKey_BLEVersion = @"kIFMSetupPropertyKey_BLEVersion";

/*
 音频文件数
 xU32
 */
NSString * const kIFMSetupPropertyKey_FileCount = @"kIFMSetupPropertyKey_FileCount";

/*
 磁盘容量
 xU64
 */
NSString * const kIFMSetupPropertyKey_DiskCapacity = @"kIFMSetupPropertyKey_DiskCapacity";

/*
 剩余容量
 xU64
 */
NSString * const kIFMSetupPropertyKey_RemainCapacity = @"kIFMSetupPropertyKey_RemainCapacity";

/*
 产品型号(字符串)
 NSString
 */
NSString * const kIFMSetupPropertyKey_DevModel = @"kIFMSetupPropertyKey_DevModel";

/*
 设备序列号(字符串)
 NSString
 */
NSString * const kIFMSetupPropertyKey_SerialNo = @"kIFMSetupPropertyKey_SerialNo";

/*
 芯片mac地址(字符串)
 NSString
 */
NSString * const kIFMSetupPropertyKey_MacNo = @"kIFMSetupPropertyKey_MacNo";

///*
// 是否打开自动语音播报(每公里自动播报，以及运动计划提示)
// BOOL
// */
//NSString * const kIFMSetupPropertyKey_AutoVoice = @"kIFMSetupPropertyKey_AutoVoice";
//
///*
// 语音播报内容选项 时间
// BOOL
// */
//NSString * const kIFMSetupPropertyKey_VoiceContent_Time = @"kIFMSetupPropertyKey_VoiceContent_Time";
//
///*
// 语音播报内容选项 距离
// BOOL
// */
//NSString * const kIFMSetupPropertyKey_VoiceContent_Distance = @"kIFMSetupPropertyKey_VoiceContent_Distance";
//
///*
// 语音播报内容选项 配速
// BOOL
// */
//NSString * const kIFMSetupPropertyKey_VoiceContent_Pace = @"kIFMSetupPropertyKey_VoiceContent_Pace";
//
///*
// 语音播报内容选项 步频
// BOOL
// */
//NSString * const kIFMSetupPropertyKey_VoiceContent_Frequency = @"kIFMSetupPropertyKey_VoiceContent_Frequency";

@interface IFMSetupDataReformer ()
@property (nonatomic, assign)   BleSetupItem    *pSetupData;

@property (nonatomic, strong)   NSMutableDictionary *diccionary;
@end

@implementation IFMSetupDataReformer

- (void)dealloc {
    if (self.pSetupData) {
        free(self.pSetupData);
        self.pSetupData = NULL;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pSetupData = malloc(sizeof(BleSetupItem));
        memset(self.pSetupData, 0, sizeof(BleSetupItem));
    }
    
    return self;
}

- (NSString*)convertHexToStringVersion:(xU32)version {
    NSMutableString *string = [NSMutableString new];
    
    [string appendFormat:@"%d.", version & 0x000000ff];
    [string appendFormat:@"%d.",(version & 0x0000ff00) >> 8];
    [string appendFormat:@"%d.", (version & 0x00ff0000) >> 16];
    [string appendFormat:@"%d", (version & 0xff000000) >> 24];
        
    return [string copy];
}

- (NSString*)convertHexToStringVersion_2:(xU32)version {
    NSMutableString *string = [NSMutableString new];
    
    [string appendFormat:@"%d.", (version & 0xff000000) >> 24];
    [string appendFormat:@"%d.", (version & 0x00ff0000) >> 16];
    [string appendFormat:@"%d.",(version & 0x0000ff00) >> 8];
    [string appendFormat:@"%d", version & 0x000000ff];
    
    return [string copy];
}

- (NSString *)convertHexToStringBleNum:(xU32)bleNum {

    xU8  hw_h, hw_l, fw_1,fw_2, fw_3;
    
    hw_h = ((bleNum >> (16 + 4)) & 0xf);
    hw_l = ((bleNum >> 16) & 0xf);
    fw_1 = ((bleNum >> 8) & 0xff);
    fw_2 = ((bleNum >> 4) & 0xf);
    fw_3 = ((bleNum) & 0xf);
    
    return [NSString stringWithFormat:@"%d.%d-%d.%d.%d",hw_h,hw_l,fw_1,fw_2,fw_3];
}

- (id)bleManager:(IFMBLEManager*)manager reformData:(NSData*)data {
    memset(self.pSetupData, 0, sizeof(BleSetupItem));
    memcpy(self.pSetupData, [data bytes], sizeof(BleSetupItem));
    
    [self.diccionary removeAllObjects];
    
    self.diccionary[kIFMSetupPropertyKey_Version] = @(self.pSetupData->setupItemVer);
    self.diccionary[kIFMSetupPropertyKey_Software] = [self convertHexToStringVersion_2:self.pSetupData->software];
    self.diccionary[kIFMSetupPropertyKey_Hardware] = [self convertHexToStringVersion:self.pSetupData->hardware];
    self.diccionary[kIFMSetupPropertyKey_LoaderVersion] = [self convertHexToStringVersion:self.pSetupData->loaderVersion];
    self.diccionary[kIFMSetupPropertyKey_Baseloader] = [self convertHexToStringVersion:self.pSetupData->baseloader];
    self.diccionary[kIFMSetupPropertyKey_GPSVersion] = [self convertHexToStringVersion:self.pSetupData->gpsVer];
    self.diccionary[kIFMSetupPropertyKey_BLEVersion] = [self convertHexToStringBleNum:self.pSetupData->bleVer];
    
    self.diccionary[kIFMSetupPropertyKey_FileCount] = @(self.pSetupData->tfileno);
    self.diccionary[kIFMSetupPropertyKey_DiskCapacity] = @(self.pSetupData->diskCapacity);
    self.diccionary[kIFMSetupPropertyKey_RemainCapacity] = @(self.pSetupData->remainCapacity);
    
    NSString *modelStr = [NSString stringWithFormat:@"%s",self.pSetupData->devModel];
    self.diccionary[kIFMSetupPropertyKey_DevModel] = modelStr;

    NSString *serialStr = [NSString stringWithFormat:@"%s",self.pSetupData->serialNo];
    self.diccionary[kIFMSetupPropertyKey_SerialNo] = serialStr;
    
    NSString *macid = [self convertHexToStringVersion_2:self.pSetupData->hardware_id];
    NSString *macid_2 = [self convertHexToStringVersion:self.pSetupData->hardware_id];
    
    xU64 macNumber = *(xU64 *)(self.pSetupData->hardware_id);
    NSString *macNo = [NSString stringWithFormat:@"%llu",macNumber];
    
    self.diccionary[kIFMSetupPropertyKey_MacNo] = macNo;
    
    return [self.diccionary copy];
}

#pragma mark - getter & setter methods

- (NSMutableDictionary*)diccionary {
    if (!_diccionary) {
        _diccionary = [NSMutableDictionary new];
    }
    
    return _diccionary;
}

- (NSNumber*)version {
    return self.diccionary[kIFMSetupPropertyKey_Version];
}

- (NSString*)software {
    return self.diccionary[kIFMSetupPropertyKey_Software];
}

- (NSString*)hardware {
    return self.diccionary[kIFMSetupPropertyKey_Hardware];
}

- (NSString*)loaderVersion {
    return self.diccionary[kIFMSetupPropertyKey_LoaderVersion];
}

- (NSString*)baseloader {
    return self.diccionary[kIFMSetupPropertyKey_Baseloader];
}

- (NSString*)gpsVersion {
    return self.diccionary[kIFMSetupPropertyKey_GPSVersion];
}

- (NSString*)bleVersion {
    return self.diccionary[kIFMSetupPropertyKey_BLEVersion];
}

- (int32_t)fileCount {
    return [self.diccionary[kIFMSetupPropertyKey_FileCount] intValue];
}


- (NSString*)stringFromBytesCount:(xU64)count {
    int32_t mCount = (int32_t)(count / (1024 * 1024));
    
    NSString *string = nil;
    if (mCount > 1024) {
        int32_t gCount = mCount / 1024;
        int32_t temp = mCount % 1024;
        
        if (temp == 0) {
            string = [NSString stringWithFormat:@"%dG", gCount];
        }
        else {
            string = [NSString stringWithFormat:@"%.2fG", ((double)gCount + (double)temp / (double)1024)];
        }
    }
    else {
        int32_t temp = count % (1024 * 1024);
        if (temp) {
            string = [NSString stringWithFormat:@"%dM", mCount];
        }
        else {
            string = [NSString stringWithFormat:@"%.2fM", ((double)mCount + (double)temp / (double)1024*1024)];
        }
    }
    
    return string;
}

- (NSString*)diskCapacity {
    xU64 count = [self.diccionary[kIFMSetupPropertyKey_DiskCapacity] unsignedLongLongValue];
    return [self stringFromBytesCount:count];
}

- (xU64)diskCapacity_int {
    xU64 count = [self.diccionary[kIFMSetupPropertyKey_DiskCapacity] unsignedLongLongValue];
    return count;
}

- (NSString*)remainCapacity {
    xU64 count = [self.diccionary[kIFMSetupPropertyKey_RemainCapacity] unsignedLongLongValue];
    return [self stringFromBytesCount:count];
}

- (NSString*)devModel {
    return self.diccionary[kIFMSetupPropertyKey_DevModel];
}

- (NSString*)serialNo {
    return self.diccionary[kIFMSetupPropertyKey_SerialNo];
}

- (NSString *)macNo {

    return self.diccionary[kIFMSetupPropertyKey_MacNo];
}

- (NSData*)rawData {
    return [NSData dataWithBytes:self.pSetupData length:sizeof(BleSetupItem)];
}

@end
