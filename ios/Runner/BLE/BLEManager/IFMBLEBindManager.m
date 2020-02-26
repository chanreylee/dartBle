//
//  IFMBLEBindManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEBindManager.h"
//#import "IFMBLEAuthorizeManager.h"
#import "IFMDevice.h"

@interface IFMBLEBindManager ()
@property (nonatomic, strong) NSData  *keyData;
@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;

//@property (nonatomic, strong) IFMBLEAuthorizeManager  *authorizeManager;

@property (nonatomic, assign) BOOL isSendDataPacket;
@end

@implementation IFMBLEBindManager
@synthesize errorType;
@synthesize errorReason;

- (xU16)objectId {
    return DEVICE_OBJECTID_AUTHORIZE;
}

- (xU32)eventType {
    return AUTHORIZE_OFFSET_BIND;
}

- (void)setupData:(NSData *)data {
    self.keyData = [data copy];
    self.isSendDataPacket = NO;
}

- (void)start {
//    if (self.needAuthorize) {
//        NSMutableData *keyData = [NSMutableData dataWithLength:P3K_KEY_LENGTH];
//        [self.authorizeManager setupData:keyData];
//        [self.authorizeManager execute];
//    }
//    else {
        self.isSendDataPacket = NO;
        [self sendCMD];
//    }
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
            if (self.device.objectID == DEVICE_OBJECTID_AUTHORIZE) {
                if (self.device.isBind) {
                    if (self.isSendDataPacket) {
                        
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"绑定命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"绑定命令已发出的数据包";
                        [self failCallback];
                    }
                }
            }
            else {
                self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                self.errorReason = @"不是绑定命令的response";
                [self failCallback];
            }
        }
    }
}

#pragma mark - IFMBLEManagerCallbackDelegate

//- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
//    [self openNotify];
//    [self sendCMD];
//}
//
//- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
//    self.errorType = IFMBLEManagerErrorTypeIncorrectData;
//    self.errorReason = @"验证设备失败";
//    [self failCallback];
//}
//
//#pragma mark - getter & setter methods
//
//- (IFMBLEAuthorizeManager*)authorizeManager {
//    if (!_authorizeManager) {
//        _authorizeManager = [[IFMBLEAuthorizeManager alloc] init];
//        _authorizeManager.delegate = self;
//    }
//    
//    return _authorizeManager;
//}

@end
