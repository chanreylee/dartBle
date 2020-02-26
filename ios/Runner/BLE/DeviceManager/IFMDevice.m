//
//  IFMDevice.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMDevice.h"
#import "p3kbleproto.h"
#import "IFMDeviceManager.h"

@interface IFMDevice ()
@property (nonatomic, assign)   P3K_States *pStates;
@end

@implementation IFMDevice

#pragma mark - life cycle methods

- (void)dealloc {
    free(self.pStates);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pStates = malloc(sizeof(P3K_States));
    }
    
    return self;
}


#pragma mark - public methods

- (void)fillDeviceStateWithData:(NSData *)data {
    memset(self.pStates, 0, sizeof(P3K_States));
    memcpy(self.pStates, [data bytes], sizeof(P3K_States));
    
    NSLog(@"%@", self.lastCMDResultString);
}

#pragma mark - getter & setter

//- (NSString*)deviceName {
//    if ([IFMBLEManager sharedInstance].connectedPeripheral == nil) {
//        return @"";
//    }
//    
//    if ([[IFMBLEManager sharedInstance].connectedPeripheral.name length] == 0) {
//        return @"未知设备";
//    }
//    
//    return [IFMBLEManager sharedInstance].connectedPeripheral.name;
//}
//
//- (NSString*)protocolVersion {
//    NSString *name = [IFMBLEManager sharedInstance].connectedPeripheral.name;
//    
//    if ([IFMBLEManager sharedInstance].connectedPeripheral == nil || [name length] < 3) {
//        return @"";
//    }
//    
//    return [name substringWithRange:NSMakeRange(name.length - 3, 2)];
//}

- (BOOL)hasStatics {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_STATICS;
    }
    
    return ret;
}

- (BOOL)isTransmiting {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_TRANSMITING;
    }
    
    return ret;
}

- (BOOL)isCharging {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_CHARGING;
    }
    
    return ret;
}

- (BOOL)isRunning {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_RUNNING;
    }
    return ret;
}

- (BOOL)isWritting {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_WRITTING;
    }
    
    return ret;
}

- (BOOL)isBind {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_BIND;
    }
    
    return ret;
}

- (BOOL)isAuthorized {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_AUTHORIZED;
    }
    
    return ret;
}

- (BOOL)isRealTimeControl {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_RT_PROCESS;
    }
    return ret;
}

- (BOOL)isUsbConnection {
    BOOL ret = NO;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->devstate & DEVICE_STATE_USB_CONNETING;
    }
    return ret;
}


- (UInt8)battery {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->battery;
    }
    
    return ret;
}

- (UInt8)operationPercent {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->oppercent;
    }
    
    return ret;
}

- (UInt8)hardwareVersion {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->hwver;
    }
    
    return ret;
}

- (UInt8)firmwareVersion {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->fwver;
    }
    
    return ret;
}

- (UInt8)gpsVersion {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->gpsver;
    }
    
    return ret;
}

- (UInt8)bleVersion {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->blever;
    }
    
    return ret;
}

- (UInt8)lastCMDType {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->otype;
    }
    
    return ret;
}

- (UInt8)packetNumber {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->ono;
    }
    
    return ret;
}

- (UInt16)objectID {
    UInt16 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->oobjID;
    }
    
    return ret;
}

- (UInt8)lastCMDResult {
    UInt8 ret = 0;
    if (self.pStates->btype == P3K_CMD_STATES) {
        ret = self.pStates->bno;
    }
    
    return ret;
}

////IFM_States中bno返回ret code，表示dev检测到的错误状态
//#define	RET_CODE_NORMAL					0
//#define	RET_CODE_DATA_OFFSET_ERR		1		//读或写的frameoff有错误
//#define	RET_CODE_DATA_LEN_ERR			2		//读或写的len有错误
//#define	RET_CODE_DATA_TRANS_OK			3		//cmdWrite时dev通过收到的数据长度判断已经传输完毕, cmdRead时dev发送完毕
//#define	RET_CODE_WDATA_ERR				4		//Dev检查出收到的数据有错误
//#define	RET_CODE_WDATA_PKTNO_ERR		5		//包编号错
//#define	RET_CODE_NO_AUTHORIZED			6		//未验证时，收到验证命令以外的其它命令
//#define	RET_CODE_IS_WRITING				7		//处在writing状态时收到新的COMW

- (NSString*)lastCMDResultString {
    UInt8 lastCMDResult = self.lastCMDResult;
    NSString *string = nil;
    
    switch (lastCMDResult) {
        case RET_CODE_NORMAL:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作成功", self.lastCMDType];
        }
            break;
        case RET_CODE_DATA_OFFSET_ERR:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 读或写的frameoff有错误", self.lastCMDType];
        }
            break;
        case RET_CODE_DATA_LEN_ERR:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 读或写的len有错误", self.lastCMDType];
        }
            break;
        case RET_CODE_DATA_TRANS_OK:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作成功 cmdWrite时dev通过收到的数据长度判断已经传输完毕, cmdRead时dev发送完毕", self.lastCMDType];
        }
            break;
        case RET_CODE_WDATA_ERR:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 Dev检查出收到的数据有错误", self.lastCMDType];
        }
            break;
        case RET_CODE_WDATA_PKTNO_ERR:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 包编号错", self.lastCMDType];
        }
            break;
        case RET_CODE_NO_AUTHORIZED:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 未验证时，收到验证命令以外的其它命令", self.lastCMDType];
            [SVProgressHUD dismiss];
        }
            break;
        case RET_CODE_IS_WRITING:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 处在writing状态时收到新的COMW", self.lastCMDType];
        }
            break;
        case RET_CODE_PARAM_ERR:
        {
            string = [NSString stringWithFormat:@"命令:%d 操作失败 收到的参数有错误", self.lastCMDType];
        }
            break;
        case RET_CODE_DISK_ERR:
        {
            string = [NSString stringWithFormat:@"命令:%d 磁盘出现错误，生成alp文件失败", self.lastCMDType];
        }
            break;
        default:
            break;
    }
    
    return string;
}

@end
