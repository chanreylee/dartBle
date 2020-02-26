//
//  IFMSportPlanReformer.m
//  P3KApp
//
//  Created by Guanghua Huo on 16/6/7.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMSportPlanReformer.h"
#import "IFMSportPlanPropertyKeys.h"

/*
 此结构的版本
 xU32
 */
NSString * const kIFMSportPlanPropertyKeys_Version = @"kIFMSportPlanPropertyKeys_Version";

/*
 运动计划名称
 NSString
 */
NSString * const kIFMSportPlanPropertyKeys_Name = @"kIFMSportPlanPropertyKeys_Name";

/*
 运动类型
 xU16
 */
NSString * const kIFMSportPlanPropertyKeys_Type = @"kIFMSportPlanPropertyKeys_Type";

/*
 目标bpm
 xU16
 */
NSString * const kIFMSportPlanPropertyKeys_BPM = @"kIFMSportPlanPropertyKeys_BPM";

/*
 目标距离（单位：米）
 xU32
 */
NSString * const kIFMSportPlanPropertyKeys_Distance = @"kIFMSportPlanPropertyKeys_Distance";

/*
 时间（单位：秒）
 xU32
 */
NSString * const kIFMSportPlanPropertyKeys_Time = @"kIFMSportPlanPropertyKeys_Time";

/*
 配速（单位：秒/公里）
 xU16
 */
NSString * const kIFMSportPlanPropertyKeys_Pace = @"kIFMSportPlanPropertyKeys_Pace";

@interface IFMSportPlanReformer ()
@property (nonatomic, assign)   BlePlanItem    *pPlanItem;

@property (nonatomic, strong)   NSMutableDictionary *diccionary;
@end

@implementation IFMSportPlanReformer

#pragma mark - life cycle methods

- (void)dealloc {
    if (self.pPlanItem) {
        free(self.pPlanItem);
        self.pPlanItem = NULL;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pPlanItem = malloc(sizeof(BlePlanItem));
        memset(self.pPlanItem, 0, sizeof(BlePlanItem));
        self.pPlanItem->planVer = 1;
    }
    
    return self;
}

#pragma mark - public methods

- (id)bleManager:(IFMBLEManager*)manager reformData:(NSData*)data {
    memset(self.pPlanItem, 0, sizeof(BlePlanItem));
    memcpy(self.pPlanItem, [data bytes], sizeof(BlePlanItem));
    
    [self.diccionary removeAllObjects];
    
    // version
    self.diccionary[kIFMSportPlanPropertyKeys_Version] = @(self.pPlanItem->planVer);
    
    // name
    NSString *name = [[NSString alloc] initWithBytes:self.pPlanItem->planName length:sizeof(self.pPlanItem->planName) encoding:NSUTF8StringEncoding];
    self.diccionary[kIFMSportPlanPropertyKeys_Name] = name;
    
    // type
    self.diccionary[kIFMSportPlanPropertyKeys_Type] = @(self.pPlanItem->type);
    
    // bpm
    self.diccionary[kIFMSportPlanPropertyKeys_BPM] = @(self.pPlanItem->bpm);
    
    // distance
    self.diccionary[kIFMSportPlanPropertyKeys_Distance] = @(self.pPlanItem->distance);
    
    // time
    self.diccionary[kIFMSportPlanPropertyKeys_Time] = @(self.pPlanItem->time);
    
    // pace
    self.diccionary[kIFMSportPlanPropertyKeys_Pace] = @(self.pPlanItem->pace);
    
    return [self.diccionary copy];
}

#pragma mark - getter methods

- (NSMutableDictionary*)diccionary {
    if (!_diccionary) {
        _diccionary = [NSMutableDictionary new];
    }
    
    return _diccionary;
}

- (NSNumber*)version {
    return self.diccionary[kIFMSportPlanPropertyKeys_Version];
}

- (NSString*)name {
    return self.diccionary[kIFMSportPlanPropertyKeys_Name];
}

- (xU16)type {
    return [self.diccionary[kIFMSportPlanPropertyKeys_Type] unsignedShortValue];
}

- (xU16)bpm {
    return [self.diccionary[kIFMSportPlanPropertyKeys_BPM] unsignedShortValue];
}

- (xU32)distance {
    return [self.diccionary[kIFMSportPlanPropertyKeys_Distance] unsignedIntValue];
}

- (xU32)timeInSeconds {
    return [self.diccionary[kIFMSportPlanPropertyKeys_Time] unsignedIntValue];
}

- (xU16)pace {
    return [self.diccionary[kIFMSportPlanPropertyKeys_Pace] unsignedShortValue];
}

- (NSData*)rawData {
    return [NSData dataWithBytes:self.pPlanItem length:sizeof(BlePlanItem)];
}

#pragma mark - setter methods

- (void)setName:(NSString *)name {
    if ([name length] == 0) {
        return;
    }
    
    const void * pName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    memset(self.pPlanItem->planName, 0, sizeof(self.pPlanItem->planName));
    memcpy(self.pPlanItem->planName, pName, strlen(pName));
    
    self.diccionary[kIFMSportPlanPropertyKeys_Name] = name;
}

- (void)setType:(xU16)type {
    self.pPlanItem->type = type;
    self.diccionary[kIFMSportPlanPropertyKeys_Type] = @(type);
}

- (void)setBpm:(xU16)bpm {
    self.pPlanItem->bpm = bpm;
    self.diccionary[kIFMSportPlanPropertyKeys_BPM] = @(bpm);
}

- (void)setDistance:(xU32)distance {
    self.pPlanItem->distance = distance;
    self.diccionary[kIFMSportPlanPropertyKeys_Distance] = @(distance);
}

- (void)setTimeInSeconds:(xU32)timeInSeconds {
    self.pPlanItem->time = timeInSeconds;
    self.diccionary[kIFMSportPlanPropertyKeys_Time] = @(timeInSeconds);
}

- (void)setPace:(xU16)pace {
    self.pPlanItem->pace = pace;
    self.diccionary[kIFMSportPlanPropertyKeys_Pace] = @(pace);
}

@end
