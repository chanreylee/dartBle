//
//  IFMIOSDevice.m
//  IFMApp
//
//  Created by huoguanghua on 16/5/19.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import "IFMUtils.h"
#import <sys/utsname.h>

#import "NSString+MD5.h"

NSString * const kIFMKeychainDeviceIdKey = @"kIFMKeychainDeviceIdKey";

@implementation IFMUtils

+ (NSString*)generateUniqueString {
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"ddHHmmss.sss";
    }
    
    NSDate *now = [NSDate new];
    NSString *dataString = [dateFormatter stringFromDate:now];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    int32_t rdm = arc4random() % 100000;
    return [NSString stringWithFormat:@"%@%05d", dataString, rdm];
}

+ (NSString*)deviceId {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:UserID] md5_16];
}

+ (NSString*)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString*)libraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString*)bundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

+ (NSString*)bundleName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString*)versionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString*)shortVersionString {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (void)decodeTime:(unsigned int)comptime toYear:(unsigned short *)pYear toMonth:(unsigned short *)pMonth toDay:(unsigned short *)pDay toHour:(unsigned short *)pHour toMinute:(unsigned short *)pMinute toSecond:(unsigned short *)pSecond {
    unsigned short	date,time;
    
    date = (unsigned short)(comptime>>16);
    time = (unsigned short)(comptime&0xFFFF);
    
    *pYear = (date>>9) + 1980;
    *pMonth = (date>>5)&0xF;
    *pDay = date&0x1F;
    *pHour = (time>>11);
    *pMinute = (time>>5)&0x3F;
    *pSecond = (time&0x1F)<<1;
}

+ (NSString*)displayTextOfNumber:(NSInteger)number {
    NSString *text = @"";
    if (number < 10000) {
        text = [NSString stringWithFormat:@"%ld", number];
    }
    else {
        if (number % 10000 > 1000) {
            text = [NSString stringWithFormat:@"%.1lf万", ((double)number) / 10000];
        }
        else {
            text = [NSString stringWithFormat:@"%ld万", number / 10000];
        }
    }
    
    return text;
}

+ (NSString*)generateSMSCode {
    int32_t code1 =  arc4random() % 9 + 1;
    int32_t code2 =  arc4random() % 10;
    int32_t code3 =  arc4random() % 10;
    int32_t code4 =  arc4random() % 10;
    
    return [NSString stringWithFormat:@"%d%d%d%d", code1, code2, code3, code4];
}


+ (NSString*)generateUniqueFileName {
    NSTimeInterval timeInterval = [[NSDate new] timeIntervalSince1970];
    int rdm = arc4random() % 999999;
    NSString *str = [NSString stringWithFormat:@"%06d%lf", rdm, timeInterval];
    return [str stringByReplacingOccurrencesOfString:@"." withString:@""];
}

+ (NSString*)generateUniqueOSSFilePath {
    return [NSString stringWithFormat:@"paw3000/%@", [IFMUtils generateUniqueString]];
}

//iOS 获取当前手机系统语言



/**
 *得到本机现在用的语言
 * en-CN 或en  英文  zh-Hans-CN或zh-Hans  简体中文   zh-Hant-CN或zh-Hant  繁体中文    ja-CN或ja  日本  ......
 */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (BOOL)isChinaLanguage {
    BOOL isChina = NO;
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    if ([preferredLang isEqualToString:@"zh-Hans-CN"] || [preferredLang isEqualToString:@"zh-Hans"] || [preferredLang isEqualToString:@"zh-Hant-CN"] || [preferredLang isEqualToString:@"zh-Hant"]) {
        isChina = YES;
    }
    return isChina;
}


+(BOOL) runningInBackground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    
    return result;
}

+(BOOL) runningInForeground
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateActive);
    
    return result;
}

