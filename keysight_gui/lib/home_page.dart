import 'package:flutter/material.dart';
import 'package:keysight_gui/application_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: const ApplicationBar(),
        preferredSize: AppBar().preferredSize,
      ),
      body: Container(),
    );
  }
}
