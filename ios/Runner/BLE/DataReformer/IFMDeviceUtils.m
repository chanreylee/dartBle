//
//  IFMDeviceUtils.m
//  P3KApp
//
//  Created by 王泽 on 2017/9/12.
//  Copyright © 2017年 Infomedia. All rights reserved.
//

#import "IFMDeviceUtils.h"

@implementation IFMDeviceUtils

+ (P3K_TagHeader *)getHeartTagData:(xU8 *)pbuff buffsize:(xU16)buffsize tagMagic:(xU16)tagMagic {
    
    P3K_TagHeader *ptag;
    xU32			found_size;
    
    found_size = 0;
    while(found_size < buffsize)
    {
        ptag = (P3K_TagHeader *)(pbuff + found_size);
        if (tagMagic == ptag->datatag)
        {
            return (P3K_TagHeader *)ptag;
        }else
        {
            found_size += 1;
        }
    }
    return NULL;
}


+ (xU32)sumBleRtInfoWithPinfo:(xU8 *)pinfo len:(xU32)len {
    
    xU32 sum = 0;
    
    while(len--)
    {
        sum += *pinfo;
        pinfo++;
    }
    return sum;
    
}

+ (Sport_Tag_Ctrl *)getSportTagData:(xU8 *)pbuff buffsize:(xU32)buffsize tagMagic:(xU32)tagMagic {
    
    Sport_Tag_Ctrl *ptag;
    xU32			found_size;
    
    found_size = 0;
    while(found_size < buffsize)
    {
        ptag = (Sport_Tag_Ctrl *)(pbuff + found_size);
        if (tagMagic == ptag->magic)
        {
            return (Sport_Tag_Ctrl *)ptag;
        }else
        {
            found_size += 1;
        }
    }
    return NULL;
    
}

+ (xS32)getCalorie:(xU32)time distance:(xU32)distance height:(xU32)height weight:(xU32)weight age:(xU16)age sex:(xU8)sex steps:(xU32)steps {
    
    xU16	heart_rate, step_fre, heart_rate_min, heart_rate_max, step_fre_quick,step_fre_medium, step_fre_medium_1, step_fre_tardy;
    double	calorie;
    
    heart_rate = 220 - age;
    step_fre = (steps) / (time / 60);
    heart_rate_min = heart_rate * 0.6;
    heart_rate_max = heart_rate * 0.9;
    step_fre_quick = 180;
    step_fre_medium = 150;
    step_fre_medium_1 = 120;
    step_fre_tardy = 90;
    
    //plan  two
    if (step_fre <= step_fre_tardy)
    {
        heart_rate = heart_rate_min;
    }else if (step_fre >= step_fre_quick)
    {
        heart_rate = heart_rate_max;
    }else
    {
        if (step_fre < step_fre_medium_1)
        {
            heart_rate *= 0.6;
        }else if (step_fre >= step_fre_medium_1 && step_fre < step_fre_medium)
        {
            heart_rate *= 0.7;
        }else if (step_fre >= step_fre_medium && step_fre < 160)
        {
            heart_rate *= 0.75;
        }else
        {
            heart_rate *= 0.85;
        }
    }
    //////////////////////////////////////////////////////////////////////////
    
#if 0		//plan  one
    if (step_fre <= 80)
    {
        heart_rate = 100;
        //	else if (step_fre <= 100)
        //		heart_rate = 90;
    }else if (step_fre <= 140)
    {
        heart_rate = step_fre;
    }else if (step_fre > 140 && step_fre < 170)
    {
        heart_rate *= 0.8;
    }else if (step_fre >= 170 && step_fre < 180)
    {
        heart_rate *= 0.85;
        //	if(step_fre > (xU16)(heart_rate *  0.9))
        //			heart_rate *= 0.9;
        //		else
        //			heart_rate = step_fre;
    }else
    {
        heart_rate *= 0.90;
        //	if(step_fre > (xU16)(heart_rate *  0.9))
        //		heart_rate *= 0.95;
        //	else
        //		heart_rate = step_fre;
    }
#endif
    
    if (sex)
    {
        calorie = (((age * 0.074) - (weight * 0.05741) + (heart_rate * 0.4472) - 20.4022) * (time /60.0) / 4.184);
    }else
    {
        calorie = (((age * 0.2017) - (weight * 0.09036) + (heart_rate * 0.6309) - 55.0969) * (time /60.0) / 4.184);
    }
    if (calorie < 0)
        calorie = 0;
#ifdef WIN32
    printf("step_fre = %d  heart_rate = %d, calorie = %lf\n", step_fre, heart_rate, calorie);
#endif
    calorie *= 10;
    
    return (xS32)calorie;
    
    
}

