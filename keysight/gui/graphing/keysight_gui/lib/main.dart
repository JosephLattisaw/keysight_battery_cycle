import 'package:flutter/material.dart';
import 'package:keysight_gui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color(Colors.black.value).withOpacity(0.90)),
      home: const HomePage(title: 'Keysight Battery Charge/Discharge System'),
    );
  }
}
