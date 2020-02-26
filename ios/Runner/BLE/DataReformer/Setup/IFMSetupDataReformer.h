//
//  IFMSetupDataReformer.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/25.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFMBLEManager.h"

@interface IFMSetupDataReformer : NSObject <IFMBLEManagerCallbackReformer>
@property (nonatomic, strong, readonly) NSNumber    *version;
@property (nonatomic, strong, readonly) NSString    *software;
@property (nonatomic, strong, readonly) NSString    *hardware;
@property (nonatomic, strong, readonly) NSString    *loaderVersion;
@property (nonatomic, strong, readonly) NSString    *baseloader;
@property (nonatomic, strong, readonly) NSString    *gpsVersion;
@property (nonatomic, strong, readonly) NSString    *bleVersion;
@property (nonatomic, assign, readonly) int32_t     fileCount;
@property (nonatomic, strong, readonly) NSString    *diskCapacity;
@property (nonatomic, assign, readonly) xU64        diskCapacity_int;
@property (nonatomic, strong, readonly) NSString    *remainCapacity;
@property (nonatomic, strong, readonly) NSString    *devModel;
@property (nonatomic, strong, readonly) NSString    *serialNo;
@property (nonatomic, strong, readonly) NSString    *macNo;
@property (nonatomic, assign)           BOOL        autoVoice;
@property (nonatomic, assign)           BOOL        isVoiceTimeSelected;
@property (nonatomic, assign)           BOOL        isVoiceDistanceSelected;
@property (nonatomic, assign)           BOOL        isVoicePaceSelected;
@property (nonatomic, assign)           BOOL        isVoiceFrequencySelected;

@property (nonatomic, strong, readonly) NSData      *rawData;
@end
