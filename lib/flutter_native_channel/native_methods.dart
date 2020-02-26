import 'flutter_native_method.dart';

class NativeMethods {
  static void interactionEvents (bool isOpen) {
    FLTNativeMethodChannel().sendMethod("interactionEvents",arguments: {"isOpen":isOpen});
  }



}