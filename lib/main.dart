import 'package:flutter/material.dart';
import 'package:dhsjakd/routes/Routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    
    return MaterialApp(
      initialRoute: '/bleConnect',
      onGenerateRoute: onGenerateRoute,
    );
  }
}
