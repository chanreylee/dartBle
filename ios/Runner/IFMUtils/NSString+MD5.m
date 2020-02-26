//
//  NSString+MD5.m
//  P3KApp
//
//  Created by Guanghua Huo on 16/6/23.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (NSString*)md5 {
    if([self length] == 0) {
        return @"";
    }
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString copy];  
}

- (NSString*)md5_16 {
    if([self length] == 0) {
        return @"";
    }
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 4; count < 12; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString copy];
}


@end
