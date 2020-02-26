

#import "IFMFLTBLEPlugin.h"
#import "IFMBleIOManager.h"
#import "IFMSendFLTMessage.h"

#import "IFMBLECheckManager.h"
#import "IFMBLEWriteManager.h"
#import "IFMBLEReadManager.h"
#import "IFMRealTimeControlManager.h"
#import "IFMBLEAuthorizeManager.h"
#import "IFMBLEBindManager.h"
#import "IFMBLEUnbindManager.h"
#import "IFMBLEBreakManager.h"
#import "IFMBLEDeviceStateManager.h"
#import "IFMFltBleCMDRealize.h"

static NSString *const CHANNEL_NAME = @"cn.com.infomedia.flutter_plugin.io/ble_method";

@interface IFMFLTBLEPlugin ()<IFMDeviceManagerDelegate>

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) NSDictionary *fParams;
@property (nonatomic, strong) IFMBleIOManager *testble;

@property (nonatomic, strong) IFMSendFLTMessage           *scanPeripheral;
@property (nonatomic, copy) FlutterResult     connectPeripheralResult;

@property (nonatomic, strong)   IFMBLEAuthorizeManager      *authorizeManager;
@property (nonatomic, strong)   IFMBLEBindManager           *bindManager;
@property (nonatomic, strong)   IFMBLEUnbindManager         *unbindManager;

@property (nonatomic, strong)   IFMBLEDeviceStateManager    *deviceStateManager;

@property (nonatomic, strong)   IFMBLECheckManager          *checkManager;
@property (nonatomic, strong)   IFMBLEWriteManager          *writeManager;
@property (nonatomic, strong)   IFMBLEReadManager           *readManager;
@property (nonatomic, strong)   IFMRealTimeControlManager   *realTimeControlManager;
@property (nonatomic, strong)   IFMBLEBreakManager          *breakManager;

@property (nonatomic, strong)   IFMFltBleCMDRealize         *fltBleCMDRealize;


@end

@implementation IFMFLTBLEPlugin

+ (instancetype)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self.class new];
    });
    return _instance;
}

//FlutterPluginRegistry 填入唯一str. 生成FlutterPluginRegistrar,
//FlutterPluginRegistrar 用来注册一个插件，并持有通道

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [IFMDeviceManager sharedInstance].delegate = [IFMFLTBLEPlugin sharedInstance];
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:CHANNEL_NAME
                                     binaryMessenger:[registrar messenger]];
    IFMFLTBLEPlugin* instance = [self.class sharedInstance];
    instance.methodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
    
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"startScanning" isEqualToString:call.method]) {
        [[IFMDeviceManager sharedInstance] startScanningForServiceUUIDs:nil isAutoConnect:YES];
        result = nil;
    } else if ([@"connectPeripheralWithName" isEqual: call.method]) {
        NSDictionary *peripheral = call.arguments;
        self.connectPeripheralResult = result;
        [[IFMDeviceManager sharedInstance] connectPeripheralWithName:peripheral[@"peripheral_Name"]];
        
    } else if ([@"isConnectPeripheral/bool" isEqualToString:call.method]) {
        result(@([IFMDeviceManager sharedInstance].isConnectPeripheral));
        
    } else if ([@"stopScanning" isEqualToString:call.method]) {
        [[IFMDeviceManager sharedInstance] stopScanning];
        
    } else if ([@"disconnectPeripheral" isEqualToString:call.method]) {
        
        [[IFMDeviceManager sharedInstance] disconnectPeripheral:[IFMDeviceManager sharedInstance].connectedPeripheral];

    } else if ([@"startNotify" isEqualToString:call.method]) {
        [[IFMDeviceManager sharedInstance] startNotifyValue];
        
    } else if ([@"stopNotify" isEqualToString:call.method]) {
           [[IFMDeviceManager sharedInstance] stopNotifyValue];
           
    } else if ([@"writeBleValue" isEqualToString:call.method]) {
        
        IFMFltBleCMDRealize *fltBleCMDRealize = [IFMFltBleCMDRealize new];
        
        self.fltBleCMDRealize = fltBleCMDRealize;
        [self.fltBleCMDRealize executeCheckWithDic:call.arguments result:result];
    } else if ([@"DebugLogInfo" isEqualToString:call.method]) {
        NSDictionary *dict = call.arguments;
        [SVProgressHUD setMinimumDismissTimeInterval:8];
        [SVProgressHUD showSuccessWithStatus:[MZYModelHelper getJsonStringWith:dict]];
    } else if ([@"interactionEvents" isEqualToString:call.method]) {
           NSDictionary *dict = call.arguments;
        if ([dict[@"isOpen"] boolValue]) {
            while ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        } else {
            //禁止用户进行操作
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        }
           
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (FlutterViewController *)currentViewController {
    return (FlutterViewController*)([UIApplication sharedApplication].delegate.window.rootViewController);
}



#pragma mark - IFMDeviceManagerDelegate

- (void)deviceManager:(IFMDeviceManager*)deviceManager didDiscoverPeripheral:(CBPeripheral*)peripheral {
    if (deviceManager.isAutoConnect) {
        
        NSString *name = peripheral.name;
        NSDictionary *dict = @{@"name":name,@"nikename":@"王泽的设备5415"};
        
        [self.scanPeripheral sendObjectMessage:dict channel:@"startScanning/BlePeripheral" callBack:^(id result) {
            if (result) {
                NSDictionary *resultDic = result;
//                [SVProgressHUD showErrorWithStatus:[MZYModelHelper getJsonStringWith:resultDic]];
            }
        }];
    }
}

- (void)deviceManager:(IFMDeviceManager*)deviceManager didConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"连接设备失败"];
        NSDictionary *dict = @{@"isConnect":@(false)};
        self.connectPeripheralResult(dict);
    }
    else {

    }
}

- (void)deviceManager:(IFMDeviceManager*)deviceManager didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error {
    if (error) {
        NSDictionary *dict = @{@"isConnect":@(false)};
        self.connectPeripheralResult(dict);
    }
}

- (void)deviceManagerIsReady:(IFMDeviceManager*)deviceManager {
    [SVProgressHUD showSuccessWithStatus:@"连接设备成功"];
    NSDictionary *dict = @{@"isConnect":@(YES),@"peripheral":@{@"nickname":@"王泽的设备5415",@"name":deviceManager.connectedPeripheral.name}};
    if (self.connectPeripheralResult) {
        self.connectPeripheralResult(dict);
    }
    
    // 获取设备状态
//    [self.deviceStateManager execute];
    
}

- (void)deviceManager:(IFMDeviceManager*)deviceManager exceptionMessage:(NSString*)message {
    [SVProgressHUD showErrorWithStatus:message];
    NSDictionary *dict = @{@"isConnect":@(false)};
    self.connectPeripheralResult(dict);
}

- (IFMSendFLTMessage *)scanPeripheral {
    if (!_scanPeripheral) {
        _scanPeripheral = [[IFMSendFLTMessage alloc] init];
    }
    return _scanPeripheral;
}


@end
