//
//  IFMBLEReadManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEReadManager.h"
#import "IFMDevice.h"
#import "IFMHeartbeatPacket.h"
#import "IFMBLEBreakManager.h"

NSInteger const IFMBLEReadManager_Read_State_Interval = 20;

@interface IFMBLEReadManager ()<IFMBLEManagerCallbackDelegate>
@property (nonatomic, assign)   xU16    objectId;
@property (nonatomic, assign)   xU32    length;
@property (nonatomic, assign)   xU16    param;
@property (nonatomic, assign)   xU32    eventType;
@property (nonatomic, assign)   xU32    dbId;
@property (nonatomic, assign)   xU16    dbpos;

@property (nonatomic, assign)   xU32    lat;    //纬度
@property (nonatomic, assign)   xU32    lon;    //经度

@property (nonatomic, assign)   int32_t totalBytesNeedRead;
@property (nonatomic, assign)   int32_t totalPacketCount;
@property (nonatomic, assign)   int32_t currentPacketNumber;

@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;

@property (nonatomic, assign)   BOOL                firstCheckFailed;
@property (nonatomic, strong)   IFMBLEBreakManager  *breakManager;
@property (nonatomic, assign)   double              startTimeInterval;
@property (nonatomic, assign)   double              currentTimeInterval;
@end

@implementation IFMBLEReadManager
@synthesize errorType;
@synthesize errorReason;

- (void)setupObjectId:(xU16)objectId {
    self.objectId = objectId;
    [self clear];
}

- (void)setupLength:(xU32)length {
    self.totalBytesNeedRead = length;
    
    self.totalPacketCount = self.totalBytesNeedRead / BLE_MAX_DATA_SIZE;
    if (self.totalBytesNeedRead % BLE_MAX_DATA_SIZE > 0) {
        self.totalPacketCount += 1;
    }
    
    self.currentPacketNumber = 0;
}

- (void)setupParam:(xU16)param {
    self.param = param;
}

- (void)setupEventType:(xU32)eventType {
    
    self.eventType = eventType;
}

- (void)setupDbId:(xU32)dbId Dbpos:(xU16)dbpos {
    
    self.dbId = dbId;
    self.dbpos = dbpos;
}

- (void)setupLat:(xU32)lat lon:(xU32)lon {
    self.lat = lat;
    self.lon = lon;
}

- (void)start {
    [self.rawData setLength:0];
    self.firstCheckFailed = NO;
    [self sendReadCMD];
}

- (void)sendReadCMD {
    P3K_Read_CMD cmd;
    P3K_ReadStatic_CMD *pCmd = (P3K_ReadStatic_CMD*)&cmd;
    memset(&cmd, 0, sizeof(P3K_Read_CMD));
    cmd.btype = P3K_CMD_READ;
    cmd.bno = self.currentPacketNumber ;
    cmd.objID = self.objectId;
    cmd.len = self.totalBytesNeedRead;
    cmd.offset = self.currentPacketNumber * BLE_MAX_DATA_SIZE;
    pCmd->param = self.param;
    
    
    if (self.objectId == DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER) {
        
        P3K_Check_Read_MediaList_CMD * cmda = (P3K_Check_Read_MediaList_CMD*)&cmd;
        cmda->dbid = self.dbId;
        cmda->dbpos = self.dbpos;
    } else if (self.objectId == DEVICE_OBJECTID_MEIDA_INFO) {
        P3K_Check_Read_MediaList_CMD * cmda = (P3K_Check_Read_MediaList_CMD*)&cmd;
        cmda->dbid = self.dbId;
        cmda->dbpos = self.dbpos;
        cmda->offset = self.eventType;
    } else if (self.objectId == DEVICE_OBJECTID_PLAYLIST) {
        P3K_Check_Read_MediaList_CMD * cmda = (P3K_Check_Read_MediaList_CMD*)&cmd;
        cmda->dbid = self.dbId;
        cmda->dbpos = self.dbpos;
    } else if (self.objectId == DEVICE_OBJECTID_CONTROL) {
    
        cmd.offset = self.eventType;
        if (self.eventType == CONTROL_OFFSET_RT_INFO_ALL) {
            P3K_FirmWare_CMD * cmda = (P3K_FirmWare_CMD*)&cmd;
            cmda->magic = self.lon;   //经度
            cmda->version = self.lat; //纬度
        }
        
    } else if (self.objectId == DEVICE_OBJECTID_SETUP) {
        
        cmd.offset = self.eventType;
    } else if (self.objectId == DEVICE_OBJECTID_PLAYLIST_NAMELIST) {
        P3K_Check_Read_MediaList_CMD * cmda = (P3K_Check_Read_MediaList_CMD*)&cmd;
        cmda->dbid = self.dbId;
        cmda->dbpos = self.dbpos;
    }
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Read_CMD)];
    
    {
    
        if (self.objectId == DEVICE_OBJECTID_TOTAL_FOLDER_LIST) {
            
            NSLog(@"DEVICE_OBJECTID_TOTAL_FOLDER_LIST : %@",cmdData);
            
        } else if (self.objectId == DEVICE_OBJECTID_MEIDA_INFO) {
            NSLog(@"DEVICE_OBJECTID_MEIDA_INFO : %@",cmdData);
        } else if (self.objectId == DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER) {
            NSLog(@"DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER : %@",cmdData);
        }
        
        
    }
    
    [self sendData:cmdData withResponse:NO];
    self.startTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
}

