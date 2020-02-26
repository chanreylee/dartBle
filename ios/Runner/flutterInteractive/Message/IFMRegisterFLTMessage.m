//
//  IFMRegisterFLTMessage.m
//  Runner
//
//  Created by 王泽 on 2019/12/18.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "IFMRegisterFLTMessage.h"

@implementation IFMRegisterFLTMessage

//- (void)registerFLTMessageWithChannelName:(NSString *)channelName callback:(VoidBlock_id)callback {
//    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
//    [flutterEngine.binaryMessenger setMessageHandlerOnChannel:channelName binaryMessageHandler:^(NSData * _Nullable message, FlutterBinaryReply  _Nonnull reply) {
//
//    }];
//}

- (void)registerFLTBoolWithChannelName:(NSString *)channelName callback:(VoidBlock_id)callback {
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    [flutterEngine.binaryMessenger setMessageHandlerOnChannel:channelName binaryMessageHandler:^(NSData * _Nullable message, FlutterBinaryReply  _Nonnull reply) {
        FlutterJSONMessageCodec *JSONCodec = [[FlutterJSONMessageCodec alloc] init];
        if (callback) {
            callback([JSONCodec decode:message]);
        }
        reply(nil);
    }];
}

- (void)registerFLTDataWithChannelName:(NSString *)channelName callback:(VoidBlock_id)callback {
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    [flutterEngine.binaryMessenger setMessageHandlerOnChannel:channelName binaryMessageHandler:^(NSData * _Nullable message, FlutterBinaryReply  _Nonnull reply) {
        if (callback) {
            callback(message);
        }
        reply(nil);
    }];
}

- (void)registerFLTStringWithChannelName:(NSString *)channelName callback:(VoidBlock_id)callback {
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    [flutterEngine.binaryMessenger setMessageHandlerOnChannel:channelName binaryMessageHandler:^(NSData * _Nullable message, FlutterBinaryReply  _Nonnull reply) {
        FlutterStringCodec *stringCodec = [[FlutterStringCodec alloc] init];
        if (callback) {
            callback([stringCodec decode:message]);
        }
        reply(nil);
    }];
}

- (void)registerFLTObjectWithChannelName:(NSString *)channelName callback:(VoidBlock_id)callback {
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    [flutterEngine.binaryMessenger setMessageHandlerOnChannel:channelName binaryMessageHandler:^(NSData * _Nullable message, FlutterBinaryReply  _Nonnull reply) {
        FlutterJSONMessageCodec *JSONCodec = [[FlutterJSONMessageCodec alloc] init];
        if (callback) {
            callback([JSONCodec decode:message]);
        }
        reply(nil);
    }];
}

@end
