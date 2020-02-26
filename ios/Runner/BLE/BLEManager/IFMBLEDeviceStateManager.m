//
//  IFMBLEDeviceStateManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEDeviceStateManager.h"

@interface IFMBLEDeviceStateManager ()
@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;
@end

@implementation IFMBLEDeviceStateManager
@synthesize errorType;
@synthesize errorReason;

- (void)start {
    [self sendCMD];
}

- (void)sendCMD {
    P3K_Write_CMD cmd;
    memset(&cmd, 0, sizeof(P3K_Write_CMD));
    cmd.btype = P3K_CMD_STATES;
    cmd.bno = 0;
    cmd.objID = 0;
    cmd.offset = 0;
    cmd.len = 0;
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    [self sendData:cmdData withResponse:NO];
}

- (void)didWriteValueWithError:(NSError*)error {
    NSLog(@"");
}

- (void)didReadValue:(NSData*)data error:(NSError*)error {
    if (error) {
        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
        self.errorReason = [NSString stringWithFormat:@"读取数据失败:%@", [error localizedDescription]];
        [self failCallback];
    }
    else {
        IFMDevice *device = [[IFMDevice alloc] init];
        [device fillDeviceStateWithData:data];
        self.device = device;
        [self.rawData setLength:0];
        
        [self.rawData appendData:data];
            
        [self successCallback];
    }
}

@end
