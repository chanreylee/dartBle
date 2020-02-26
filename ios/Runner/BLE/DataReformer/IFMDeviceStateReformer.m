//
//  IFMDeviceStateReformer.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMDeviceStateReformer.h"

@implementation IFMDeviceStateReformer

- (IFMDevice*)bleManager:(IFMBLEManager*)manager reformData:(NSData*)data {
    const void* pData = [data bytes];
    UInt8 btype = 0;
    memcpy(&btype, pData, sizeof(UInt8));
    if (btype == P3K_CMD_STATES) {
        IFMDevice *device = [[IFMDevice alloc] init];
        [device fillDeviceStateWithData:data];
        return device;
    }
    
    return nil;
}

@end
