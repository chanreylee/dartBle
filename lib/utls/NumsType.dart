import 'dart:typed_data';

class XInt8 {
  XInt8(this._value);

  var _value = 0;
  
  int get getValue {
    return this._value.toSigned(8);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XUint8 {
  XUint8(this._value);

  var _value = 0;
  
  int get getValue {
    return this._value.toUnsigned(8);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XInt16 {
  XInt16(this._value);

  var _value = 0;

  int get getValue {
    return this._value.toSigned(16);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XUint16 {
  XUint16(this._value);

  var _value = 0;
  
  int get getValue {
    return this._value.toUnsigned(16);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XInt32 {
  XInt32(this._value);

  var _value = 0;

  int get getValue {
    return this._value.toSigned(32);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XUint32 {
  XUint32(this._value);

  var _value = 0;
  
  int get getValue {
    return this._value.toUnsigned(32);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XInt64 {
  XInt64(this._value);

  var _value = 0;

  int get getValue {
    return this._value.toSigned(64);
  }

  void set setValue(int value) {
    this._value = value;
  }
}

class XUint64 {
  XUint64(this._value);

  var _value = 0;
  
  int get getValue {
    return this._value.toUnsigned(64);
  }

  void set setValue(int value) {
    this._value = value;
  }
}


/// Cast the list of bytes into a typed [Uint8List].
///
/// When [copy] is specified, the content will be copied even if the input
/// [bytes] are already Uint8List.
Uint8List castBytes(List<int> bytes, {bool copy = false}) {
  if (bytes is Uint8List) {
    if (copy) {
      final list = new Uint8List(bytes.length);
      list.setRange(0, list.length, bytes);
      return list;
    } else {
      return bytes;
    }
  } else {
    return new Uint8List.fromList(bytes);
  }
}