- (void)didWriteValueWithError:(NSError *)error {
    
    
}

- (void)didReadValue:(NSData *)data error:(NSError *)error {
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
            IFMDevice *device = [IFMDevice new];
            [device fillDeviceStateWithData:data];
            self.device = device;
            if (device.objectID == self.objectId) {
                NSLog(@"是读1M测试命令");
                if (device.lastCMDType == P3K_CMD_READ) {
                    NSLog(@"开始接受数据");
                }
                else if (device.lastCMDType == P3K_CMD_DATA) {
                    NSLog(@"读取完成");
                    if (device.objectID == DEVICE_OBJECTID_FIRMWARE) {
                        
                        P3K_FirmWare_Ctrl *firmWare = (P3K_FirmWare_Ctrl* )[self.rawData bytes];
                        
                        NSLog(@"");
                    }
                    [self successCallback];
                }
            }
            else {
                
                if ((self.currentTimeInterval - self.startTimeInterval) > 200) {
                    
                    if (self.firstCheckFailed == NO) {
                        self.firstCheckFailed = YES;
                        
                        [self.breakManager execute];
                        
                    }
                    else {
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = @"不是读1M测试命令";
                        [self failCallback];
                    }
                }
            }
        }
        else if (btype == P3K_CMD_DATA) {

            P3K_Data dataPacket;
            memset(&dataPacket, 0, sizeof(P3K_Data));
            // 会有脏数据
//            memcpy(&dataPacket, [data bytes], sizeof(P3K_Data));
            memcpy(&dataPacket, [data bytes], [data length]);
            UInt8 packetNumber = dataPacket.bno;
            NSLog(@"<----- 读取到数据：%d - %d", self.currentPacketNumber, packetNumber);
            if ((UInt8)self.currentPacketNumber == packetNumber) { // 正常，写入缓存
                self.currentPacketNumber += 1;
                [self.rawData appendBytes:&dataPacket.data length:sizeof(dataPacket.data)];
//                [self.rawData appendBytes:&dataPacket.data length:sizeof(BLE_MAX_DATA_SIZE)];
            }
            else { // 丢包，从下一个包重新读取
                [self sendReadCMD];
            }
        }
    }
}

- (void)clear {
    self.length = 0;
    self.lat = 0;
    self.lon = 0;
    self.totalBytesNeedRead = 0;
    self.totalPacketCount = 0;
    self.currentPacketNumber = 0;
    self.currentPacketNumber = 0;
    self.param = 0;
    self.eventType = 0;
    self.dbId = 0;
    self.dbpos = 0;
    self.errorType = 0;
    self.errorReason = nil;
    self.firstCheckFailed = NO;
    self.breakManager = nil;
    self.startTimeInterval = 0.0;
    self.currentTimeInterval = 0.0;
}

#pragma mark - IFMBLEManagerCallbackDelegate

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    [self openNotify];
    [self.rawData setLength:0];
    [self sendReadCMD];
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    self.errorType = IFMBLEManagerErrorTypeIncorrectData;
    self.errorReason = @"不是读1M测试命令";
    [self failCallback];
}

#pragma mark - getter & setter methods

- (IFMBLEBreakManager*)breakManager {
    if (!_breakManager) {
        _breakManager = [[IFMBLEBreakManager alloc] init];
        _breakManager.delegate = self;
    }
    return _breakManager;
}


@end
