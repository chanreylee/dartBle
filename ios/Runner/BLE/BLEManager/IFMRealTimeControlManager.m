//
//  IFMRealTimeControlManager.m
//  P3KApp
//
//  Created by 王泽 on 2017/1/19.
//  Copyright © 2017年 Infomedia. All rights reserved.
//

#import "IFMRealTimeControlManager.h"
#import "IFMDevice.h"

@interface IFMRealTimeControlManager ()
@property (nonatomic, assign)   xU16    objectId;
@property (nonatomic, strong)   NSData  *keyData;
@property (nonatomic, assign)   xU32    eventType;
@property (nonatomic, assign)   xU32    length;
@property (nonatomic, assign)   IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong)   NSString                *errorReason;

@property (nonatomic, assign)   BOOL    isSendDataPacket;
@end


@implementation IFMRealTimeControlManager
@synthesize errorType;
@synthesize errorReason;

- (xU16)oldObjectId {
    return DEVICE_OBJECTID_CONTROL;
}

- (void)setupObjectId:(xU16)objectId {
    self.objectId = objectId;
}

- (void)setupEventType:(xU32)eventType {

    self.eventType = eventType;
}

- (void)setupData:(NSData *)data {
    self.keyData = [data copy];
}

- (void)setupLength:(xU32)length {

    self.length = length;

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
    cmd.objID = [self oldObjectId];
    cmd.offset = self.eventType;
    cmd.len = self.length;
    
    if (self.objectId > 0) {
        cmd.objID = self.objectId;
    }
    
    if ([self.keyData length] > 0) {
        memcpy(&cmd.ex, [self.keyData bytes], P3K_CMD_EXPARAM_SIZE);
    }
    
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    
    {
    
        if (self.objectId == DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY) {
            NSLog(@"DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY : %@",cmdData);
        }
        if (self.objectId == DEVICE_OBJECTID_FIRMWARE_CHECK_AND_UPDATA) {
            NSLog(@"DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY : %@",cmdData);
        }
    }
    
    [self sendData:cmdData withResponse:NO];
    
    if (self.length > P3K_CMD_EXPARAM_SIZE) {
        self.isSendDataPacket = NO;
    } else {
        self.isSendDataPacket = YES;
    }

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
            
            if (device.objectID == DEVICE_OBJECTID_CONTROL) {
                
                if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK){
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"实时控制命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"实时控制命令已发出了数据包";
                        [self failCallback];
                    }
                }
            } else if (device.objectID == DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY) {
                
                if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK){
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"实时控制命令(key)只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"实时控制命令已发出了数据包";
                        [self failCallback];
                    }
                }

            } else if (device.objectID == DEVICE_OBJECTID_SETUP) {
                
                if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK){
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"系统设置命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"系统设置命令已发出了数据包";
                        [self failCallback];
                    }
                }
                
            }else if (device.objectID == DEVICE_OBJECTID_FIRMWARE_CHECK_AND_UPDATA) {
                
                if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK){
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"固件升级命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"固件升级命令已发出了数据包";
                        [self failCallback];
                    }
                }
                
            }else if (device.objectID == DEVICE_OBJECTID_STATICS) {
                
                if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK){
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"清除运动记录命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"清除运动记录已发出了数据包";
                        [self failCallback];
                    }
                }
                
            } else if (device.objectID == DEVICE_OBJECTID_UNSUPPORT_SONG_DBID) {
                
                if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK){
                    if (self.isSendDataPacket) {
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"清除标记命令只发了一个包";
                        [self failCallback];
                    }
                }
                else {
                    if (!self.isSendDataPacket) {
                        [self sendData];
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"清除标记已发出了数据包";
                        [self failCallback];
                    }
                }
                
            }
            else {
                self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                self.errorReason = @"不是实时控制命令的response 或者写key命令 再或者系统设置命令";
                [self failCallback];
            }
        }
    }
}


@end