+ (xS32)Get_Special_Key_8byte_to_16byte:(xU8 *)phardwareid pspecialkey:(xU8 *)pspecial_key {
    
    xU16 gKey[]= {
        0x34,0x7f,0x4a,0x5b,0x75,0x3a,0x03,0x43,
        0x6a,0x38,0x06,0x32,0x04,0x46,0x07,0x3d,
        0x28,0x48,0x4e,0x63,0x74,0x16,0x1b,0x3f,
        0x25,0x4c,0x0d,0x6f,0x79,0x02,0x2a,0x68,
        0x5a,0x1c,0x11,0x66,0x77,0x70,0x2b,0x0b,
        0x33,0x60,0x72,0x10,0x64,0x36,0x57,0x5c,
        0x14,0x31,0x40,0x19,0x7c,0x42,0x29,0x71,
        0x30,0x67,0x49,0x12,0x1f,0x4b,0x09,0x2f,
        0x05,0x5f,0x50,0x61,0x27,0x62,0x6c,0x0e,
        0x7e,0x51,0x59,0x41,0x0f,0x22,0x17,0x4d,
        0x47,0x5e,0x52,0x45,0x01,0x00,0x6d,0x6b,
        0x3c,0x1d,0x69,0x15,0x56,0x24,0x1e,0x20,
        0x3b,0x54,0x58,0x2c,0x26,0x0c,0x23,0x73,
        0x13,0x65,0x5d,0x7d,0x4f,0x76,0x37,0x44,
        0x78,0x1a,0x2d,0x18,0x39,0x08,0x0a,0x7a,
        0x53,0x55,0x6e,0x35,0x3e,0x21,0x2e,0x7b,
    };
    
    xU16   i, bit_val;
    xU16	bitnum = 8 * 8;
    
    memset(pspecial_key, 0, 16);
    for (i = 0; i < bitnum; i++)
    {
        bit_val = (phardwareid[i / 8] & (1 << (i % 8))) > 0 ? 1 : 0;
        
        pspecial_key[gKey[i*2] / 8] |= bit_val << (gKey[i*2] % 8);
        pspecial_key[gKey[i*2 + 1] / 8] |= bit_val << (gKey[i*2 + 1] % 8);
    }
    
    
//    for (NSInteger i = 0; i < 16; i ++) {
//        NSLog(@"%x",pspecial_key[i]);
//    }

    return 0;
    
}

