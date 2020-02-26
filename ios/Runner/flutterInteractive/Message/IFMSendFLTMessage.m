//
//  IFMSendFLTMessage.m
//  Runner
//
//  Created by 王泽 on 2019/12/17.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "IFMSendFLTMessage.h"



@implementation IFMSendFLTMessage

- (void)sendDataMessage:(NSData *)message channel:(NSString *)channelName callback:(VoidBlock_id)callback {
    
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    FlutterBinaryCodec *binaryCodec = [[FlutterBinaryCodec alloc] init];
    FlutterBasicMessageChannel *stringChannel = [FlutterBasicMessageChannel messageChannelWithName:channelName binaryMessenger:flutterEngine.binaryMessenger codec:binaryCodec];
    [stringChannel sendMessage:message reply:^(id  _Nullable reply) {
        if (callback) {
            NSData *replyData = [binaryCodec decode:reply];
            callback(replyData);
        }
    }];
}

- (void)sendStringMessage:(NSString *)message channel:(NSString *)channelName callBack:(VoidBlock_string)callback {
    
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    FlutterStringCodec *stringCodec = [[FlutterStringCodec alloc] init];
    FlutterBasicMessageChannel *stringChannel = [FlutterBasicMessageChannel messageChannelWithName:channelName binaryMessenger:flutterEngine.binaryMessenger codec: stringCodec];
    [stringChannel sendMessage:message reply:^(id  _Nullable reply) {
        if (callback) {
            NSString *replyString = [stringCodec decode:reply];
            callback(replyString);
        }
    }];
}

- (void)sendBoolMessage:(BOOL)message channel:(NSString *)channelName callback:(VoidBlock_id)callback {
    
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    FlutterJSONMessageCodec *JSONCodec = [[FlutterJSONMessageCodec alloc] init];

    NSData *data = [JSONCodec encode:@{@"bool":@(message)}];
    [flutterEngine.binaryMessenger sendOnChannel:channelName message:data binaryReply:^(NSData * _Nullable reply) {
        if (callback) {
            NSDictionary *dic = [JSONCodec decode:reply];
            callback(dic);
        }
    }];
}

- (void)sendObjectMessage:(id)arrayOrDic channel:(NSString *)channelName callBack:(VoidBlock_id)callback {
    
    FlutterEngine *flutterEngine = [(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine];
    FlutterJSONMessageCodec *JSONCodec = [[FlutterJSONMessageCodec alloc] init];

    NSData *data = [JSONCodec encode:arrayOrDic];
    [flutterEngine.binaryMessenger sendOnChannel:channelName message:data binaryReply:^(NSData * _Nullable reply) {
        if (callback) {
            NSDictionary *dic = [JSONCodec decode:reply];
            callback(dic);
        }
    }];
}

@end
