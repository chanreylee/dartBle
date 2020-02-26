//
//  IFMHeartbeatPacket.h
//  P3KApp
//
//  Created by 王泽 on 16/8/26.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFMHeartbeatPacketDelegate <NSObject>

- (void)againAutoConnectionDev;

@end


@interface IFMHeartbeatPacket : NSObject

@property (nonatomic, weak) id<IFMHeartbeatPacketDelegate>   delegate;
@property (nonatomic, assign , readonly) BOOL isProcess;
@property (nonatomic, assign) BOOL             isCanStart;

+ (instancetype)sharedInstance;

- (BOOL)isOnTimer;

- (void)Start;

- (void)Stop;

- (void)setupIsStartSport:(BOOL)isStartSport;

@end
