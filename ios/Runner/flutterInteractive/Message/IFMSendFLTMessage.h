//
//  IFMSendFLTMessage.h
//  Runner
//
//  Created by 王泽 on 2019/12/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "MZYModelHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface IFMSendFLTMessage : NSObject

- (void)sendDataMessage:(NSData *)message channel:(NSString *)channelName callback:(VoidBlock_id)callback;

- (void)sendStringMessage:(NSString *)message channel:(NSString *)channelName callBack:(VoidBlock_string)callback;

- (void)sendBoolMessage:(BOOL)message channel:(NSString *)channelName callback:(VoidBlock_id)callback;

- (void)sendObjectMessage:(id)arrayOrDic channel:(NSString *)channelName callBack:(VoidBlock_id)callback;

@end

NS_ASSUME_NONNULL_END