+ (NSString*)iphonePlatform {

    struct utsname systemInfo;

    uname(&systemInfo);

    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return platform;

//    if([platform isEqualToString:@"iPhone1,1"])return@"iPhone 2G";
//
//    if([platform isEqualToString:@"iPhone1,2"])return@"iPhone 3G";
//
//    if([platform isEqualToString:@"iPhone2,1"])return@"iPhone 3GS";
//
//    if([platform isEqualToString:@"iPhone3,1"])return@"iPhone 4";
//
//    if([platform isEqualToString:@"iPhone3,2"])return@"iPhone 4";
//
//    if([platform isEqualToString:@"iPhone3,3"])return@"iPhone 4";
//
//    if([platform isEqualToString:@"iPhone4,1"])return@"iPhone 4S";
//
//    if([platform isEqualToString:@"iPhone5,1"])return@"iPhone 5";
//
//    if([platform isEqualToString:@"iPhone5,2"])return@"iPhone 5";
//
//    if([platform isEqualToString:@"iPhone5,3"])return@"iPhone 5c";
//
//    if([platform isEqualToString:@"iPhone5,4"])return@"iPhone 5c";
//
//    if([platform isEqualToString:@"iPhone6,1"])return@"iPhone 5s";
//
//    if([platform isEqualToString:@"iPhone6,2"])return@"iPhone 5s";
//
//    if([platform isEqualToString:@"iPhone7,1"])return@"iPhone 6 Plus";
//
//    if([platform isEqualToString:@"iPhone7,2"])return@"iPhone 6";
//
//    if([platform isEqualToString:@"iPhone8,1"])return@"iPhone 6s";
//
//    if([platform isEqualToString:@"iPhone8,2"])return@"iPhone 6s Plus";
//
//    if([platform isEqualToString:@"iPhone8,4"])return@"iPhone SE";
//
//    if([platform isEqualToString:@"iPhone9,1"])return@"iPhone 7";
//
//    if([platform isEqualToString:@"iPhone9,2"])return@"iPhone 7 Plus";
//
//    if([platform isEqualToString:@"iPhone10,1"])return@"iPhone 8";
//
//    if([platform isEqualToString:@"iPhone10,4"])return@"iPhone 8";
//
//    if([platform isEqualToString:@"iPhone10,2"])return@"iPhone 8 Plus";
//
//    if([platform isEqualToString:@"iPhone10,5"])return@"iPhone 8 Plus";
//
//    if([platform isEqualToString:@"iPhone10,3"])return@"iPhone X";
//
//    if([platform isEqualToString:@"iPhone10,6"])return@"iPhone X";
//
//    if([platform isEqualToString:@"iPod1,1"])return@"iPod Touch 1G";
//
//    if([platform isEqualToString:@"iPod2,1"])return@"iPod Touch 2G";
//
//    if([platform isEqualToString:@"iPod3,1"])return@"iPod Touch 3G";
//
//    if([platform isEqualToString:@"iPod4,1"])return@"iPod Touch 4G";
//
//    if([platform isEqualToString:@"iPod5,1"])return@"iPod Touch 5G";
//
//    if([platform isEqualToString:@"iPad1,1"])return@"iPad 1G";
//
//    if([platform isEqualToString:@"iPad2,1"])return@"iPad 2";
//
//    if([platform isEqualToString:@"iPad2,2"])return@"iPad 2";
//
//    if([platform isEqualToString:@"iPad2,3"])return@"iPad 2";
//
//    if([platform isEqualToString:@"iPad2,4"])return@"iPad 2";
//
//    if([platform isEqualToString:@"iPad2,5"])return@"iPad Mini 1G";
//
//    if([platform isEqualToString:@"iPad2,6"])return@"iPad Mini 1G";
//
//    if([platform isEqualToString:@"iPad2,7"])return@"iPad Mini 1G";
//
//    if([platform isEqualToString:@"iPad3,1"])return@"iPad 3";
//
//    if([platform isEqualToString:@"iPad3,2"])return@"iPad 3";
//
//    if([platform isEqualToString:@"iPad3,3"])return@"iPad 3";
//
//    if([platform isEqualToString:@"iPad3,4"])return@"iPad 4";
//
//    if([platform isEqualToString:@"iPad3,5"])return@"iPad 4";
//
//    if([platform isEqualToString:@"iPad3,6"])return@"iPad 4";
//
//    if([platform isEqualToString:@"iPad4,1"])return@"iPad Air";
//
//    if([platform isEqualToString:@"iPad4,2"])return@"iPad Air";
//
//    if([platform isEqualToString:@"iPad4,3"])return@"iPad Air";
//
//    if([platform isEqualToString:@"iPad4,4"])return@"iPad Mini 2G";
//
//    if([platform isEqualToString:@"iPad4,5"])return@"iPad Mini 2G";
//
//    if([platform isEqualToString:@"iPad4,6"])return@"iPad Mini 2G";
//
//    if([platform isEqualToString:@"iPad4,7"])return@"iPad Mini 3";
//
//    if([platform isEqualToString:@"iPad4,8"])return@"iPad Mini 3";
//
//    if([platform isEqualToString:@"iPad4,9"])return@"iPad Mini 3";
//
//    if([platform isEqualToString:@"iPad5,1"])return@"iPad Mini 4";
//
//    if([platform isEqualToString:@"iPad5,2"])return@"iPad Mini 4";
//
//    if([platform isEqualToString:@"iPad5,3"])return@"iPad Air 2";
//
//    if([platform isEqualToString:@"iPad5,4"])return@"iPad Air 2";
//
//    if([platform isEqualToString:@"iPad6,3"])return@"iPad Pro 9.7";
//
//    if([platform isEqualToString:@"iPad6,4"])return@"iPad Pro 9.7";
//
//    if([platform isEqualToString:@"iPad6,7"])return@"iPad Pro 12.9";
//
//    if([platform isEqualToString:@"iPad6,8"])return@"iPad Pro 12.9";
//
//    if([platform isEqualToString:@"i386"])return@"iPhone Simulator";
//
//    if([platform isEqualToString:@"x86_64"])return@"iPhone Simulator";

}

