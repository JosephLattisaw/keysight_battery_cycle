import 'package:flutter/material.dart';
import 'package:keysight_gui/c_api/keysight_c_api.dart';
import 'package:provider/provider.dart';

class InstrumentListView extends StatelessWidget {
  const InstrumentListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<KeysightCAPI>(context, listen: false);
    final keysightConnectionStatus =
        context.select((KeysightCAPI k) => k.keysightConnectionStatus);

    return ListView(
      children: [
        Container(
          color: Colors.white.withOpacity(0.1),
          child: ListTile(
            title: const Text(
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
                child:
                    Text(keysightConnectionStatus ? "Disconnect" : "Connect"),
              ),
              onPressed: () {
                if (keysightConnectionStatus) {
                  backend.disconnectKeysight();
                } else {
                  backend.connectKeysight();
                }
              },
              style: ElevatedButton.styleFrom(
                  primary:
                      keysightConnectionStatus ? Colors.red : Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}
