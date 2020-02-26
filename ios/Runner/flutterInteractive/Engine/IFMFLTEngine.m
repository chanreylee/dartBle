//
//  IFMFLTEngine.m
//  Runner
//
//  Created by 王泽 on 2019/12/18.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "IFMFLTEngine.h"

@interface IFMFLTEngine()

@property (nonatomic, strong) FlutterEngine         *engine;
@property (nonatomic, strong) FlutterViewController *flutterViewController;

@end

@implementation IFMFLTEngine

- (instancetype)initWithEngine:(FlutterEngine * _Nullable)engine
{
    if (self = [super init]) {
        if(!engine){
            _engine = [[FlutterEngine alloc] initWithName:@"io.flutter" project:nil];
        }else{
            _engine = engine;
        }
        [_engine runWithEntrypoint:nil];
//        _flutterViewController = [[FlutterViewController alloc] initWithEngine:_engine nibName:nil bundle:nil];
        Class clazz = NSClassFromString(@"GeneratedPluginRegistrant");
        if (clazz) {
            if ([clazz respondsToSelector:NSSelectorFromString(@"registerWithRegistry:")]) {
                [clazz performSelector:NSSelectorFromString(@"registerWithRegistry:")
                            withObject:_engine];
            }
        }
    }
    return self;
}

@end