+ (NSString*)iphoneType {
    
    if(CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size))   return @"iPhone 3GS";
    
    if(CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size))   return @"iPhone 4";
    
    if(CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size))  return @"iPhone 5";

    if(CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size))  return @"iPhone 6";
    
    if(CGSizeEqualToSize(CGSizeMake(1080, 1920), [[UIScreen mainScreen] currentMode].size)) return @"iPhone 6 Plus";
    
    if(CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)) return @"iPhone X";
    
    if(CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size))  return @"iPhone XR";
    
    if(CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size)) return @"iPhone XS Max";
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    return platform;
    
}

#define CURR_LANG                        ([[NSLocale preferredLanguages] objectAtIndex:0])
+ (NSString *)IFMLocalizedString:(NSString *)translation_key {
    NSString * s = NSLocalizedString(translation_key, nil);
    //NSString * s = IFMLocalizedStringFromTable(@"trainTitle",@"文件名",@"");
    if (![CURR_LANG isEqual:@"en"] && ![CURR_LANG isEqual:@"zh-Hans-CN"] && ![CURR_LANG isEqual:@"zh-Hans"] && ![CURR_LANG isEqual:@"zh-Hant-CN"] && ![CURR_LANG isEqual:@"zh-Hant"] && ![CURR_LANG isEqual:@"ja"] && ![CURR_LANG isEqual:@"ja-CN"] && ![CURR_LANG isEqual:@"ja-JP"]) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    return s;
}

/**
 * 手机号码格式验证
 */
+ (BOOL)isMobile:(NSString *)phoneNum {
    
    NSString *MOBILE = @"^(13[0-9]|14[5-9]|15[0-3,5-9]|16[2,5,6,7]|17[0-8]|18[0-9]|19[1,3,5,8,9])\\d{8}$";
    NSPredicate *pred_mobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [pred_mobile evaluateWithObject:phoneNum];
}

@end
