//
//  IFMFLTEngine.h
//  Runner
//
//  Created by 王泽 on 2019/12/18.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface IFMFLTEngine : NSObject
- (instancetype)initWithEngine:(FlutterEngine * _Nullable)engine;

- (FlutterEngine *)engine;
- (void)atacheToViewController:(FlutterViewController *)vc;

@end

NS_ASSUME_NONNULL_END
