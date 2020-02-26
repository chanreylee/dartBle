//
//  IFMBLEManager.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMBLEManager.h"
#import "IFMDeviceManager.h"
#import "IFMHeartbeatPacket.h"

@interface IFMBLEManager () <IFMDeviceManagerDataDelegate>
@property (nonatomic, weak) id<IFMBLEManager> child;

@property (nonatomic, assign, readwrite) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong, readwrite) NSString                *errorReason;
@property (nonatomic, assign, readwrite) BOOL                    isFlying;
@property (nonatomic, strong, readwrite) NSMutableData           *rawData;

@end

@implementation IFMBLEManager

#pragma mark - life cycle methods

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(IFMBLEManager)]) {
            self.child = (id<IFMBLEManager>)self;
        }
        else {
            @throw [NSException exceptionWithName:@"初始化失败" reason:@"IFMBLEManager的子类必须实现IFMBLEManagerProtocol" userInfo:nil];
        }
    }
    
    return self;
}

#pragma mark - public methods

- (id)fetchDataWithReformer:(id<IFMBLEManagerCallbackReformer>)reformer {
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(bleManager:reformData:)]) {
        resultData = [reformer bleManager:self reformData:self.rawData];
    } else {
        resultData = [self.rawData copy];
    }
    return resultData;
}

- (void)execute {
    if ([[IFMDeviceManager sharedInstance] isConnectPeripheral]) {
        [IFMDeviceManager sharedInstance].dataDelegate = self;
        self.isFlying = YES;
        [self.child start];
    }
    else {
        self.errorType = IFMBLEManagerErrorTypeNoConnection;
        self.errorReason = @"尚未连接设备";
        if ([self.delegate respondsToSelector:@selector(managerCallbackDidFailed:)]) {
            [self.delegate managerCallbackDidFailed:self];
        }
        self.isFlying = NO;
    }
}

- (void)openNotify {
    self.isFlying = YES;
    
    [IFMDeviceManager sharedInstance].dataDelegate = self;
}

- (void)closeNotify {
    self.isFlying = NO;
    
    [IFMDeviceManager sharedInstance].dataDelegate = nil;
}

- (void)successCallback {
    self.isFlying = NO;
    
    [IFMDeviceManager sharedInstance].dataDelegate = nil;
    
    if ([self.delegate respondsToSelector:@selector(managerCallbackDidSuccess:)]) {
        [self.delegate managerCallbackDidSuccess:self];
    }
//    //准备进入空闲状态,发送心跳包
//
    if ([IFMHeartbeatPacket sharedInstance].isCanStart) {
        [[IFMHeartbeatPacket sharedInstance] Start];
    }
    
}

- (void)failCallback {
    self.isFlying = NO;
    
    [IFMDeviceManager sharedInstance].dataDelegate = nil;
    
    if ([self.delegate respondsToSelector:@selector(managerCallbackDidFailed:)]) {
        [self.delegate managerCallbackDidFailed:self];
    }
    
//    //准备进入空闲状态,发送心跳包
    if ([IFMHeartbeatPacket sharedInstance].isCanStart) {
        [[IFMHeartbeatPacket sharedInstance] Start];
    }
}

- (void)sendData:(NSData*)data withResponse:(BOOL)withResponse {
    [[IFMDeviceManager sharedInstance] writeValue:data needResponse:withResponse];
}

#pragma mark - IFMDeviceManagerDataDelegate

- (void)deviceManager:(IFMDeviceManager*)deviceManager didWriteValueWithError:(NSError*)error {
    [self.child didWriteValueWithError:error];
}

- (void)deviceManager:(IFMDeviceManager*)deviceManager didReadValue:(NSData*)data error:(NSError*)error {
    [self.child didReadValue:data error:error];
}

#pragma mark - getter & setter methods

- (NSMutableData*)rawData {
    if (!_rawData) {
        _rawData = [NSMutableData data];
    }
    
    return _rawData;
}

@end
