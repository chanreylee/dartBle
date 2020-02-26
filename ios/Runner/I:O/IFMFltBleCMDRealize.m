//
//  IFMFltBleCMDRealize.m
//  Runner
//
//  Created by 王泽 on 2020/1/7.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import "IFMFltBleCMDRealize.h"
#import "IFMBLEManager.h"
#import "IFMBLEAuthorizeManager.h"
#import "IFMBLEBindManager.h"
#import "IFMBLEUnbindManager.h"
#import "IFMBLEAuthorizeManager.h"
#import "IFMBLEDeviceStateManager.h"
#import "IFMBLECheckManager.h"
#import "IFMBLEWriteManager.h"
#import "IFMBLEReadManager.h"
#import "IFMRealTimeControlManager.h"
#import "IFMBLEBreakManager.h"


#import "IFMDeviceStateReformer.h"


@interface IFMFltBleCMDRealize ()<IFMBLEManagerCallbackDelegate>

@property (nonatomic, copy)   FlutterResult     connectPeripheralResult;

@property (nonatomic, strong)   IFMBLEAuthorizeManager      *authorizeManager;
@property (nonatomic, strong)   IFMBLEBindManager           *bindManager;
@property (nonatomic, strong)   IFMBLEUnbindManager         *unBindManager;

@property (nonatomic, strong)   IFMBLEDeviceStateManager    *deviceStateManager;

@property (nonatomic, strong)   IFMBLECheckManager          *checkManager;
@property (nonatomic, strong)   IFMBLEWriteManager          *writeManager;
@property (nonatomic, strong)   IFMBLEReadManager           *readManager;
@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlManager;
@property (nonatomic, strong)   IFMBLEBreakManager          *breakManager;

@end

@implementation IFMFltBleCMDRealize

- (void)executeCheckWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    
    xU8 btype = 0;
    btype = [dic[@"btype"] unsignedIntValue];
    
    switch (btype) {
        case P3K_CMD_CHECK:
        {
            [self checkCMDWithDic:dic result:result];
        }
        break;
            
        case P3K_CMD_STATES:
        {
            [self deviceStatesCMDWithResult:result];
        }
        break;
        case P3K_CMD_WRITE:
        {
            [self writeCMDWithDic:dic result:result];
        }
        break;
            
        case P3K_CMD_READ:
        {
            [self readCMDWithDic:dic result:result];
        }
        break;
        
        case P3K_CMD_BREAK:
        {
            IFMBLEBreakManager *breakManager = [[IFMBLEBreakManager alloc] init];
            breakManager.delegate = self;
            breakManager.flutterResult = result;
            [breakManager execute];
        }
        break;
        
        default:
        {
            result(@"命令不支持");
        }
            break;
    }
}



- (void)deviceStatesCMDWithResult:(FlutterResult)result {
    IFMBLEDeviceStateManager *deviceStateManager = [[IFMBLEDeviceStateManager alloc] init];
    self.deviceStateManager = deviceStateManager;
    deviceStateManager.delegate = self;
    deviceStateManager.flutterResult = result;
    [deviceStateManager execute];
}

- (void)authorizeCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    IFMBLEAuthorizeManager *authorizeManager = [[IFMBLEAuthorizeManager alloc] init];
    self.authorizeManager = authorizeManager;
    authorizeManager.delegate = self;
    authorizeManager.flutterResult = result;
    FlutterStandardTypedData *fltData = dic[@"data"];
    
    NSData *data = fltData.data;
    char ch[17];
    memset(ch, 0, 16);
    NSData *cmdData = [NSData dataWithBytes:ch length:16];
    if ([cmdData isEqualToData:data]) {
        NSLog(@"");
    }
    [authorizeManager setupData:cmdData];
    [authorizeManager execute];
}

- (void)bindCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    IFMBLEBindManager *bindManager = [[IFMBLEBindManager alloc] init];
    self.bindManager = bindManager;
    bindManager.delegate = self;
    bindManager.flutterResult = result;
    NSString *key = dic[@"idKey"];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    [bindManager setupData:keyData];
    [bindManager setNeedAuthorize:NO];
    [bindManager execute];
}

- (void)unBindCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    IFMBLEUnbindManager *unBindManager = [[IFMBLEUnbindManager alloc] init];
    self.unBindManager = unBindManager;
    unBindManager.delegate = self;
    unBindManager.flutterResult = result;
    [unBindManager setNeedAuthorize:NO];
    [unBindManager execute];
}

