//
//  IFMFltBleCMDRealize.h
//  Runner
//
//  Created by 王泽 on 2020/1/7.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFMSendFLTMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface IFMFltBleCMDRealize : NSObject

- (void)executeCheckWithDic:(NSDictionary *)dic result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END
