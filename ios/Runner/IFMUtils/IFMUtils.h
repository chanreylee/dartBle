//
//  IFMIOSDevice.h
//  IFMApp
//
//  Created by huoguanghua on 16/5/19.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IFMLocalizedString(key, comment) \
[IFMUtils IFMLocalizedString: (key)]

@interface IFMUtils : NSObject

+ (NSString*)generateUniqueString;

// 设备uuid
+ (NSString*)deviceId;

// Documents路径
+ (NSString*)documentsPath;

// Library路径
+ (NSString*)libraryPath;

// bundle id
+ (NSString*)bundleIdentifier;

// bundle name
+ (NSString*)bundleName;

// version
+ (NSString*)versionString;

// short version
+ (NSString*)shortVersionString;


+ (NSString*)displayTextOfNumber:(NSInteger)number;

/**
 *  生成随机验证码
 *
 *  @return 验证码
 */
+ (NSString*)generateSMSCode;

+ (NSString*)generateUniqueFileName;

+ (NSString*)generateUniqueOSSFilePath;

// 从格林威治时间获得年月日时分秒
+ (void)decodeTime:(unsigned int)comptime toYear:(unsigned short *)pyear toMonth:(unsigned short *)pmonth toDay:(unsigned short *)pday toHour:(unsigned short *)pHour toMinute:(unsigned short *)pMinute toSecond:(unsigned short *)pSecond;

/**
 *得到本机现在用的语言
 * en-CN 或en  英文  zh-Hans-CN或zh-Hans  简体中文   zh-Hant-CN或zh-Hant  繁体中文    ja-CN或ja  日本  ......
 */

+ (NSString*)getPreferredLanguage;

+ (BOOL)isChinaLanguage;

+(BOOL)runningInBackground;

+(BOOL)runningInForeground;

//手机系统型号;
+ (NSString*)iphonePlatform;

//屏幕类型 4/5/6/6p/X/XR/XS_MAX;
+ (NSString*)iphoneType;

+ (NSString *)IFMLocalizedString:(NSString *)translation_key;

/**
 * 手机号码格式验证 2019.8.14更新
 */
+ (BOOL)isMobile:(NSString *)phoneNum;

@end
