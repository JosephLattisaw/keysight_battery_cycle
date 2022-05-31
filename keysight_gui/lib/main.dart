import 'package:flutter/material.dart';
import 'package:keysight_gui/home_page.dart';
import 'package:provider/provider.dart';
import 'package:keysight_gui/keysight_c_api.dart' as c_api;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color(Colors.black.value).withOpacity(0.86),
        ),
        home: HomePage(),
      ),
    );
  }
}
