//
//  IFMBLEWriteManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEWriteManager.h"
#import "IFMDevice.h"
#import "IFMBLEBreakManager.h"

NSInteger const IFMBLEWriteManager_Read_State_Interval = 24;//24;

@interface IFMBLEWriteManager ()<IFMBLEManagerCallbackDelegate>
@property (nonatomic, assign)   xU16        objectId;
@property (nonatomic, strong)   NSData      *data;
@property (nonatomic, assign)   int32_t     totalBytes;
@property (nonatomic, assign)   int32_t     totalPacketCount;
@property (nonatomic, assign)   int32_t     currentPacketNumber;
@property (nonatomic, assign)   int32_t     offset;

@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;

@property (nonatomic, assign)   BOOL        firstWriteFailed;
@property (nonatomic, assign)   double      startTimeInterval;
@property (nonatomic, assign)   double      currentTimeInterval;
@property (nonatomic, strong)   IFMBLEBreakManager      *breakManager;

@property (nonatomic, assign)   BOOL        isFIRMWARE;

@end

@implementation IFMBLEWriteManager
@synthesize errorType;
@synthesize errorReason;

- (void)setupObjectId:(xU16)objectId {
    self.objectId = objectId;
    [self clear];
}

- (void)setupData:(NSData *)data {
    self.data = [data copy];
    
    self.totalBytes = (UInt32)[data length];
    self.totalPacketCount = (self.totalBytes - P3K_CMD_EXPARAM_SIZE) / BLE_MAX_DATA_SIZE;
    if ((self.totalBytes - P3K_CMD_EXPARAM_SIZE) % BLE_MAX_DATA_SIZE > 0) {
        self.totalPacketCount += 1;
    }
    self.currentPacketNumber = 0;
    self.offset = 0;
    
    NSLog(@"total:%d", self.totalBytes);
}

- (void)setupOffset:(xU32)offset {

    self.offset = offset;
    [self resetPacketNumber];
}

- (void)resetPacketNumber {
    self.totalPacketCount = (self.totalBytes - self.offset - P3K_CMD_EXPARAM_SIZE) / BLE_MAX_DATA_SIZE;
    if ((self.totalBytes - self.offset - P3K_CMD_EXPARAM_SIZE) % BLE_MAX_DATA_SIZE > 0) {
        self.totalPacketCount += 1;
    }
    self.currentPacketNumber = 0;
}

- (void)start {
    [self sendWriteCMD];
}

- (void)sendWriteCMD {
    P3K_Write_CMD cmd;
    memset(&cmd, 0, sizeof(P3K_Write_CMD));
    cmd.btype = P3K_CMD_WRITE;
    cmd.bno = 0;
    cmd.objID = self.objectId;
    
    cmd.offset = self.offset;
    cmd.len = self.totalBytes;
    
    const void * pData = [self.data bytes];
    pData += self.offset;
    
    memcpy(&cmd.ex, pData, sizeof(UInt8) * P3K_CMD_EXPARAM_SIZE);
    
    const void * temp = pData;
    int32_t a = *((int32_t*)temp);
    temp += sizeof(int32_t);
    int32_t b = *((int32_t*)temp);
    
    NSLog(@"----> write %d %d", a, b);
    
//    memcpy(&cmd.ex, [self.data bytes], sizeof(UInt8) * P3K_CMD_EXPARAM_SIZE);
    
    self.offset += P3K_CMD_EXPARAM_SIZE;
    
    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    
    {
        if (self.objectId == DEVICE_OBJECTID_PLAYLIST_NAMELIST) {
            
            NSLog(@"DEVICE_OBJECTID_PLAYLIST_NAMELIST : %@",cmdData);
        }

    }
    
    [self sendData:cmdData withResponse:NO];
    self.startTimeInterval = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    if (cmd.objID == DEVICE_OBJECTID_FIRMWARE) {
        self.isFIRMWARE = YES;
    }
}

- (void)sendDataPacket:(BOOL)needResponse {
    P3K_Data dataPacket;
    memset(&dataPacket, 0, sizeof(P3K_Data));
    dataPacket.btype = P3K_CMD_DATA;
    dataPacket.bno = self.currentPacketNumber;
    
    
    uint32_t bytesNeedSend = BLE_MAX_DATA_SIZE;
    
    // 最后一个数据包
    if (self.currentPacketNumber == (self.totalPacketCount - 1)) {
        bytesNeedSend = self.totalBytes - self.offset;
    }
    
    const void * pData = [self.data bytes];
    pData += self.offset;
    
    memcpy(&dataPacket.data, pData, sizeof(UInt8) * bytesNeedSend);
    self.offset += bytesNeedSend;
    
    int32_t temp = *((int32_t*)pData);
    
    NSData *cmdData = [NSData dataWithBytes:&dataPacket length:sizeof(P3K_Data)];
    
    {
        if (self.objectId == DEVICE_OBJECTID_PLAYLIST_NAMELIST) {

            NSLog(@"DEVICE_OBJECTID_PLAYLIST_NAMELIST : %@",cmdData);
        }
        
    }
    
    [self sendData:cmdData withResponse:needResponse];
    
    NSLog(@"-----> 发包:%d bytes %d -- %d --offset:%d needResponse:%@ number:%d", bytesNeedSend, self.currentPacketNumber, (UInt8)self.currentPacketNumber, self.offset, needResponse? @"YES":@"NO", temp);
    
}

