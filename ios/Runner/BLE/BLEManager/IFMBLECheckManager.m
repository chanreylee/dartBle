//
//  IFMBLECheckManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLECheckManager.h"
#import "IFMDevice.h"
#import "IFMBLEBreakManager.h"

@interface IFMBLECheckManager () <IFMBLEManagerCallbackDelegate>
@property (nonatomic, assign)   xU16    objectId;
@property (nonatomic, assign)   xU16    mode;
@property (nonatomic, assign)   xU16    param;
@property (nonatomic, assign)   xU32    eventType;
@property (nonatomic, assign)   xU32    dbId;
@property (nonatomic, assign)   xU16    dbpos;

@property (nonatomic, assign) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong) NSString                *errorReason;

@property (nonatomic, assign)   BOOL                firstCheckFailed;

@property (nonatomic, strong)   IFMBLEBreakManager  *breakManager;

@property (nonatomic, assign)   double      startTimeInterval;
@property (nonatomic, assign)   double      currentTimeInterval;
@end

@implementation IFMBLECheckManager
@synthesize errorType;
@synthesize errorReason;

- (void)setupObjectId:(xU16)objectId {
    self.objectId = objectId;
    [self clear];
}

- (void)setupMode:(xU16)mode {
    self.mode = mode;
}

- (void)setupEventType:(xU32)eventType {
    
    self.eventType = eventType;
}

- (void)setupParam:(xU16)param {
    self.param = param;
}

- (void)start {
    [self sendCMD];
}

- (void)setupDbId:(xU32)dbId Dbpos:(xU16)dbpos {

    self.dbId = dbId;
    self.dbpos = dbpos;
}

- (void)sendCMD {
    P3K_Write_CMD cmd;
    P3K_CheckStatic_CMD *pCmd = (P3K_CheckStatic_CMD*)&cmd;
    memset(&cmd, 0, sizeof(P3K_Write_CMD));
    cmd.btype = P3K_CMD_CHECK;
    cmd.bno = 0;
    cmd.objID = self.objectId;
    cmd.offset = 0;
    cmd.len = 0;
    
    pCmd->mode = self.mode;
    pCmd->param = self.param;
    
    if (self.objectId == DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER) {
//        xU8 btype;    /* P3K_CMD_WRITE */
//        xU8 bno;    /* 0 */
//        xU16 objID;
//        xU32 offset;
//        xU32 len;                    /* object length */
//        xU32 dbid;
//        xU16 dbpos;
//        xU8 ex[BLE_MAX_MTU_SIZE-18];
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
            P3K_Check_Read_MediaList_CMD * cmda = (P3K_Check_Read_MediaList_CMD*)&cmd;
            cmda->dbid = self.dbId;
        }
    }  else if (self.objectId == DEVICE_OBJECTID_SETUP) {
        
        cmd.offset = self.eventType;
    } else if (self.objectId == DEVICE_OBJECTID_PLAYLIST_NAMELIST) {
        
//        xU8 btype;    /* P3K_CMD_WRITE */
//        xU8 bno;    /* 0 */
//        xU16 objID;
//        xU32 offset;
//        xU32 len;                    /* object length */
//        xU32 dbid;
//        xU16 dbpos;
//        xU8 ex[BLE_MAX_MTU_SIZE-18];
        
        P3K_Check_Read_MediaList_CMD * cmda = (P3K_Check_Read_MediaList_CMD*)&cmd;
        cmda->dbid = self.dbId;
        cmda->dbpos = self.dbpos;
    }

    NSData *cmdData = [NSData dataWithBytes:&cmd length:sizeof(P3K_Write_CMD)];
    
        {
            
            if (self.objectId == DEVICE_OBJECTID_MEIDA_INFO) {
                
                NSLog(@"DEVICE_OBJECTID_MEIDA_INFO : %@",cmdData);
            } else if (self.objectId == DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER) {
                
                NSLog(@"DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER : %@",cmdData);
            } else if (self.objectId == DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER) {
                
                NSLog(@"DEVICE_OBJECTID_MEIDA_LIST_IN_FOLDER : %@",cmdData);
            } else if (self.objectId == DEVICE_OBJECTID_STATICS) {
            
                 NSLog(@"DEVICE_OBJECTID_STATICS : %@",cmdData);
            }
            
            
        }

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
        
        P3K_States p;
        
        memcpy(&btype, pData, sizeof(UInt8));
        
        memcpy(&p , pData , sizeof(P3K_States));
        
        IFMDevice *device = [[IFMDevice alloc] init];
        [device fillDeviceStateWithData:data];
        self.device = device;
        if (btype == P3K_CMD_CHECK) {
            [self.rawData setLength:0];
            [self.rawData appendData:data];
            [self successCallback];
        }
        else {
            
            if ((self.currentTimeInterval - self.startTimeInterval) > 200) {
                
                if (self.firstCheckFailed == NO) {
                    self.firstCheckFailed = YES;

                    [self.breakManager execute];
                    
                }
                else {
                    self.errorType = IFMBLEManagerErrorTypeIncorrectData;
                    self.errorReason = @"没有收到Check的响应";
                    [self failCallback];
                }
            }
        }
    }
}

- (void)clear {
    self.mode = 0;
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
    [self sendCMD];
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    self.errorType = IFMBLEManagerErrorTypeIncorrectData;
    self.errorReason = @"没有收到Check的响应";
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
