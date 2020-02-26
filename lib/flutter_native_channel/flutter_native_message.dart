import 'dart:typed_data';
import 'package:flutter/services.dart';


// FLTNativeMessageChannel flutter 发送到 native 消息，可回复
// NativeFLTMessageChannel flutter 订阅 native 发送过来的 消息，可回复

class FLTNativeMessageChannel {

  //flutter端发送 message：二进制ByteData，channelName：通道名字, 返回结果 二进制ByteData
  Future<ByteData> sendByteDataMessage(String channelName, ByteData message) async {
    // //向平台发送二进制消息.
    // final WriteBuffer buffer = WriteBuffer()
    //   ..putFloat64(3.1415)
    //   ..putInt32(12345678);
    // final ByteData message = buffer.done();
    ByteData reply = await ServicesBinding.instance.defaultBinaryMessenger.send(channelName, message);
    return reply;
  }

  // 测试发送结构化消息;
  Future<ByteData> sendBoolMessage(String channelName, bool message) async  {
    // StandardMessageCodec messageCodec = StandardMessageCodec();
    JSONMessageCodec messageCodec = JSONMessageCodec();
    Map dic = {"bool":true}; 
    ByteData reply = await ServicesBinding.instance.defaultBinaryMessenger.send("messageChannel", messageCodec.encodeMessage(dic));
    return reply;
  }

  //flutter端发送 message：String，channelName：通道名字, 返回结果 String
  Future<String> sendStringMessage(String channelName, String message) async {
    var channel = BasicMessageChannel<String>(channelName, StringCodec());
    // 发送
    String reply = await channel.send(message);
    return reply;
  }
  

  // flutter端发送 message：List/Map，channelName：通道名字, 返回结果 List/Map
  Future<T> sendCustomMessage<T>(T object) async {
    // StandardMessageCodec messageCodec = StandardMessageCodec();
    JSONMessageCodec messageCodec = JSONMessageCodec();
    final T result = messageCodec.decodeMessage(await ServicesBinding.instance.defaultBinaryMessenger
        .send("messageChannel", messageCodec.encodeMessage(object)));
    return result;
  }


}



class NativeFLTMessageChannel {

  // 接收
  // 注册Bool数据接收，channelName通道名字, Native端发送 {"bool":ture/false} 转 Json二进制
  void registerBoolMessageFromNative(String channelName,{callback(bool message)}) {
    ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(channelName,(ByteData message) async {
      Map data = JSONMessageCodec().decodeMessage(message);
      callback(data["bool"]);
      return null;//可在此回复Native端信息
    });
  }

  // 注册String数据接收，channelName通道名字 Native端发送 String 通过 StringCodec()编码;
  void registerStringMessageFromNative(String channelName,{callback(String string)}) {
    var channel = BasicMessageChannel<String>(channelName, StringCodec());
    channel.setMessageHandler((String message) async {
      print('Received: $message');
      callback(message);
      return null;//可在此回复Native端信息
    });
  }

  // 注册List/Map数据接收，channelName通道名字 Native端发送 List/Map 转 Json二进制;
  void registerCustomMessageFromNative<T>(String channelName,{callback(T message)}) {
    ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(channelName,(ByteData message) async {
      T data = JSONMessageCodec().decodeMessage(message);
      callback(data);
      return message;//可在此回复Native端信息
    });
  }

  // 注册 二进制ByteData 数据接收，channelName通道名字 Native端发送 二进制; 接收数据后可用 ReadBuffer 自行解析
  void registerByteDataMessageFromNative(String channelName,{callback(ByteData message)}) {
    ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(channelName, (ByteData message) async {

      // final ReadBuffer readBuffer = ReadBuffer(message);
      // final double x = readBuffer.getFloat64();
      // final int n = readBuffer.getInt32();
      callback(message);
      return null;//可在此回复Native端信息
    });
  }

}