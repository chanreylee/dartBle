;//
//  IFMDeviceManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMDeviceManager.h"
#import "IFMHeartbeatPacket.h"
#import "IFMPlayerManger.h"

NSString * const IETIFM_Device_Prefix = @"IETP3K";
int i = 0;

const UInt8 DeviceServiceUUID[] = {0x5E,0x6D,0x1A,0x82,0xE5,0x03,0xC8,0x90,0x2D,0x3A,0x2E,0x1C,0x88,0x8F,0x9B,0xA0};
const UInt8 DeviceReadCharUUID[] = {0x55,0x58,0x46,0xE7,0xDD,0x83,0x2B,0xAA,0xBC,0x3A,0xFB,0x00,0xB7,0xC9,0xDA,0x57};
const UInt8 DeviceWriteCharUUID[] = {0x62,0xD4,0x2C,0x6A,0xB0,0xAC,0xA3,0x8E,0x69,0x36,0xFC,0xE9,0x65,0xD6,0x0D,0xCF};

@interface IFMDeviceManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong)   CBCentralManager    *centralManager;

@property (nonatomic, strong)   CBPeripheral        *recoveryPeripheral;
@property (nonatomic, strong, readwrite) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong)   NSMutableArray      *deviceArray;


@property (nonatomic, strong)   CBUUID              *serviceUUID;
@property (nonatomic, strong)   CBUUID              *readCharacteristicUUID;
@property (nonatomic, strong)   CBUUID              *writeCharacteristicUUID;


@property (nonatomic, strong)   CBService           *service;
//@property (nonatomic, strong)   CBCharacteristic    *readCharacteristic;
//@property (nonatomic, strong)   CBCharacteristic    *writeCharacteristic;

@property (nonatomic, strong)   NSTimer             *scanTimer;

@end

@implementation IFMDeviceManager

#pragma mark - life cycle methods

+ (instancetype)sharedInstance {
    static IFMDeviceManager * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[IFMDeviceManager alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 创建 central manager
        
        NSString *indetify = @"device_Indetify";
        const char *label = [indetify UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
        
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:@{CBCentralManagerOptionShowPowerAlertKey: @(YES)}];
//        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:@{CBCentralManagerOptionShowPowerAlertKey: @(YES),CBCentralManagerOptionRestoreIdentifierKey:
//                                                                                                    @"myCentralManagerIdentifier"}];
        
        // 准备service 和 characteristic 的 UUIDs
        [self prepareUUIDs];
    }
    
    return self;
}

#pragma mark - public methods

// 是否已连接外设
- (BOOL)isConnectPeripheral {
    if (self.connectedPeripheral == nil) {
        return NO;
    }
    return (self.connectedPeripheral.state == CBPeripheralStateConnected);
}

// 开始扫描外设。传入指定的Service UUID，只扫描提供这些service的外设
// uuids 数组中的类型为CBUUID
- (void)startScanningForServiceUUIDs:(NSArray*)uuids isAutoConnect:(BOOL)isAutoConnect {
    //是否是自动连接
    self.isAutoConnect = isAutoConnect;
    
    if ([self checkCentralManager:self.centralManager.state]) {
        [self.centralManager scanForPeripheralsWithServices:uuids options:nil];
    } else {
        [self.scanTimer invalidate];
        
        NSDictionary *userInfo = nil;
        if (uuids) {
            userInfo = @{@"uuids": uuids};
        }
        
        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(scanForPeripheralsWithServices:) userInfo:userInfo repeats:YES];
    }
}

- (void)scanForPeripheralsWithServices:(NSTimer*)timer {
    if ([self checkCentralManager:self.centralManager.state]) {
        NSArray *uuids = timer.userInfo[@"uuids"];
        [self.centralManager scanForPeripheralsWithServices:uuids options:nil];
        [self.scanTimer invalidate];
        self.scanTimer = nil;
    }
}

