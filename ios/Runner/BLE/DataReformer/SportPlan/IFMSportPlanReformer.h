//
//  IFMSportPlanReformer.h
//  P3KApp
//
//  Created by Guanghua Huo on 16/6/7.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFMBLEManager.h"

@interface IFMSportPlanReformer : NSObject <IFMBLEManagerCallbackReformer>
@property (nonatomic, strong, readonly) NSNumber    *version;
@property (nonatomic, copy)     NSString    *name;
@property (nonatomic, assign)   xU16        type;
@property (nonatomic, assign)   xU16        bpm;
@property (nonatomic, assign)   xU32        distance;
@property (nonatomic, assign)   xU32        timeInSeconds;
@property (nonatomic, assign)   xU16        pace;

@property (nonatomic, strong, readonly) NSData      *rawData;
@end