- (void)sendBatchDataPacket {
    if (self.currentPacketNumber >= self.totalPacketCount - 1) {
        self.currentPacketNumber = self.totalPacketCount - 1;
    }
    
    int32_t fromPacketIndex = self.currentPacketNumber;
    int32_t toPacketIndex = self.currentPacketNumber + IFMBLEWriteManager_Read_State_Interval;
    if (toPacketIndex >= self.totalPacketCount - 1) {
        toPacketIndex = self.totalPacketCount - 1;
    }
    
    for (int32_t i = fromPacketIndex; i <= toPacketIndex; i++) {
        self.currentPacketNumber = i;
        [self sendDataPacket:(i == toPacketIndex)];
    }
}

- (void)didWriteValueWithError:(NSError *)error {
    if (error) {
        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
        self.errorReason = [NSString stringWithFormat:@"写入数据失败:%@", [error localizedDescription]];
        [self failCallback];
    }
    else {
        if (self.currentPacketNumber > 0 && self.currentPacketNumber < self.totalPacketCount - 1) {
            self.currentPacketNumber += 1;
            
            if (self.isFIRMWARE) {
                [SVProgressHUD showProgress:(self.offset / 1.0)/self.totalBytes status:[NSString stringWithFormat:@"%@%.1f%%",@"正在给Pico传输固件：",(self.offset / 1.0)/self.totalBytes*100.0]];
            }
            
            if (self.objectId == DEVICE_OBJECTID_BACKGROUND_FIRMWARE) {
                
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    
                    return;
                }
            }
            
            [self sendBatchDataPacket];
        }
    }
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
            
            if (device.objectID == self.objectId) {
                NSLog(@"是写1M测试命令");
                if (device.lastCMDType == P3K_CMD_WRITE) {
                    
                    [self sendBatchDataPacket];
                    
                }
                else if (device.lastCMDType == P3K_CMD_DATA) {
                    NSLog(@"<----- 收到Response packetNumber:%d offset:%d", self.currentPacketNumber, self.offset);
                    if (device.lastCMDResult == RET_CODE_WDATA_PKTNO_ERR) { // 包编号错
                        UInt8 packetNumber = device.packetNumber;
                        NSLog(@"<----- 接包:%d", packetNumber);
                        UInt8 cutNum = (UInt8)self.currentPacketNumber;
                        
                        if (packetNumber != cutNum) {
                            NSLog(@"发现丢包，需要重传");
//                            CGFloat dshadhsahdsa =  [[[NSUserDefaults standardUserDefaults] valueForKey:@"丢包次数"] doubleValue];
//                            dshadhsahdsa += 1;
//                            [[NSUserDefaults standardUserDefaults] setFloat:dshadhsahdsa forKey:@"丢包次数"];
                            
                            if (cutNum < packetNumber) {
                                cutNum += UINT8_MAX;
                            }
                            
                            int32_t count = cutNum - packetNumber;
                            self.offset -= count * BLE_MAX_DATA_SIZE;
                            
                            [self resetPacketNumber];
                            [self sendWriteCMD];
                        }
                    }
                    else if (device.lastCMDResult == RET_CODE_DATA_TRANS_OK) {
                        NSLog(@"%@", device.lastCMDResultString);
                        NSLog(@"传输完成");
                        [self.rawData setLength:0];
                        [self.rawData appendData:data];
                        [self successCallback];
                    }
                    else if (device.lastCMDResult == RET_CODE_IS_WRITING) {
                        NSLog(@"RET_CODE_IS_WRITING");
                    }
                    else {
                        NSLog(@"传输失败，请检查log");
                        
                        [self failCallback];
                    }
                }
            }
            else {
                
                if ((self.currentTimeInterval - self.startTimeInterval) > 300) {
                    
                    if (self.firstWriteFailed == NO) {
                        self.firstWriteFailed = YES;
                        [self.breakManager execute];
                        
                    }
                    else {
                        NSLog(@"不是写1M测试命令");
                        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                        self.errorReason = [NSString stringWithFormat:@"收到的数据不是%d的响应", self.objectId];
                        [self failCallback];

                    }
                }
            }
        }
    }
}

- (void)clear {
    
    self.data = nil;
    self.totalBytes = 0;
    self.totalPacketCount = 0;
    self.currentPacketNumber = 0;
    self.offset = 0;
    self.firstWriteFailed = NO;
    self.isFIRMWARE = NO;
    self.errorType = 0;
    self.errorReason = nil;
    self.breakManager = nil;
    self.startTimeInterval = 0.0;
    self.currentTimeInterval = 0.0;
}

#pragma mark - IFMBLEManagerCallbackDelegate

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    [self openNotify];
    [self start];
    
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    if (manager == self.breakManager){
        self.errorType = IFMBLEManagerErrorTypeIncorrectData;
        self.errorReason = @"写入失败";
        [self failCallback];
    }
}

- (IFMBLEBreakManager*)breakManager {
    if (!_breakManager) {
        _breakManager = [[IFMBLEBreakManager alloc] init];
        _breakManager.delegate = self;
    }
    
    return _breakManager;
}

@end