// 停止扫描外设
- (void)stopScanning {
    if ([self checkCentralManager:self.centralManager.state]) {
//        if (self.centralManager.isScanning) {
            [self.centralManager stopScan];
//        }
    }
}

// 连接外设
- (void)connectPeripheral:(CBPeripheral*)peripheral {
    if ([self checkCentralManager:self.centralManager.state] && ![self isConnectPeripheral]) {
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

// 连接外设
- (void)connectPeripheralWithName:(NSString*)name {
    for (CBPeripheral *peripheral in self.deviceArray) {
        if ([peripheral.name isEqualToString:name]) {
            if ([self checkCentralManager:self.centralManager.state] && ![self isConnectPeripheral]) {
                [self.centralManager connectPeripheral:peripheral options:nil];
                break;
            }
        }
    }
}

// 断开连接外设
- (void)disconnectPeripheral:(CBPeripheral*)peripheral {
    if ([self checkCentralManager:self.centralManager.state] &&
        [self isConnectPeripheral]) {
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

// 开始notify
- (void)startNotifyValue {
    if ([self checkCentralManager:self.centralManager.state]) {
        if ([self isConnectPeripheral]) {
            
            [self.connectedPeripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
        }
        else {
            dispatch_sync(dispatch_get_main_queue(),^{
                if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
                    [self.delegate deviceManager:self exceptionMessage:@"尚未连接设备"];
                }
            });
        }
    }
}

// 停止notify
- (void)stopNotifyValue {
    if ([self checkCentralManager:self.centralManager.state]) {
        if ([self isConnectPeripheral]) {
            [self.connectedPeripheral setNotifyValue:NO forCharacteristic:self.readCharacteristic];
        }
        else {
            dispatch_sync(dispatch_get_main_queue(),^{
                if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
                    [self.delegate deviceManager:self exceptionMessage:@"尚未连接设备"];
                }
                
            });
        }
    }
}

// 写一次数据
- (void)writeValue:(NSData*)data needResponse:(BOOL)needResponse {
    if ([self checkCentralManager:self.centralManager.state]) {
        if ([self isConnectPeripheral]) {

            //准备进入非空闲状态,停止心跳包
            if ([[IFMHeartbeatPacket sharedInstance] isOnTimer]) {
                [[IFMHeartbeatPacket sharedInstance] Stop];
            }
            
//            if (self.writeCharacteristic) {
                [self.connectedPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:(needResponse? CBCharacteristicWriteWithResponse: CBCharacteristicWriteWithoutResponse)];
//            }
//            else {
//                CBPeripheral *tempPeripheral = self.connectedPeripheral;
//                [self disconnectPeripheral:self.connectedPeripheral];
//                [self connectPeripheral:tempPeripheral];
//            }
            
        }
        else {
            dispatch_sync(dispatch_get_main_queue(),^{
                if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
                    [self.delegate deviceManager:self exceptionMessage:@"尚未连接设备"];
                }
                
            });
        }
    }
}


// 进入前台之后停止升级固件;
- (void)intoTheForegroundStopFirmwareContinue {

    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
           
           [self disconnectPeripheral:self.connectedPeripheral];
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
           
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               
               [IFMHeartbeatPacket sharedInstance].isCanStart = YES;
               [[IFMHeartbeatPacket sharedInstance] Start];
               
           });
    }
}

#pragma mark - private methods

- (void)prepareUUIDs {
    UInt8 len = 0;
    GET_ARRAY_LEN(DeviceServiceUUID, len);
    self.serviceUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:DeviceServiceUUID length:len]];
    
    GET_ARRAY_LEN(DeviceReadCharUUID, len);
    self.readCharacteristicUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:DeviceReadCharUUID length:len]];
    
    GET_ARRAY_LEN(DeviceWriteCharUUID, len);
    self.writeCharacteristicUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:DeviceWriteCharUUID length:len]];
}

