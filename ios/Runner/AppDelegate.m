#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "MZYModelHelper.h"
#import "IFMDeviceManager.h"
#import "IFMSendFLTMessage.h"

@interface AppDelegate ()

@property(nonatomic, strong)FlutterViewController* controller;
@property(nonatomic, strong)FlutterJSONMessageCodec* JSONMessageCodec;
@property(nonatomic, strong)IFMSendFLTMessage *bleDisconnect;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    self.controller = (FlutterViewController*)self.window.rootViewController;
    self.flutterEngine = self.controller.engine;
    
    
//    IFMFLTEngine *engine = [[IFMFLTEngine alloc] initWithEngine:[(AppDelegate *)[[UIApplication sharedApplication] delegate] flutterEngine]];
//    FlutterViewController *flutterViewController = [[FlutterViewController alloc] initWithEngine:engine nibName:nil bundle:nil];
    
    [IFMFLTBLEPlugin registerWithRegistrar: [self registrarForPlugin:@"IFMFLTBLEPlugin"]];
    [IFMDeviceManager sharedInstance];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //费是不可
    NSDictionary *dict = @{@"isBleDisconnect":@(YES)};
    [RACObserve([IFMDeviceManager sharedInstance] , connectedPeripheral) subscribeNext:^(id x) {
        if (!x) {
            [self.bleDisconnect sendObjectMessage:dict channel:@"ble_Disconnect" callBack:^(id result) {
                if (result) {
                   NSDictionary *resultDic = result;

                }
            }];
        }
    }];
    
}


- (FlutterJSONMessageCodec *)JSONMessageCodec {
    if (!_JSONMessageCodec) {
        _JSONMessageCodec = [[FlutterJSONMessageCodec alloc] init];
    }
    return _JSONMessageCodec;
}

- (IFMSendFLTMessage *)bleDisconnect {
    if (!_bleDisconnect) {
        _bleDisconnect = [[IFMSendFLTMessage alloc] init];
    }
    return _bleDisconnect;
}

@end
