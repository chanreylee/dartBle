//
//  IFMBleIOManager.m
//  Runner
//
//  Created by 王泽 on 2019/12/18.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "IFMBleIOManager.h"

#import "IFMDeviceManager.h"
#import "CBPeripheral+IFMProperties.h"

#import "IFMBLEAuthorizeManager.h"
#import "IFMBLEBindManager.h"
#import "IFMBLEDeviceStateManager.h"
#import "IFMDeviceStateReformer.h"
#import "IFMBLEWriteManager.h"
#import "IFMBLEReadManager.h"
#import "IFMBLECheckManager.h"
#import "IFMCheckCMDReformer.h"
#import "IFMSetupDataReformer.h"
#import "IFMHeartbeatPacket.h"
#import "IFMUtils.h"

#import "IFMSendFLTMessage.h"
#import "MZYModelHelper.h"

@interface IFMBleIOManager () <IFMDeviceManagerDelegate, IFMBLEManagerCallbackDelegate>
@property (nonatomic, strong)   NSMutableArray              *deviceArray;
@property (nonatomic, strong)   CBPeripheral                *selectedPeripheral;

@property (nonatomic, strong)   IFMBLEAuthorizeManager      *authorizeManager;
@property (nonatomic, strong)   IFMBLEBindManager           *bindManager;
@property (nonatomic, strong)   IFMBLEDeviceStateManager    *deviceStateManager;
@property (nonatomic, strong)   IFMCheckCMDReformer         *checkCMDReformer;
@property (nonatomic, strong)   IFMSetupDataReformer        *setupDataReformer;
@property (nonatomic, strong)   IFMBLECheckManager          *checkSetupkManager;
@property (nonatomic, strong)   IFMBLEReadManager           *readSetupManager;

@property (nonatomic, assign)   NSInteger                   directoryCount;

@property (nonatomic, copy)     VoidBlock                   dismissBlock;


@property (nonatomic, strong)   NSTimer                     *timer;
@property (nonatomic, assign)   BOOL                        isAutoConnect;
@property (nonatomic, strong)   IFMSendFLTMessage           *scanPeripheral;

@end

@implementation IFMBleIOManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
        [self configDatas];
        
    }
    return self;
}

- (void)initialize {

    [IFMDeviceManager sharedInstance].delegate = self;
}


- (void)configDatas {


}


#pragma mark - ui events

- (void)beginAutoConnection {
    
    self.isAutoConnect = YES;
    if (![IFMDeviceManager sharedInstance].delegate) {
        [IFMDeviceManager sharedInstance].delegate = self;
        @weakify(self);
        [[IFMDeviceManager sharedInstance] startScanningForServiceUUIDs:nil isAutoConnect:YES];
    } else {
        [[IFMDeviceManager sharedInstance] startScanningForServiceUUIDs:nil isAutoConnect:YES];
        
    }
}

- (void)startConnectButton:(id)sender {
    
    [SVProgressHUD showWithStatus:@"正在连接设备"];
    [[IFMDeviceManager sharedInstance] connectPeripheral:self.selectedPeripheral];
    
}

#pragma mark - private methods

- (void)saveDeviceModel {

    
    //初始化数据库~。
    
    NSString *selectedPeripheral_uuid = self.selectedPeripheral.identifier.UUIDString;
    NSString *selectedPeripheral_name = self.selectedPeripheral.name;
    
    [self.checkSetupkManager setupObjectId:DEVICE_OBJECTID_SETUP];
    [self.checkSetupkManager execute];
    
    [SVProgressHUD showWithStatus:@"正在加载设备信息..."];
    
    //        self.loadDataCenter = [[IFMLoadDataProcessCenter alloc] init];
    //        self.loadDataCenter.loadedEndBlock = self.dismissBlock;
    //        [self.loadDataCenter startLoadInfoProcess];
}

