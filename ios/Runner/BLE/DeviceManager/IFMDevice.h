//
//  IFMDevice.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFMDevice : NSObject
//@property (nonatomic, strong, readonly) NSString        *deviceName; // remote device name
//@property (nonatomic, strong, readonly) NSString        *protocolVersion; // protover of remote device
@property (nonatomic, assign, readonly) BOOL            hasStatics; // 当前有存储在机器内部的运动数据
@property (nonatomic, assign, readonly) BOOL            isTransmiting; // 数据传输过程中
@property (nonatomic, assign, readonly) BOOL            isCharging; // 设备正在充电
@property (nonatomic, assign, readonly) BOOL            isRunning; // 客户正在运动中
@property (nonatomic, assign, readonly) BOOL            isWritting; // 正在将数据写入硬件
@property (nonatomic, assign, readonly) BOOL            isBind; // 设备是否已绑定
@property (nonatomic, assign, readonly) BOOL            isAuthorized; // 设备是否已验证
@property (nonatomic, assign, readonly) BOOL            isRealTimeControl; // 设备是否正在处理控制
@property (nonatomic, assign, readonly) BOOL            isUsbConnection;    //USB 是否连接中
@property (nonatomic, assign, readonly) UInt8           battery; // 设备电量千分比
@property (nonatomic, assign, readonly) UInt8           operationPercent; // 当前命令进行的百分比
@property (nonatomic, assign, readonly) UInt8           hardwareVersion; // 硬件版本号
@property (nonatomic, assign, readonly) UInt8           firmwareVersion; // 固件版本号
@property (nonatomic, assign, readonly) UInt8           gpsVersion; // gps版本号
@property (nonatomic, assign, readonly) UInt8           bleVersion; // ble版本号
@property (nonatomic, assign, readonly) UInt8           lastCMDType; // 上一次的cmd type
@property (nonatomic, assign, readonly) UInt8           packetNumber; // 读或写的包编号
@property (nonatomic, assign, readonly) UInt16          objectID; // 读或写的objectID
@property (nonatomic, assign, readonly) UInt8           lastCMDResult; // 上一次的cmd result for debug
@property (nonatomic, strong, readonly) NSString        *lastCMDResultString; // 上一次的cmd result

/*
 填充设备状态数据
 */
- (void)fillDeviceStateWithData:(NSData*)data;
@end
