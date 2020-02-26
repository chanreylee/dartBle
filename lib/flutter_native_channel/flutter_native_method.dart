import 'package:flutter/services.dart';


class FLTNativeMethodChannel {
  
  static const CHANNEL_NAME = "cn.com.infomedia.flutter_plugin.io/ble_method";
  MethodChannel _channel;

  //单例
  factory FLTNativeMethodChannel() =>_getInstance();
  static FLTNativeMethodChannel get instance => _getInstance();
  static FLTNativeMethodChannel _instance;
  FLTNativeMethodChannel._internal() {
    // 初始化
    _channel = const MethodChannel(CHANNEL_NAME)
                      ..setMethodCallHandler(methodCall);
    
  }
  static FLTNativeMethodChannel _getInstance() {
    if (_instance == null) {
      _instance = new FLTNativeMethodChannel._internal();
    }
    return _instance;
  }

  Future<dynamic> methodCall (MethodCall call) async {
    switch (call.method) {
      case 'bar':
        return call.arguments;
      // case 'baz':
      //   throw PlatformException(code: '400', message: 'This is bad');
      default:
        //未能找到
        throw MissingPluginException();
    }
  }


  //flutter端发送 methodName：方法名字，arguments：参数, callback：回调
  void sendMethod(String methodName, {dynamic arguments, callback(dynamic result)}) async {
    dynamic result = await _channel.invokeMethod(methodName,arguments);
    callback(result);
  }

  Future<dynamic> sendMethod_V2(String methodName, {dynamic arguments}) async {
    dynamic result = await _channel.invokeMethod(methodName,arguments);
    return result;
  }

  //flutter端发送 methodName：方法名字，arguments：参数, callback：回调
  void sendDebugLogInfo(dynamic arguments, {callback(dynamic result)}) async {
    dynamic result = await _channel.invokeMethod("DebugLogInfo",arguments);
    callback(result);
  }

}


  