- (BOOL)checkCentralManager:(CBManagerState)state {
    
    if (state == CBCentralManagerStatePoweredOn) {
        
        // 不知名原因 因手机而异 第一次调用哪怕打开手机蓝牙也会是 CBCentralManagerStateUnknown状态
        // 所以 手动调用第二次 变成 CBCentralManagerStatePoweredOn
//        if (i == 0) {
//            i++;
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"a" object:nil];
//        }
        return YES;
    }
    NSString *message = nil;
    
    if (state == CBCentralManagerStatePoweredOff) {
        message = @"设备蓝牙已关闭，请前往设置程序打开蓝牙";
    }
    else if (state == CBCentralManagerStateUnauthorized) {
        message = @"没有权限使用蓝牙功能";
    }
    else if (state == CBCentralManagerStateUnsupported) {
        message = @"设备没有蓝牙功能";
    }
    else if (state == CBCentralManagerStateResetting) {
        message = @"设备的蓝牙怎不可用，请稍后再试";
    }
    else if (state == CBCentralManagerStateUnknown) {
        message = @"设备的蓝牙功能暂不可用";
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
            [self.delegate deviceManager:self exceptionMessage:message];
    }
    
    return NO;
}

- (void)clean {
    self.service = nil;
    self.readCharacteristic = nil;
    self.writeCharacteristic = nil;
    
    if ([self isConnectPeripheral]) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    }
    
    self.connectedPeripheral.delegate = nil;
    self.connectedPeripheral = nil;
    // 清空蓝牙中心保存的外设列表
    [self.deviceArray removeAllObjects];
}

