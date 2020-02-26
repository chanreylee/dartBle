import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:dhsjakd/ble__manager/ble_IO_manager/BLEIOManager.dart';
import 'package:dhsjakd/utls/DataConvertTool.dart';
import 'package:dhsjakd/utls/NumsType.dart';

import 'P3KSetupKeys.dart';

class P3KSetupReformer extends BLEManagerCallbackReformer {
  int version;
  String software;
  String hardware;
  String loaderVersion;
  String baseloader;
  String gpsVersion;
  String bleVersion;
  int fileCount;
  String diskCapacity;
  int diskCapacity_int;
  String remainCapacity;
  String devModel;
  String serialNo;
  String macNo;
  bool autoVoice;
  bool isVoiceTimeSelected;
  bool isVoiceDistanceSelected;
  bool isVoicePaceSelected;
  bool isVoiceFrequencySelected;

  // BleSetupItem
  Uint8List _setupData;
  Map _setupMap = Map();

  @override
  Map bleManagerReformer(BleIOManager manager, Uint8List reformData) {
    this._setupMap.clear();
    ReadBuffer tempButter = ReadBuffer(reformData.buffer.asByteData());
    // reformData.buffer.asByteData().
    this._setupMap[kIFMSetupPropertyKey_Version] = tempButter.getUint32();
    this._setupMap[kIFMSetupPropertyKey_Software] =
        convertHexToStringVersion_reverse(tempButter.getUint32());
    this._setupMap[kIFMSetupPropertyKey_Hardware] =
        convertHexToStringVersion(tempButter.getUint32());
    this._setupMap[kIFMSetupPropertyKey_LoaderVersion] =
        convertHexToStringVersion(tempButter.getUint32());
    this._setupMap[kIFMSetupPropertyKey_Baseloader] =
        convertHexToStringVersion(tempButter.getUint32());
    this._setupMap[kIFMSetupPropertyKey_GPSVersion] =
        convertHexToStringVersion(tempButter.getUint32());
    this._setupMap[kIFMSetupPropertyKey_BLEVersion] =
        convertHexToStringBleNum(tempButter.getUint32());
    this._setupMap[kIFMSetupPropertyKey_MacNo] =
        getNumString(tempButter.getUint8List(8));
    this._setupMap[kIFMSetupPropertyKey_FileCount] = tempButter.getUint32();
    this._setupMap[kIFMSetupPropertyKey_DiskCapacity] =
        reformData.buffer.asByteData().getUint64(40, Endian.little);
    tempButter.getUint32();
    tempButter.getUint32();
    this._setupMap[kIFMSetupPropertyKey_RemainCapacity] =
        reformData.buffer.asByteData().getUint64(48, Endian.little);
    tempButter.getUint32();
    tempButter.getUint32();

    this._setupMap[kIFMSetupPropertyKey_DevModel] =
        getNumString(tempButter.getUint8List(16));
    this._setupMap[kIFMSetupPropertyKey_SerialNo] = 
        getNumString(tempButter.getUint8List(32));

    return this._setupMap;
  }

  int getVersion() {
    return this._setupMap[kIFMSetupPropertyKey_Version];
  }

  String getSoftware() {
    return this._setupMap[kIFMSetupPropertyKey_Software];
  }

  String getHardware() {
    return this._setupMap[kIFMSetupPropertyKey_Hardware];
  }

  String getLoaderVersion() {
    return this._setupMap[kIFMSetupPropertyKey_LoaderVersion];
  }

  String getBaseloader() {
    return this._setupMap[kIFMSetupPropertyKey_Baseloader];
  }

  String getGpsVersion() {
    return this._setupMap[kIFMSetupPropertyKey_GPSVersion];
  }

  String getBleVersion() {
    return this._setupMap[kIFMSetupPropertyKey_BLEVersion];
  }

  XInt32 getFileCount() {
    return XInt32(this._setupMap[kIFMSetupPropertyKey_FileCount]);
  }

  String getDiskCapacity() {
    return stringFromBytesCount(
        this._setupMap[kIFMSetupPropertyKey_DiskCapacity]);
  }

  XUint64 getDiskCapacity_int() {
    return XUint64(this._setupMap[kIFMSetupPropertyKey_DiskCapacity]);
  }

  String getRemainCapacity() {
    return stringFromBytesCount(
        this._setupMap[kIFMSetupPropertyKey_RemainCapacity]);
  }

  String getDevModel() {
    return this._setupMap[kIFMSetupPropertyKey_DevModel];
  }

  String getSerialNo() {
    return this._setupMap[kIFMSetupPropertyKey_SerialNo];
  }

  String getMacNo() {
    return this._setupMap[kIFMSetupPropertyKey_MacNo];
  }

  Uint8List getSetupData() {
    return this._setupData;
  }
}
