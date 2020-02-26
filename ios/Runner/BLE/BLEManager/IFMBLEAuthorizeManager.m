//
//  IFMBLEAuthorizeManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEAuthorizeManager.h"
#import "IFMDevice.h"

@interface IFMBLEAuthorizeManager ()
@property (nonatomic, strong) NSData                    *keyData;
@property (nonatomic, assign) IFMBLEManagerErrorType    errorType;
@property (nonatomic, strong) NSString                  *errorReason;

@property (nonatomic, assign) BOOL                    isSendDataPacket;
@end

@implementation IFMBLEAuthorizeManager
@synthesize errorType;
@synthesize errorReason;

- (xU16)objectId {
    return DEVICE_OBJECTID_AUTHORIZE;
}

- (xU32)eventType {
    return AUTHORIZE_OFFSET_AUTH;
}

- (void)setupData:(NSData *)data {
    self.keyData = [data copy];
}

- (void)start {
    self.isSendDataPacket = NO;
    [self sendCMD];
}

- (void)sendCMD {
    P3K_Write_CMD cmd;
    memset(&cmd, 0, sizeof(P3K_Write_CMD));
    cmd.btype = P3K_CMD_WRITE;
    cmd.bno = 0;
    cmd.objID = [self objectId];
    cmd.offset = [self eventType];
    cmd.len = P3K_KEY_LENGTH;
    
    if ([self.keyData length] > 0) {
        memcpy(&cmd.ex, [self.keyData bytes], P3K_CMD_EXPARAM_SIZE);
    }
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    [self sendData:cmdData withResponse:NO];
}

- (void)sendData {
    P3K_Data keyData;
    memset(&keyData, 0, sizeof(P3K_Data));
    keyData.btype = P3K_CMD_DATA;
    keyData.bno = 0;
    
    if ([self.keyData length] > 0) {
        const void * pData = [self.keyData bytes];
        pData += P3K_CMD_EXPARAM_SIZE;
        memcpy(&keyData.data, pData, [self.keyData length] - P3K_CMD_EXPARAM_SIZE);
    }
    
    NSData *cmdData = [NSData dataWithBytes:&keyData length:sizeof(P3K_Data)];
    [self sendData:cmdData withResponse:NO];
    
    self.isSendDataPacket = YES;
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
            IFMDevice *device = [[IFMDevice alloc] init];
            [device fillDeviceStateWithData:data];
            self.device = device;
            if (device.objectID == DEVICE_OBJECTID_AUTHORIZE) {
                if (device.isAuthorized) {
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"授权命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"授权命令已发出了数据包,但是仍然授权失败";
                        [self failCallback];
                    }
                }
            }
            else {
                self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                self.errorReason = @"不是授权命令的response";
                [self failCallback];
            }
        }
    }
}

@end
