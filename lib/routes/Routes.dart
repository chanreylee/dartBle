import 'package:flutter/material.dart';
import 'package:dhsjakd/pages/ConnectPages/BleConnectPage.dart';

// ChangeNotifierProvider<BLECentralManager>(
//       create: (_) => BLECentralManager(),
//       child: BleConnectedPage(arguments: arguments)

final routes = {
  '/bleConnect': (context, {arguments}) => BleConnectPage(arguments: arguments)
};

// 大祭司哦啊接低洼
var onGenerateRoute = (RouteSettings settings) {
  // 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
