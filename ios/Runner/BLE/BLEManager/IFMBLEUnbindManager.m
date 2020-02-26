//
//  IFMBLEUnbindManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEUnbindManager.h"
#import "IFMBLEAuthorizeManager.h"
#import "IFMDevice.h"
#import "IFMBLEBreakManager.h"

@interface IFMBLEUnbindManager () <IFMBLEManagerCallbackDelegate>
@property (nonatomic, strong) NSData                  *authorizeData;
@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;
@property (nonatomic, strong) IFMBLEAuthorizeManager  *authorizeManager;
@property (nonatomic, strong) IFMBLEBreakManager      *breakManager;
@property (nonatomic, assign) BOOL                    firstUnbingFailed;

@property (nonatomic, assign)   double      startTimeInterval;
@property (nonatomic, assign)   double      currentTimeInterval;
@end

@implementation IFMBLEUnbindManager
@synthesize errorType;
@synthesize errorReason;

- (xU16)objectId {
    return DEVICE_OBJECTID_AUTHORIZE;
}

- (xU32)eventType {
    return AUTHORIZE_OFFSET_UNBIND;
}

- (void)setupData:(NSData*)data {
    self.authorizeData = [data copy];
}

- (void)start {
    if (self.needAuthorize) {
        if (self.authorizeData) {
            [self.authorizeManager setupData:self.authorizeData];
        }
        else {
            NSMutableData *keyData = [NSMutableData dataWithLength:P3K_KEY_LENGTH];
            [self.authorizeManager setupData:keyData];
        }
        
        [self.authorizeManager execute];
    }
    else {
        [self sendCMD];
    }
}

- (void)sendCMD {
    P3K_Write_CMD cmd;
    memset(&cmd, 0, sizeof(P3K_Write_CMD));
    cmd.btype = P3K_CMD_WRITE;
    cmd.bno = 0;
    cmd.objID = [self objectId];
    cmd.offset = [self eventType];
    cmd.len = 0;
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    [self sendData:cmdData withResponse:NO];
    self.startTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
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
        self.currentTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        
        const void* pData = [data bytes];
        UInt8 btype = 0;
        memcpy(&btype, pData, sizeof(UInt8));
        if (btype == P3K_CMD_STATES) {
            IFMDevice *device = [[IFMDevice alloc] init];
            [device fillDeviceStateWithData:data];
            
            if (device.objectID == DEVICE_OBJECTID_AUTHORIZE) {
                
                if (device.isBind == NO) {
                    [self.rawData setLength:0];
                    [self.rawData appendData:data];
                    [self successCallback];
                }
                else {
                    self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                    self.errorReason = @"解除绑定失败";
                    [self failCallback];
                }
            }
            else {
                
                if ((self.currentTimeInterval - self.startTimeInterval) > 200) {
                    
                    if (self.firstUnbingFailed == NO) {
                        self.firstUnbingFailed = YES;
                        [self.breakManager execute];
                        
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"没有收到解绑的响应";
                        [self failCallback];
                    }
                }
            }
        }
    }
}

#pragma mark - IFMBLEManagerCallbackDelegate

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    [self openNotify];
    [self sendCMD];
    
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    if (manager == self.authorizeManager) {
        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
        self.errorReason = @"验证设备失败";
        [self failCallback];
    } else if (manager == self.breakManager){
        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
        self.errorReason = @"解绑失败";
        [self failCallback];

    }
}


#pragma mark - getter & setter methods

- (IFMBLEAuthorizeManager*)authorizeManager {
    if (!_authorizeManager) {
        _authorizeManager = [[IFMBLEAuthorizeManager alloc] init];
        _authorizeManager.delegate = self;
    }
    
    return _authorizeManager;
}

- (IFMBLEBreakManager*)breakManager {
    if (!_breakManager) {
        _breakManager = [[IFMBLEBreakManager alloc] init];
        _breakManager.delegate = self;
    }
    
    return _breakManager;
}

@end
