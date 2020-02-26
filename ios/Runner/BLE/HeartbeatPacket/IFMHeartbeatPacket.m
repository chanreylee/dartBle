//
//  IFMHeartbeatPacket.m
//  P3KApp
//
//  Created by 王泽 on 16/8/26.
//  Copyright © 2016年 Infomedia. All rights reserved.
//
#import "IFMBLEDeviceStateManager.h"
#import "IFMHeartbeatPacket.h"
#import "IFMDeviceManager.h"
#import "IFMDevice.h"
#import "IFMPlayerManger.h"
#import "IFMBLEReadManager.h"
#import "IFMBLECheckManager.h"
#import "IFMDeviceUtils.h"


@interface IFMHeartbeatPacket ()<IFMBLEManagerCallbackDelegate>

@property (nonatomic, strong)   NSTimer                     *timer;
@property (nonatomic, strong)   IFMBLEDeviceStateManager    *deviceStateManager;
@property (nonatomic, assign)   int                         num;
@property (nonatomic, strong)   IFMDevice                   *device;
@property (nonatomic, assign)   NSTimeInterval              timeInterval;
@property (nonatomic, strong)   IFMBLEReadManager           *readRTInfo;
@property (nonatomic, strong)   IFMBLECheckManager          *checkRTInfo;
@property (nonatomic, assign , readwrite) BOOL              isProcess;
@property (nonatomic, assign)   BOOL                        isUSB;
@property (nonatomic, assign)   BOOL                        isStartSport;

@end

@implementation IFMHeartbeatPacket

static IFMHeartbeatPacket *instance;

+ (instancetype)sharedInstance {
    static IFMHeartbeatPacket *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (BOOL)isOnTimer {

    return self.timer ? YES : NO;
}

- (void)Start {
    NSLog(@"开始心跳包发送");
    self.timeInterval = 0.38;
//    self.timeInterval = 10;
    [self startTimer];
}

- (void)Stop {

    [self stopTimer];
    NSLog(@"心跳包停止发送");
    
    if (![[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
    NSLog(@"检测到主控制中心没有连接外部设备,心跳包停止发送");
        self.isCanStart = NO;
        [[IFMDeviceManager sharedInstance] startScanningForServiceUUIDs:nil isAutoConnect:YES];
        if ([self.delegate respondsToSelector:@selector(againAutoConnectionDev)]) {
            [self.delegate againAutoConnectionDev];
        }
    }
}

- (void)startTimer {
    if (self.timer == nil) {
        if (self.isStartSport) {
            [self stopTimer];
            [self sendCheckRTInfo:nil];
        } else {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(sendReadRTInfo:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)sendCheckRTInfo:(id)sender {
    
    xU32 nowTime = [IFMDeviceUtils getNowTime];
    
    NSLog(@"开启运动时间:-------> %d", nowTime);
    
    [self.checkRTInfo setupObjectId:DEVICE_OBJECTID_CONTROL];
    [self.checkRTInfo setupEventType:CONTROL_OFFSET_RT_INFO_ALL];
    [self.checkRTInfo setupDbId:nowTime Dbpos:0];
    [self.checkRTInfo execute];
}

- (void)sendReadRTInfo:(id)sender {
    
    if (!self.isCanStart) {
        return;
    }

    xU32 lon = 0;
    xU32 lat = 0;
    
    if (self.isProcess) {
        [self.deviceStateManager execute];
    } else {
        if ([IFMPlayerManger sharedInstance].workMode == 1) {
            lon = 0;
            
            lat = 0;
            
            [self.readRTInfo setupObjectId:DEVICE_OBJECTID_CONTROL];
            [self.readRTInfo setupEventType:CONTROL_OFFSET_RT_INFO_ALL];
            [self.readRTInfo setupLat:lat lon:lon];
            [self.readRTInfo setupLength:sizeof(Ble_RT_Info)];
            [self.readRTInfo execute];

        } else {
            NSLog(@"lon:------->%d, lat:------->%d ",lon,lat);
            
            [self.readRTInfo setupObjectId:DEVICE_OBJECTID_CONTROL];
            [self.readRTInfo setupEventType:CONTROL_OFFSET_RT_INFO_ALL];
            [self.readRTInfo setupLat:lat lon:lon];
            [self.readRTInfo setupLength:sizeof(Ble_RT_Info)];
            [self.readRTInfo execute];
        }
    }
}

- (void)setupIsStartSport:(BOOL)isStartSport {

    self.isStartSport = isStartSport;
}


#pragma mark - IFMBLEManagerCallbackDelegate

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager {
    if (manager == self.deviceStateManager) {
        NSLog(@"......");
        self.num = 0;
        [SVProgressHUD dismiss];
        
        [self.device fillDeviceStateWithData:manager.rawData];
        
        if (self.device.isUsbConnection) {
            self.isUSB = YES;
        } else {
            if (self.isUSB) {
                
                if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
                    [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];
                    self.isUSB = NO;
                    return;
                }
            }
        }
    
        if (self.device.isRealTimeControl) {
            self.isProcess = YES;
            [self startTimer];
        } else {
            self.isProcess = NO;
            [self startTimer];
        }
    } else if (manager == self.readRTInfo) {
        [SVProgressHUD dismiss];
        self.num = 0;
        [[IFMPlayerManger sharedInstance] fillRTInfoWithData:manager.rawData];
        
        if (manager.device.isUsbConnection) {
            self.isUSB = YES;
        } else {
            if (self.isUSB) {
                
                if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
                    [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];
                    self.isUSB = NO;
                    return;
                }
            }
        }
        
        if (manager.device.isRealTimeControl) {

            self.isProcess = YES;
            [self startTimer];
        } else {
            self.isProcess = NO;
            [self startTimer];
        }
    } else if (manager == self.checkRTInfo) {
    
        self.isStartSport = NO;
        [self startTimer];
    }
}

- (void)managerCallbackDidFailed:(IFMBLEManager *)manager {
    if (manager == self.deviceStateManager) {
        
        if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
            
        self.num += 1;
            if (self.num == 37) {
                // 是否已连接外设
                if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
                    [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];
                    return;
                }
            }
            [self startTimer];
        }
    } else if (manager == self.readRTInfo) {
        if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
            
            self.num += 1;
            if (self.num == 37) {
                // 是否已连接外设
                if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
                    [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];
                    return;
                }
            }
            [self startTimer];
        }
    }
}

#pragma mark - getter & setter methods

- (IFMBLEDeviceStateManager*)deviceStateManager {
    if (!_deviceStateManager) {
        _deviceStateManager = [[IFMBLEDeviceStateManager alloc] init];
        _deviceStateManager.delegate = self;
        
    }
    return _deviceStateManager;
}

- (IFMBLEReadManager*)readRTInfo {
    if (!_readRTInfo) {
        _readRTInfo = [[IFMBLEReadManager alloc] init];
        _readRTInfo.delegate = self;
        
    }
    return _readRTInfo;
}

- (IFMBLECheckManager*)checkRTInfo {
    if (!_checkRTInfo) {
        _checkRTInfo = [[IFMBLECheckManager alloc] init];
        _checkRTInfo.delegate = self;
        
    }
    return _checkRTInfo;
}


- (IFMDevice *)device {

    if (!_device) {
        _device = [[IFMDevice alloc] init];
    }
    return _device;
}

@end
