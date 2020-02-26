import 'dart:ffi';

import 'dart:typed_data';

import 'package:dhsjakd/utls/NumsType.dart';
import 'package:flutter/foundation.dart';

String getNumString (Uint8List numList) {
  
    String numString = "";
    for (int i = 0; i < numList.length; i++) {
        numString += numList[i].toRadixString(16).toUpperCase();
        if (i != numList.length - 1) {
          numString += ".";
        }
    }
    return numString;
}

String convertHexToStringVersion (int version) {
  String string = "";
  string += (version & 0x000000ff).toString() + ".";
  string += ((version & 0x0000ff00) >> 8).toString() + ".";
  string += ((version & 0x00ff0000) >> 16).toString() + ".";
  string += ((version & 0xff000000) >> 24).toString();
  return string;
}

String convertHexToStringVersion_reverse (int version) {
  String string = "";
  string += ((version & 0xff000000) >> 24).toString() + ".";
  string += ((version & 0x00ff0000) >> 16).toString() + ".";
  string += ((version & 0x0000ff00) >> 8).toString() + ".";
  string += (version & 0x000000ff).toString();
  return string;
}

String convertHexToStringBleNum (int bleNum) {
  int  hw_h, hw_l, fw_1,fw_2, fw_3;
  hw_h = ((bleNum >> (16 + 4)) & 0xf);
  hw_l = ((bleNum >> 16) & 0xf);
  fw_1 = ((bleNum >> 8) & 0xff);
  fw_2 = ((bleNum >> 4) & 0xf);
  fw_3 = ((bleNum) & 0xf);
  String string = hw_h.toString() + "." + 
                  hw_l.toString() + "-" +
                  fw_1.toString() + "." +
                  fw_2.toString() + "." +
                  fw_3.toString();
  return string;
}

String stringFromBytesCount (int count) {
  int mCount = (count / (1024 * 1024)).toInt();

  String string = null;

  if (mCount > 1024) {
        int gCount = (mCount / 1024).toInt();
        int temp = mCount % 1024;
        
        if (temp == 0) {
            string = gCount.toString() + "G";
        }
        else {
            string = (gCount.toDouble() + temp.toDouble() / 1024.0).toStringAsFixed(2) + "G"; 
        }
    }
    else {
        int temp = count % (1024 * 1024);
        if (temp != 0) {
            string = mCount.toString() + "M";
        }
        else {
            string = (mCount.toDouble() + temp.toDouble() / 1024.0*1024.0).toStringAsFixed(2) + "M";
        }
    }

  return string;

}
 

int sumBleRtInfoWithPinfo (Uint8List pinfo, int len) {
  int sum = 0;
  ReadBuffer readBuffer = ReadBuffer(pinfo.buffer.asByteData());
  while (len-- != 0) {
    sum += readBuffer.getUint8();
  }
  return sum;
}

Uint16List getHeartTagData (Uint8List pbuff, int buffsize, int tagMagic) {

  Uint16List ptag = Uint16List(2);
  Uint8List newPbuff = Uint8List.fromList(pbuff);

  int	found_size = 0;

  while(found_size < buffsize)
    {
        // newPbuff.buffer.asByteData().getUint16(31 + found_size, Endian.host);
        if (tagMagic == newPbuff.buffer.asByteData(31 + found_size, 4).getUint16(0))
        {
          ptag[0] = newPbuff.buffer.asByteData(31 + found_size, 4).getUint16(0);
          ptag[1] = newPbuff.buffer.asByteData(31 + found_size + 2, 4).getUint16(0);
            return ptag;
        }else
        {
            found_size += 1;
        }
    }
    return null;
}



int reversedDataToiOS(int xnum, int len, bool isUnint) {

    ByteData data = ByteData(len);
    Uint8List uTempList = Uint8List(len);
    Int8List tempList = Int8List(len);

    Uint8List iOS_UList = Uint8List(len);
    Int8List iOS_List = Int8List(len);

  switch (len) {
    // X16
    case 2:
      {
        if (isUnint) {
          data.setUint16(0, xnum);
          uTempList.setRange(0, len, data.buffer.asUint8List(0, len));
          for (var i = 0; i < len; i++) {
            iOS_UList[len - 1 - i] = uTempList[i];
          }
          return iOS_UList.buffer.asByteData(0, len).getUint16(0, Endian.little);
        } else {
          data.setInt16(0, xnum, Endian.little);
          tempList.setRange(0, len, data.buffer.asInt8List(0, len));
          for (var i = 0; i < len; i++) {
            iOS_List[len - 1 - i] = tempList[i];
          }
          return iOS_List.buffer.asByteData(0, len).getInt16(0, Endian.little);
        }
      }
      break;
    case 4:
    {

      if (isUnint) {
          data.setUint32(0, xnum, Endian.little);
          uTempList.setRange(0, len, data.buffer.asUint8List(0, len));
          for (var i = 0; i < len; i++) {
            iOS_UList[len - 1 - i] = uTempList[i];
          }
          return iOS_UList.buffer.asByteData(0, len).getUint32(0, Endian.little);
        } else {
          data.setInt32(0, xnum, Endian.little);
          tempList.setRange(0, len, data.buffer.asInt8List(0, len));
          for (var i = 0; i < len; i++) {
            iOS_List[len - 1 - i] = tempList[i];
          }
          return iOS_List.buffer.asByteData(0, len).getInt32(0, Endian.little);
        }
    }
    break;
    case 8:
    {

      if (isUnint) {
          data.setUint64(0, xnum, Endian.little);
          uTempList.setRange(0, len, data.buffer.asUint8List(0, len));
          for (var i = 0; i < len; i++) {
            iOS_UList[len - 1 - i] = uTempList[i];
          }
          return iOS_UList.buffer.asByteData(0, len).getUint64(0, Endian.little);
        } else {
          data.setInt64(0, xnum, Endian.little);
          tempList.setRange(0, len, data.buffer.asInt8List(0, len));
          for (var i = 0; i < len; i++) {
            iOS_List[len - 1 - i] = tempList[i];
          }
          return iOS_List.buffer.asByteData(0, len).getInt64(0, Endian.little);
        }
    }
      break;
    default:
    {
      return 0;
    }
  } 
        
}
