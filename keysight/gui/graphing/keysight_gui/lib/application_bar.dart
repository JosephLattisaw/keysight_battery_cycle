import 'package:flutter/material.dart';

class ApplicationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appBarHeight = AppBar().preferredSize.height;

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Keysight Battery Charge/Discharge System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
          Image.asset(
            'assets/ibeos_logo.png',
            fit: BoxFit.contain,
            height: appBarHeight * 0.6,
          ),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
