import 'package:flutter/material.dart';
import 'package:keysight_gui/home_page.dart';
import 'package:keysight_gui/keysight_c_api.dart' as c_api;
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => c_api.KeysightCAPI(),
          lazy: false,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor:
                Color(Colors.black.value).withOpacity(0.86)),
        home: HomePage(),
      ),
    );
  }
}
