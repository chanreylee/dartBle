//
//  IFMBLEBreakManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/26.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEBreakManager.h"
#import "IFMDevice.h"

@interface IFMBLEBreakManager ()
@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;
@end

@implementation IFMBLEBreakManager
@synthesize errorType;
@synthesize errorReason;

- (void)start {
    [self sendCMD];
}

- (void)sendCMD {
    P3K_Write_CMD cmd;
    memset(&cmd, 0, sizeof(P3K_Write_CMD));
    cmd.btype = P3K_CMD_BREAK;
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    [self sendData:cmdData withResponse:NO];
}

- (void)didWriteValueWithError:(NSError*)error {
    
}

- (void)didReadValue:(NSData*)data error:(NSError*)error {
    if (error) {
        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
        self.errorReason = [NSString stringWithFormat:@"读取数据失败:%@", [error localizedDescription]];
        [self failCallback];
    }
    else {
        const void* pData = [data bytes];
        UInt8 btype = 0;
        memcpy(&btype, pData, sizeof(UInt8));
        if (btype == P3K_CMD_STATES) {
            
            IFMDevice *device = [IFMDevice new];
            [device fillDeviceStateWithData:data];
            if (device.isWritting || device.lastCMDResult == RET_CODE_IS_WRITING) {
                self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                self.errorReason = @"Break IsWritting";
                [self failCallback];
            }
            else {
                [self.rawData setLength:0];
                [self.rawData appendData:data];
                [self successCallback];
            }
        }
        else {
            self.errorType = IFMBLEManagerErrorTypeIncorrectData;
            self.errorReason = @"没有收到Break的响应";
            [self failCallback];
        }
    }
}

@end
