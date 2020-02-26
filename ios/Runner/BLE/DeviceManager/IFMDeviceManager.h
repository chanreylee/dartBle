//
//  IFMDeviceManager.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IFMDeviceManager;
@protocol IFMDeviceManagerDelegate <NSObject>

@optional

- (void)deviceManager:(IFMDeviceManager*)deviceManager didDiscoverPeripheral:(CBPeripheral*)peripheral;

- (void)deviceManager:(IFMDeviceManager*)deviceManager didConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error;

- (void)deviceManager:(IFMDeviceManager*)deviceManager didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error;

- (void)deviceManagerIsReady:(IFMDeviceManager*)deviceManager;

- (void)deviceManager:(IFMDeviceManager*)deviceManager exceptionMessage:(NSString*)message;

@end

@protocol IFMDeviceManagerDataDelegate <NSObject>

@optional

- (void)deviceManager:(IFMDeviceManager*)deviceManager didWriteValueWithError:(NSError*)error;

- (void)deviceManager:(IFMDeviceManager*)deviceManager didReadValue:(NSData*)data error:(NSError*)error;

@end

@interface IFMDeviceManager : NSObject
@property (nonatomic, weak) id<IFMDeviceManagerDelegate>        delegate;
@property (nonatomic, weak) id<IFMDeviceManagerDataDelegate>    dataDelegate;

@property (nonatomic, assign) BOOL                      isAutoConnect;
@property (nonatomic, strong, readonly) CBPeripheral    *connectedPeripheral;
@property (nonatomic, strong)   CBCharacteristic    *readCharacteristic;
@property (nonatomic, strong)   CBCharacteristic    *writeCharacteristic;


+ (instancetype)sharedInstance;

// 是否已连接外设
- (BOOL)isConnectPeripheral;

// 开始扫描外设。传入指定的Service UUID，只扫描提供这些service的外设
// uuids 数组中的类型为CBUUID
- (void)startScanningForServiceUUIDs:(NSArray*)uuids isAutoConnect:(BOOL)isAutoConnect;

// 停止扫描外设
- (void)stopScanning;

// 连接外设
- (void)connectPeripheral:(CBPeripheral*)peripheral;

// 通过name连接外设
- (void)connectPeripheralWithName:(NSString*)name;

// 断开连接外设
- (void)disconnectPeripheral:(CBPeripheral*)peripheral;

// 开始notify
- (void)startNotifyValue;

// 停止notify
- (void)stopNotifyValue;

// 写一次数据
- (void)writeValue:(NSData*)data needResponse:(BOOL)needResponse;

// 进入后台之后开始升级固件;
- (void)intoTheBackgroundFirmwareContinue;

// 进入前台之后停止升级固件;
- (void)intoTheForegroundStopFirmwareContinue;

@end