+ (NSData *)convertHexDataToMacId:(NSString *)macId {
    
    const char *pstr = NULL;
    if ([macId canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        pstr = [macId cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    xU64 version = 0;
    NSUInteger len = strlen(pstr);
    for (NSUInteger i = 0; i < len; i++) {
        version = version * 10 + (pstr[i] - '0');
    }
    
    xU8		hardwareid[8];
    xU8     pspecial_key[16];
    
    
    for (NSInteger i = 0; i < 8; i++) {
        hardwareid[i] = (version >> 8 * i) & 0xff;
        NSLog(@"%x",hardwareid[i]);
    }
    NSLog(@"--------------");
    [IFMDeviceUtils Get_Special_Key_8byte_to_16byte:hardwareid pspecialkey:pspecial_key];
    
    NSData *keyData = [NSData dataWithBytes:pspecial_key length:sizeof(pspecial_key)];
    
    return keyData;
}

+ (NSString *)getMacIdStrWithMacId:(NSString *)macId {
    
    NSMutableString *hardwareid_Str = [[NSMutableString alloc] init];
    const char *pstr = NULL;
    if ([macId canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        pstr = [macId cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    xU64 version = 0;
    NSUInteger len = strlen(pstr);
    for (NSUInteger i = 0; i < len; i++) {
        version = version * 10 + (pstr[i] - '0');
    }
    
    xU8        hardwareid[8];

    for (NSInteger i = 0; i < 8; i++) {
        hardwareid[i] = (version >> 8 * i) & 0xff;
        [hardwareid_Str appendFormat:@"%x",hardwareid[i]];
        NSLog(@"%x",hardwareid[i]);
    }
    NSLog(@"--------------");
    
    return hardwareid_Str;
}

+ (NSData *)convertHexDataToMacIdEX:(NSString *)macId {
    
    const char *pstr = NULL;
    if ([macId canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        pstr = [macId cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    xU64 version = 0;
    NSUInteger len = strlen(pstr);
    for (NSUInteger i = 0; i < len; i++) {
        version = version * 10 + (pstr[i] - '0');
    }
    
    xU8        hardwareid[8];
    xU8     hardwareid_ex[8];
    xU8     pspecial_key[16];
    
    
    for (NSInteger i = 0; i < 8; i++) {
        hardwareid[i] = (version >> 8 * i) & 0xff;
    }

    for (NSInteger i = 0; i < 8; i++) {
        hardwareid_ex[i] = hardwareid[7 - i];
        NSLog(@"%x",hardwareid_ex[i]);
    }
    
    NSLog(@"--------------");
    
    [IFMDeviceUtils Get_Special_Key_8byte_to_16byte:hardwareid_ex pspecialkey:pspecial_key];
    
    NSData *keyData = [NSData dataWithBytes:pspecial_key length:sizeof(pspecial_key)];
    
    return keyData;
}

+ (NSString *)getEXMacIdStrWithMacIdEX:(NSString *)macId {
    
    NSMutableString *hardwareid_Str = [[NSMutableString alloc] init];
    const char *pstr = NULL;
    if ([macId canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        pstr = [macId cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    xU64 version = 0;
    NSUInteger len = strlen(pstr);
    for (NSUInteger i = 0; i < len; i++) {
        version = version * 10 + (pstr[i] - '0');
    }
    
    xU8        hardwareid[8];
    xU8     hardwareid_ex[8];
    
    for (NSInteger i = 0; i < 8; i++) {
        hardwareid[i] = (version >> 8 * i) & 0xff;
    }

    for (NSInteger i = 0; i < 8; i++) {
        hardwareid_ex[i] = hardwareid[7 - i];
        [hardwareid_Str appendFormat:@"%x",hardwareid_ex[i]];
        NSLog(@"%x",hardwareid_ex[i]);
    }
    
    NSLog(@"--------------");
    
    return hardwareid_Str;
}


+ (xU16)interceptionStr:(NSString *)str rang:(NSRange)rang {
    
    NSString *numStr = [str substringWithRange:rang];
    xU16 num = [numStr intValue];
    
    return num;
}


+ (xU32)getNowTime {
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateformatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    
    NSString *dateStr = [dateformatter stringFromDate:date];
    
    xU16 year = [IFMDeviceUtils interceptionStr:dateStr rang:NSMakeRange(0, 4)];
    xU16 month = [IFMDeviceUtils interceptionStr:dateStr rang:NSMakeRange(5, 2)];
    xU16 day = [IFMDeviceUtils interceptionStr:dateStr rang:NSMakeRange(8, 2)];
    xU16 hour = [IFMDeviceUtils interceptionStr:dateStr rang:NSMakeRange(11, 2)];
    xU16 min = [IFMDeviceUtils interceptionStr:dateStr rang:NSMakeRange(14, 2)];
    xU16 sec = [IFMDeviceUtils interceptionStr:dateStr rang:NSMakeRange(17, 2)];
    
    xU32 nowTime = [IFMDeviceUtils generalGetCompactTimeWithYear:year month:month day:day hour:hour min:min sec:sec];
    
    return nowTime;
}

+ (xU32)generalGetCompactTimeWithYear:(xU16)year month:(xU16)month day:(xU16)day hour:(xU16)hour min:(xU16)min sec:(xU16)sec {
    
    xU16	date,time;
    xU32	comptime;
    
    date = (year-1980);
    date <<= 9;
    date |= (month<<5);
    date |= day;
    
    time = hour;
    time <<= 11;
    time |= (min<<5);
    time |= (sec>>1);
    
    comptime = date;
    comptime <<= 16;
    comptime |= time;
    return	comptime;
}

@end