- (void)bingDeviceInfoSend {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    
    parameters[@"deviceId"] = self.selectedPeripheral.identifier.UUIDString;
    parameters[@"name"] = self.selectedPeripheral.name;
    parameters[@"deviceType"] = @(0);
    parameters[@"mode"] = self.setupDataReformer.devModel;
    parameters[@"serialNumber"] = self.setupDataReformer.serialNo;
    parameters[@"hardwareVersion"] = self.setupDataReformer.hardware;
    parameters[@"firmwareVersion"] = self.setupDataReformer.software;
    parameters[@"bleVersion"] = self.setupDataReformer.bleVersion;
    parameters[@"amount"] = @(self.setupDataReformer.diskCapacity_int);
    parameters[@"macId"] = self.setupDataReformer.macNo;
    
//    self.loadDataCenter = [[IFMLoadDataProcessCenter alloc] init];
//    self.loadDataCenter.loadedEndBlock = self.dismissBlock;
//    [self.loadDataCenter startLoadInfoProcess];
}


#pragma mark - IFMDeviceManagerDelegate

// 扫描到合适的peripheral
- (void)deviceManager:(IFMDeviceManager*)deviceManager didDiscoverPeripheral:(CBPeripheral*)peripheral {
    
    if (deviceManager.isAutoConnect) {
        
        self.selectedPeripheral = peripheral;
        NSString *UUID = self.selectedPeripheral.identifier.UUIDString;
        NSString *name = self.selectedPeripheral.name;
        NSDictionary *dict = @{@"name":name,@"macId":UUID};
        
        [self.scanPeripheral sendObjectMessage:dict channel:@"startScanning/BlePeripheral" callBack:^(id result) {
            if (result) {
//                NSDictionary *resultDic = result;
//                [SVProgressHUD showErrorWithStatus:[MZYModelHelper getJsonStringWith:resultDic]];
            }
        }];
            
    }
}

//连接成功
- (void)deviceManagerIsReady:(IFMDeviceManager*)deviceManager {
    [SVProgressHUD showSuccessWithStatus:IFMLocalizedString(@"连接设备成功", nil)];
    

}


- (void)deviceManager:(IFMDeviceManager*)deviceManager didConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"连接设备失败"];
    }
    else {
        
    }
}

- (void)deviceManager:(IFMDeviceManager*)deviceManager didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error {
}

- (void)deviceManager:(IFMDeviceManager*)deviceManager exceptionMessage:(NSString*)message {
    [SVProgressHUD showErrorWithStatus:message];
}