#pragma mark - CBCentralManagerDelegate


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self checkCentralManager:central.state];
    if (self.recoveryPeripheral) {
        [self connectPeripheral:self.recoveryPeripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    
    NSArray *devices = dict[CBCentralManagerRestoredStatePeripheralsKey];
    self.recoveryPeripheral = devices.firstObject;
    NSLog(@"devices : %@",devices);
    NSLog(@"");
}


//莫名设备
//C0F99607-3E72-F40F-DCEC-3F880632E588
//D685C181-89DF-B220-96FC-CE2F7B13BA6E
//7D9048E4-BD36-CF91-64C8-A89CAD9B28A4
//D111BD1F-AD7C-7964-DD91-01A2B0249994 黑色
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    dispatch_sync(dispatch_get_main_queue(),^{
        NSLog(@"%@",peripheral.name);
        
        if ([peripheral.name length] > 0 && [peripheral.name hasPrefix:IETIFM_Device_Prefix]) {
            [self.deviceArray addObject:peripheral];
            if ([self.delegate respondsToSelector:@selector(deviceManager:didDiscoverPeripheral:)]) {
                [self.delegate deviceManager:self didDiscoverPeripheral:peripheral];
            }
        }
        
//    NSDictionary*dic = advertisementData[@"kCBAdvDataServiceData"];
//
//       if(dic) {
//           CBUUID *uuid = [CBUUID UUIDWithString:@"FDA5"];
//
//           NSData*data = dic[uuid];
//           const int MAC_BYTE_LENGTH =6;
//
//           Byte  bytes[MAC_BYTE_LENGTH +1] = {0};
//           if([data length] >= MAC_BYTE_LENGTH) {
//               [data getBytes:bytes range:NSMakeRange([data length] - MAC_BYTE_LENGTH, MAC_BYTE_LENGTH)];
//
//               NSMutableArray *macs = [NSMutableArray array];
//
//               for(int i =0;i < MAC_BYTE_LENGTH ;i ++) {
//                   NSString*strByte = [NSString stringWithFormat:@"%02x",bytes[i]];
//
//                   [macs addObject:strByte];
//
//               }
//               NSString *strMac = [macs componentsJoinedByString:@":"];
//
//               NSLog(@"%@::%@",peripheral.name,strMac);
//
//           }
//
//        }

        
//        if ([peripheral.name length] > 0 && [peripheral.name hasPrefix:IETIFM_Device_Prefix]) {
//
//            NSPredicate *pred = [NSPredicate predicateWithFormat:@"userID = %@",
//                                 [[NSUserDefaults standardUserDefaults] valueForKey:UserID]];
//            RLMResults<IFMPersonalData *> *data = [IFMPersonalData objectsWithPredicate:pred];
//            IFMPersonalData *personalData = data.firstObject;
//
//            if (personalData.picoId && ![personalData.picoId isEqualToString:@""]) {
//
//                if (self.isAutoConnect) {
//
//                    if ([personalData.picoId isEqualToString:peripheral.identifier.UUIDString]) {
//                        if ([self.delegate respondsToSelector:@selector(deviceManager:didDiscoverPeripheral:)]) {
//                            [self.delegate deviceManager:self didDiscoverPeripheral:peripheral];
//                        }
//                    }
//                }
//            } else {
//                if ([self.delegate respondsToSelector:@selector(deviceManager:didDiscoverPeripheral:)]) {
//                    [self.delegate deviceManager:self didDiscoverPeripheral:peripheral];
//                }
//            }
//        }
    });
    
//            NSLog(@"%@",peripheral);
//    if ([peripheral.name length] > 0 && ([peripheral.name hasPrefix:@"ITEP4K"] || [peripheral.name hasPrefix:IETIFM_Device_Prefix])){
//
//        if ([peripheral.name isEqualToString:@"ITEP4K353535"]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"macid传输结束" object:nil];
//        } else {
//            if ([self.delegate respondsToSelector:@selector(deviceManager:didDiscoverPeripheral:)]) {
//                [self.delegate deviceManager:self didDiscoverPeripheral:peripheral];
//            }
//        }
//    }
    
//        //如果为自动连接 并且数据库内没有设备信息
//        if (self.isAutoConnect && [IFMDeviceModel allObjects].count != 0) {
//            
//            [self.deviceArray addObject:peripheral];
//            
//            RLMResults <IFMDeviceModel *> *models = [[IFMDeviceModel allObjects] sortedResultsUsingProperty:@"time" ascending:NO];
//            
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                
//                //找出数据库中时间最匹配的一条
//                
//                for (IFMDeviceModel *model in models) {
//                    
//                    for (CBPeripheral *tempPeripheral in self.deviceArray) {
//                        
//                        if ([model.deviceIdentifier isEqualToString:tempPeripheral.identifier.UUIDString]) {
//                            
//                            if ([self.delegate respondsToSelector:@selector(deviceManager:didDiscoverPeripheral:)]) {
//                                [self.delegate deviceManager:self didDiscoverPeripheral:tempPeripheral];
//                                return;
//                            }
//                        }
//                    }
//                }
//            });
//            
//        } else {
//        
//            if ([self.delegate respondsToSelector:@selector(deviceManager:didDiscoverPeripheral:)]) {
//                [self.delegate deviceManager:self didDiscoverPeripheral:peripheral];
//            }
//        }
        //
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    // 清除恢复的外设;
    self.recoveryPeripheral = nil;
    // 持有已连接的外设
    self.connectedPeripheral = peripheral;
    
    // 设置外设的代理
    self.connectedPeripheral.delegate = self;
    
    // 已连接上外设，停止扫描
    [self stopScanning];
    // 清空蓝牙中心保存的外设列表
    [self.deviceArray removeAllObjects];
    
    // 查找服务
    [self.connectedPeripheral discoverServices:@[self.serviceUUID]];
    
    dispatch_sync(dispatch_get_main_queue(),^{
        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
            //进入后台搞事情
        } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
               if ([self.delegate respondsToSelector:@selector(deviceManager:didConnectPeripheral:error:)]) {
                   [self.delegate deviceManager:self didConnectPeripheral:peripheral error:nil];
               }
        }
    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_sync(dispatch_get_main_queue(),^{
        if ([self.delegate respondsToSelector:@selector(deviceManager:didConnectPeripheral:error:)]) {
            [self.delegate deviceManager:self didConnectPeripheral:peripheral error:error];
        }
        
    });
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    dispatch_sync(dispatch_get_main_queue(),^{
        if ([self.delegate respondsToSelector:@selector(deviceManager:didDisconnectPeripheral:error:)]) {
            [self.delegate deviceManager:self didDisconnectPeripheral:peripheral error:error];
        }
        [self clean];
    });
}
    

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error {
    if (error) {
        NSString *message = [NSString stringWithFormat:@"查找外设:%@的服务失败\nError:%@", peripheral.name, [error localizedDescription]];
        
        dispatch_sync(dispatch_get_main_queue(),^{
            if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
                [self.delegate deviceManager:self exceptionMessage:message];
            }
        });
        
    }
    else {
        // 找到感兴趣的Service
        for (CBService *tempService in peripheral.services) {
            if ([tempService.UUID isEqual:self.serviceUUID]) {
                self.service = tempService;
                // 查找此服务的特征
                [peripheral discoverCharacteristics:@[self.readCharacteristicUUID, self.writeCharacteristicUUID] forService:tempService];
                break;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    if (error) {
        NSString *message = [NSString stringWithFormat:@"查找外设:%@的特征失败\nError:%@", peripheral.name, [error localizedDescription]];
        
        dispatch_sync(dispatch_get_main_queue(),^{
            if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
                [self.delegate deviceManager:self exceptionMessage:message];
            }
        });
        
    }
    else {
        // 找到感兴趣的Characteristic
        BOOL isReadReady = NO;
        BOOL isWriteReady = NO;
        for (CBCharacteristic *tempCharacteristic in service.characteristics) {
            if ([tempCharacteristic.UUID isEqual:self.readCharacteristicUUID]) { // 找到可读特征
                self.readCharacteristic = tempCharacteristic;
                isReadReady = YES;
            }
            else if ([tempCharacteristic.UUID isEqual:self.writeCharacteristicUUID]) { // 找到可写特征
                self.writeCharacteristic = tempCharacteristic;
                isWriteReady = YES;
            }
        }
        if (isReadReady && isWriteReady) {
            dispatch_sync(dispatch_get_main_queue(),^{
                if ([self.delegate respondsToSelector:@selector(deviceManagerIsReady:)]) {
                    [self startNotifyValue];
                    [self.delegate deviceManagerIsReady:self];
                }
            });
        } else {
        
            dispatch_sync(dispatch_get_main_queue(),^{
                NSString *message = [NSString stringWithFormat:@"查找外设:%@的特征失败\nError:%@", peripheral.name, [error localizedDescription]];
                if ([self.delegate respondsToSelector:@selector(deviceManager:exceptionMessage:)]) {
                    [self.delegate deviceManager:self exceptionMessage:message];
                }
                [self clean];
            });
        }
    }
}

- (void)setDataDelegate:(id<IFMDeviceManagerDataDelegate>)dataDelegate {

    _dataDelegate = dataDelegate;

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    dispatch_sync(dispatch_get_main_queue(),^{
        if ([self.dataDelegate respondsToSelector:@selector(deviceManager:didReadValue:error:)]) {
            [self.dataDelegate deviceManager:self didReadValue:characteristic.value error:error];
        }
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    dispatch_sync(dispatch_get_main_queue(),^{
        if ([self.dataDelegate respondsToSelector:@selector(deviceManager:didWriteValueWithError:)]) {
            [self.dataDelegate deviceManager:self didWriteValueWithError:error];
        }
    });
}

- (NSMutableArray<CBPeripheral *>*)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray new];
    }
    
    return _deviceArray;
}


@end
