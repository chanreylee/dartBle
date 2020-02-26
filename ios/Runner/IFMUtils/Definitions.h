//
//  Definitions.h
//  IFMApp
//
//  Created by 霍广华 on 16/4/24.
//  Copyright © 2016年 Infomedia. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h

/************************************************
 * NSLog
 ***********************************************/
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif


/************************************************
 * 固件 信息
 ***********************************************/

#define IFM_FirmwareInfo        @"FirmwareInfo"
#define IFM_Version             @"Version"


/************************************************
 * 星历 历书地址
 ***********************************************/

#define IFM_EphemerisURL        @"https://alp.u-blox.com/current_1d.alp"
#define IFM_EphemerisInfo       @"EphemerisInfo"
#define IFM_EphemerisName       [NSString stringWithFormat:@"%ld.alp",(long)[[NSUserDefaults standardUserDefaults]integerForKey:IFM_EphemerisInfo]]

#define IFM_lotooPicoURl_AppStore  @"http://itunes.apple.com/app/id1204723706"       

/************************************************
 * 登录方式 ,  社交账号类型  ,  用户性别类型
 ***********************************************/


// 用户性别类型
typedef NS_ENUM(NSUInteger, IFMUserGenderType) {
    kUserGenderTypeUnknown = 0,     // 未知
    kUserGenderTypeMale = 1,        // 男
    kUserGenderTypeFemale = 2,      // 女
};

// 所连接PICO 的语言类型
typedef NS_ENUM(NSInteger, IFMPicoLanguageType) {
    IFMPicoLanguageTypeChineseAndEnglish    = 1,                  // 中英文
    IFMPicoLanguageTypeKorean               = 2,                  // 韩文
    IFMPicoLanguageTypeJapanese             = 3,                  // 日文
    IFMPicoLanguageTypeRussian              = 4,                  // 俄文
    IFMPicoLanguageTypeSpanish              = 7,                  // 西语（西班牙语、德语、法语）
};

/************************************************
 * Scheme
 友盟
 AppKey:5795c1be67e58e2bed000f90
 
 QQ
 APPID:1105567034
 APPKEY:i9u9zTaunPX7JIzM
 
 新浪微博：
 App Key：602148794
 App Secret：cede12dbba6e9ebdacd48bbdac112dda
 
 微信：
 审核中
 
 云通讯：
 
 ACCOUNT SID：8a48b5514ff923b4014fff9ddc4d1196
 AUTH TOKEN：442041c391ee4e168187080187a429cd
 Rest URL(生产)：https://app.cloopen.com:8883
 AppID：aaf98f894ff913860150026b91950805
 
 短信模板id：103627
 短信模板内容：【爱韵动】您的验证码是{1}，请于{2}分钟内正确输入
 ***********************************************/


//一 . 在扫描绑定界面 开启扫描15秒内未连接设备
//二 . 在用户已绑定设备的情况下 开启扫描20秒内未自动连接设备
//三 . 在用户连接设备，授权未通过的情况下。


/************************************************
 * 用户信息
 ***********************************************/

#define UserID           @"UserID"               //userId
#define Nick             @"Nick"                 //用户昵称
#define Password         @"Password"             //密码
#define Location         @"Location"             //位置
#define Token            @"token"                //token

/************************************************
 * 获取字节数组的长度
 ***********************************************/
#define GET_ARRAY_LEN(array, len) {len = (sizeof(array) / sizeof(array[0]));}

#pragma mark - Block

/************************************************
 * Blocks
 ***********************************************/

typedef void (^VoidBlock)();
typedef BOOL (^BoolBlock)();
typedef int  (^IntBlock) ();
typedef id   (^IDBlock)  ();

typedef void (^VoidBlock_int)(int);
typedef BOOL (^BoolBlock_int)(int);
typedef int  (^IntBlock_int) (int);
typedef id   (^IDBlock_int)  (int);

typedef void (^VoidBlock_string)(NSString *);
typedef BOOL (^BoolBlock_string)(NSString *);
typedef int  (^IntBlock_string) (NSString *);
typedef id   (^IDBlock_string)  (NSString *);