#pragma mark - IFMBLEManagerCallbackDelegate

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    if (manager == self.deviceStateManager) {
        IFMDeviceStateReformer *reformer = [IFMDeviceStateReformer new];
        IFMDevice *device = [manager fetchDataWithReformer:reformer];
        [SVProgressHUD showWithStatus:@"正在验证设备..."];
        
        if (device.isBind) {
            NSString *key = [IFMUtils deviceId];
            NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            [self.authorizeManager setupData:keyData];
            [self.authorizeManager execute];
        } else {
            char ch[17];
            memset(ch, 0, 16);
            NSData *cmdData = [NSData dataWithBytes:ch length:16];
            [self.authorizeManager setupData:cmdData];
            [self.authorizeManager execute];
        }
        
    } else if (manager == self.authorizeManager) {
        [SVProgressHUD showWithStatus:IFMLocalizedString(@"正在绑定设备...", nil)];
        
        if (manager.device.isBind) {
            [SVProgressHUD showSuccessWithStatus:IFMLocalizedString(@"绑定设备成功", nil)];
            [self.selectedPeripheral ifm_setIsBind:YES];
            //开始把设备信息存入数据库
            [self saveDeviceModel];

        } else {
            NSString *key = [IFMUtils deviceId];
            NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            [self.bindManager setupData:keyData];
            [self.bindManager setNeedAuthorize:NO];
            [self.bindManager execute];
        }
        
    } else if (manager == self.bindManager) {
        [SVProgressHUD showSuccessWithStatus:IFMLocalizedString(@"绑定设备成功", nil)];
        
        [self.selectedPeripheral ifm_setIsBind:YES];
        //开始把设备信息存入数据库
        [self saveDeviceModel];
        
    } else if (manager == self.checkSetupkManager) {
        NSNumber *number = [manager fetchDataWithReformer:self.checkCMDReformer];
        [self.readSetupManager setupLength:[number intValue]];
        [self.readSetupManager setupObjectId:DEVICE_OBJECTID_SETUP];
        [self.readSetupManager execute];
        
    } else if (manager == self.readSetupManager) {
        [SVProgressHUD showSuccessWithStatus:IFMLocalizedString(@"获取设置数据成功", nil)];
        [self.setupDataReformer bleManager:manager reformData:manager.rawData];
        [self bingDeviceInfoSend];
    }
    
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    if (manager == self.deviceStateManager) {
        [SVProgressHUD showErrorWithStatus:IFMLocalizedString(@"获取设备状态信息失败", nil)];
    }
    else if (manager == self.authorizeManager) {

        if (manager.device.isBind) {

            [[IFMHeartbeatPacket sharedInstance] Stop];
            [self.deviceArray removeAllObjects];

        } else {
            [SVProgressHUD showErrorWithStatus:IFMLocalizedString(@"验证设备失败", nil)];
            [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];
            [self.deviceArray removeAllObjects];
            
        }
        
    } else if (manager == self.bindManager) {
        
        [SVProgressHUD showErrorWithStatus:IFMLocalizedString(@"验证设备失败", nil)];
        [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];
        [self.deviceArray removeAllObjects];
        
        [SVProgressHUD showErrorWithStatus:IFMLocalizedString(@"绑定设备失败", nil)];
    }
}



- (NSMutableArray*)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray new];
        
//        CBPeripheral *peripheral = self.deviceArray[indexPath.row];
//        NSString *name = peripheral.name;
//        NSString *nick = [peripheral ifm_nick];
    }
    
    return _deviceArray;
}



- (IFMBLEAuthorizeManager*)authorizeManager {
    if (!_authorizeManager) {
        _authorizeManager = [[IFMBLEAuthorizeManager alloc] init];
        _authorizeManager.delegate = self;
    }
    
    return _authorizeManager;
}

- (IFMBLEBindManager*)bindManager {
    if (!_bindManager) {
        _bindManager = [[IFMBLEBindManager alloc] init];
        _bindManager.delegate = self;
    }
    
    return _bindManager;
}

- (IFMBLEDeviceStateManager*)deviceStateManager {
    if (!_deviceStateManager) {
        _deviceStateManager = [[IFMBLEDeviceStateManager alloc] init];
        _deviceStateManager.delegate = self;
    }
    
    return _deviceStateManager;
}



- (IFMCheckCMDReformer*)checkCMDReformer {
    if (!_checkCMDReformer) {
        _checkCMDReformer = [IFMCheckCMDReformer new];
    }
    
    return _checkCMDReformer;
}

- (IFMSetupDataReformer*)setupDataReformer {
    if (!_setupDataReformer) {
        _setupDataReformer = [IFMSetupDataReformer new];
    }
    
    return _setupDataReformer;
}

- (IFMBLECheckManager*)checkSetupkManager {
    if (!_checkSetupkManager) {
        _checkSetupkManager = [[IFMBLECheckManager alloc] init];
        _checkSetupkManager.delegate = self;
    }
    
    return _checkSetupkManager;
}

- (IFMBLEReadManager*)readSetupManager {
    if (!_readSetupManager) {
        _readSetupManager = [[IFMBLEReadManager alloc] init];
        _readSetupManager.delegate = self;
    }
    
    return _readSetupManager;
}


- (IFMSendFLTMessage *)scanPeripheral {
    if (!_scanPeripheral) {
        _scanPeripheral = [[IFMSendFLTMessage alloc] init];
    }
    return _scanPeripheral;
}

@end