- (void)checkCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    IFMBLECheckManager *checkManager = [[IFMBLECheckManager alloc] init];
    self.checkManager = checkManager;
    checkManager.delegate = self;
    checkManager.flutterResult = result;
    if (dic[@"objectId"]) {
        [checkManager setupObjectId:[dic[@"objectId"] intValue]];
        [checkManager setupEventType:[dic[@"offset"] intValue]];
        [checkManager setupParam:[dic[@"param"] intValue]];
        [checkManager setupDbId:[dic[@"dbid"] intValue] Dbpos:[dic[@"dbpos"] intValue]];
        [checkManager execute];
    } else {
        result(@"未填写objectId");
    }
}

- (void)writeCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    int objectId = [dic[@"objectId"] intValue];
    
//    - (xU16)objectId {
//        return DEVICE_OBJECTID_AUTHORIZE;
//    }
//
//    - (xU32)eventType {
//        return AUTHORIZE_OFFSET_BIND;
//    }
    if (objectId == DEVICE_OBJECTID_AUTHORIZE) {
        if ([dic[@"offset"] intValue] == AUTHORIZE_OFFSET_AUTH) {
            [self authorizeCMDWithDic:dic result:result];
        } else if ([dic[@"offset"] intValue] == AUTHORIZE_OFFSET_BIND) {
            [self bindCMDWithDic:dic result:result];
        }
    } else if (objectId == DEVICE_OBJECTID_CONTROL ||
               objectId == DEVICE_OBJECTID_FOLDER_AND_MEDIA_KEY ||
               objectId == DEVICE_OBJECTID_FIRMWARE_CHECK_AND_UPDATA) {
        [self realTimeControlCMDWithDic:dic result:result];
        
    } else {
        
        IFMBLEWriteManager *writeManager = [[IFMBLEWriteManager alloc] init];
        self.writeManager = writeManager;
        writeManager.delegate = self;
        writeManager.flutterResult = result;
        if (dic[@"objectId"]) {
            if (objectId == DEVICE_OBJECTID_PLAYLIST_NAMELIST) {
                NSLog(@"");
            }
            [writeManager setupObjectId:[dic[@"objectId"] intValue]];
            [writeManager setupOffset:[dic[@"offset"] intValue]];
            FlutterStandardTypedData *fltData = dic[@"data"];
            NSData *data = fltData.data;

            [writeManager setupData:data];
            [writeManager execute];
        } else {
            result(@"未填写objectId");
        }
    }
}

- (void)readCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    IFMBLEReadManager *readManager = [[IFMBLEReadManager alloc] init];
    self.readManager = readManager;
    readManager.delegate = self;
    readManager.flutterResult = result;
    if (dic[@"objectId"]) {
        if (CONTROL_OFFSET_RT_INFO_ALL == [dic[@"offset"] intValue]) {
            NSLog(@"");
        }
        [readManager setupObjectId:[dic[@"objectId"] intValue]];
        [readManager setupLength:[dic[@"length"] intValue]];
        [readManager setupEventType:[dic[@"offset"] intValue]];
        [readManager setupParam:[dic[@"param"] intValue]];
        [readManager setupDbId:[dic[@"dbid"] intValue] Dbpos:[dic[@"dbpos"] intValue]];
        [readManager execute];
    } else {
        result(@"未填写objectId");
    }
}

- (void)realTimeControlCMDWithDic:(NSDictionary *)dic result:(FlutterResult)result {
    IFMRealTimeControlManager *realTimeControlManager = [[IFMRealTimeControlManager alloc] init];
    self.realTimeControlManager = realTimeControlManager;
    realTimeControlManager.delegate = self;
    realTimeControlManager.flutterResult = result;
    if (dic[@"objectId"]) {
        [realTimeControlManager setupObjectId:[dic[@"objectId"] intValue]];
        [realTimeControlManager setupLength:[dic[@"length"] intValue]];
        [realTimeControlManager setupEventType:[dic[@"offset"] intValue]];
        FlutterStandardTypedData *fltData = dic[@"data"];
        NSData *data = fltData.data;
        [realTimeControlManager setupData:data];
        [realTimeControlManager execute];
    } else {
        result(@"未填写objectId");
    }
}



#pragma mark - IFMBLEManagerCallbackDelegate

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    NSMutableDictionary *resultDic = @{}.mutableCopy;
//    {
//      err:{
//        errorType:<Uint32>,
//        errorReason:<String>
//      },
//      responseObject:{
//        data:<ByteData>
//        deviceState:<ByteData>
//      }
//    }
    FlutterStandardTypedData *rawData = [FlutterStandardTypedData typedDataWithBytes:manager.rawData];
    manager.flutterResult(@{@"data":rawData,@"success":@(YES)});
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    manager.flutterResult(@{@"errorType":@(manager.errorType),@"errorReason":manager.errorReason,@"success":@(NO)});
    [SVProgressHUD showErrorWithStatus:@"返回错误"];
}

@end
