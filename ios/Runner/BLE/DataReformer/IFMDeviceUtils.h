//
//  IFMDeviceUtils.h
//  P3KApp
//
//  Created by 王泽 on 2017/9/12.
//  Copyright © 2017年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IFMDeviceUtils : NSObject


+ (P3K_TagHeader *)getHeartTagData:(xU8 *)pbuff buffsize:(xU16)buffsize tagMagic:(xU16)tagMagic;

+ (xU32)sumBleRtInfoWithPinfo:(xU8 *)pinfo len:(xU32)len;

+ (Sport_Tag_Ctrl *)getSportTagData:(xU8 *)pbuff buffsize:(xU32)buffsize tagMagic:(xU32)tagMagic;

+ (xS32)getCalorie:(xU32)time distance:(xU32)distance height:(xU32)height weight:(xU32)weight age:(xU16)age sex:(xU8)sex steps:(xU32)steps;

+ (xS32)Get_Special_Key_8byte_to_16byte:(xU8 *)phardwareid pspecialkey:(xU8 *)pspecial_key;

+ (NSData *)convertHexDataToMacId:(NSString *)macId;
+ (NSString *)getMacIdStrWithMacId:(NSString *)macId;

+ (NSData *)convertHexDataToMacIdEX:(NSString *)macId;
+ (NSString *)getEXMacIdStrWithMacIdEX:(NSString *)macId;

+ (xU32)getNowTime;

@end
