//
//  IFMBLEManager.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "p3kbleproto.h"
#import "IFMDevice.h"
#import "IFMSendFLTMessage.h"

@class IFMBLEManager;
@protocol IFMBLEManager <NSObject>

@optional

- (xU16)objectId;

- (xU32)eventType;

- (void)setupObjectId:(xU16)objectId;

- (void)setupEventType:(xU32)eventType;

- (void)setupData:(NSData*)data;

- (void)setupLength:(xU32)length;

- (void)start;

- (void)didWriteValueWithError:(NSError*)error;

- (void)didReadValue:(NSData*)data error:(NSError*)error;

@end

@protocol IFMBLEManagerCallbackDelegate <NSObject>

@required

- (void)managerCallbackDidSuccess:(IFMBLEManager *)manager;
- (void)managerCallbackDidFailed:(IFMBLEManager *)manager;

@end

@protocol IFMBLEManagerCallbackReformer <NSObject>

@optional

- (id)bleManager:(IFMBLEManager*)manager reformData:(NSData*)data;

@end

typedef NS_ENUM(NSUInteger, IFMBLEManagerErrorType) {
    IFMBLEManagerErrorTypeDefault,      // 默认状态，还未请求
    IFMBLEManagerErrorTypeSuccess,      // 请求成功
    IFMBLEManagerErrorTypeInvalidParam, // 非法参数
    IFMBLEManagerErrorTypeIncorrectData,// 请求成功，数据错误
    IFMBLEManagerErrorTypeUnauthorized, // 设备未授权
    IFMBLEManagerErrorTypeUnbind,       // 设备未绑定
    IFMBLEManagerErrorTypeNoConnection  // 没有连接的设备
};

@interface IFMBLEManager : NSObject
@property (nonatomic, weak) id<IFMBLEManagerCallbackDelegate>   delegate;
@property (nonatomic, assign, readonly) IFMBLEManagerErrorType  errorType;
@property (nonatomic, strong, readonly) NSString                *errorReason;
@property (nonatomic, assign, readonly) BOOL                    isFlying;
@property (nonatomic, strong, readonly) NSMutableData           *rawData;
@property (nonatomic, strong) IFMDevice                         *device;
@property (nonatomic, copy) FlutterResult                     flutterResult;

- (id)fetchDataWithReformer:(id<IFMBLEManagerCallbackReformer>)reformer;

- (void)execute;

- (void)openNotify;

- (void)closeNotify;

- (void)successCallback;
- (void)failCallback;

- (void)sendData:(NSData*)data withResponse:(BOOL)withResponse;

@end