typedef void (^VoidBlock_id)(id);
typedef BOOL (^BoolBlock_id)(id);
typedef int  (^IntBlock_id) (id);
typedef id   (^IDBlock_id)  (id);

#pragma mark - 颜色宏定义

/************************************************
 * RGB
 ***********************************************/
#define RGB(r, g, b) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

/************************************************
 * RGBA
 ***********************************************/
#define RGBAlpha(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

/************************************************
 * HexRGB
 ***********************************************/
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/************************************************
 * HexRGBAlpha
 ***********************************************/
#define HexRGBAlpha(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#pragma mark - 尺寸大小

#define IsIOS8  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_5_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH <= 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


/************************************************
 * screen width
 ***********************************************/
#define IFM_ScreenWidth [UIScreen mainScreen].bounds.size.width
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
/************************************************
 * screen height
 ***********************************************/
#define IFM_ScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

/************************************************
 * navigation bar height
 ***********************************************/


#define IFM_NavigationBarHeight 44
#define NavigationBarHeight     44

/************************************************
 * status bar height
 ***********************************************/
#define IFM_StatusBarHeight 44
#define StatusBarHeight     20

/************************************************
 * 标准space
 ***********************************************/
#define IFM_StandardSpace 8

/************************************************
 * 分隔线 height
 ***********************************************/
#define IFM_SplitLineHeight 0.5

/************************************************
 * image border width
 ***********************************************/
#define IFM_ImageBorderWidth 0.5

/************************************************
 * 单行 height
 ***********************************************/
#define IFM_SingleCellHeight 47

#pragma mark - Color定义

/************************************************
 * tab bar background color
 ***********************************************/
#define IFM_TabBarBackgroundColor HexRGB(0xc4c4c4c)

/************************************************
 * page background color
 ***********************************************/
#define IFM_PageBackgroundColor HexRGB(0xefeff4)

/************************************************
 * highlighted color
 ***********************************************/
#define IFM_HighlightedColor HexRGB(0xfefefe)

/************************************************
 * white color
 ***********************************************/
#define IFM_WhiteColor HexRGB(0xffffff)

/************************************************
 * dark black color
 ***********************************************/
#define IFM_DarkBlackColor HexRGB(0x2d2d2d)

/************************************************
 * light black color
 ***********************************************/
#define IFM_LightBlackColor HexRGB(0x929292)

/************************************************
 * image border color
 ***********************************************/
#define IFM_ImageBorderColor HexRGB(0x848484)

#pragma mark - Font定义

/************************************************
 * extra large font
 ***********************************************/
#define IFM_ExtraLargeFont  [UIFont systemFontOfSize:21]

/************************************************
 * large font
 ***********************************************/
#define IFM_LargeFont  [UIFont systemFontOfSize:18]

/************************************************
 * normal font
 ***********************************************/
#define IFM_NormalFont  [UIFont systemFontOfSize:16]

/************************************************
 * small font
 ***********************************************/
#define IFM_SmallFont  [UIFont systemFontOfSize:14]

/************************************************
 * extra small font
 ***********************************************/
#define IFM_ExtraSmallFont  [UIFont systemFontOfSize:10]

#pragma mark - WZ 运动界面按钮状态

#define IFM_PlanButton  @"planButton_status"

#pragma mark - 通知

#define IFMRemoveRadioChange_Notification    @"IFMRemoveRadioChangeNotification"


///-----------
///  判断iOS机型
///-----------

#define kIS_IPHONE_3GS [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_4S [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_5C_5S [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_6_6S [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_6P_6SP [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(1080, 1920), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_7_8 [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_7P_8P [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(1080, 1920), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_X_XS [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_XS_Max [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kIS_IPHONE_XR [UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : \
NO
#define kISX [[IFMUtils iphoneType] isEqualToString:@"iPhone X"]  \
          || [[IFMUtils iphoneType] isEqualToString:@"iPhone XR"] \
          || [[IFMUtils iphoneType] isEqualToString:@"iPhone XS Max"]


#endif /* Definitions_h */
