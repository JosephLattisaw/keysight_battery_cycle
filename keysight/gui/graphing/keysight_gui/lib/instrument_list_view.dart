import 'package:flutter/material.dart';

class InstrumentListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: Colors.white.withOpacity(0.1),
          child: ListTile(
            title: Text(
              "Keysight BT2203A Series Charge-Discharge System",
              style: TextStyle(color: Colors.white),
            ),
            leading: Image.asset(
              'assets/BT2202A.png',
              fit: BoxFit.contain,
              width: 70,
            ),
            trailing: ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Connect"),
              ),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white.withOpacity(0.2),
          child: ListTile(
            title: Text(
              "Keysight DAQ970A Data Acquisition System",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            leading: Image.asset(
              'assets/DAQ970A.png',
              fit: BoxFit.contain,
              width: 70,
            ),
            trailing: ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Connect"),
              ),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
