import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:keysight_gui/keysight_c_api.dart';
import 'package:provider/provider.dart';

class SystemSafety extends HookWidget {
  double minYellowVoltage = 0;
  double minRedVoltage = 0;
  double maxYellowVoltage = 0;
  double maxRedVoltage = 0;
  double maxRedCurrent = 0;

  @override
  Widget build(BuildContext context) {
    final backend = Provider.of<KeysightCAPI>(context, listen: false);
    minYellowVoltage = backend.minYellowVoltage;
    minRedVoltage = backend.minRedVoltage;
    maxYellowVoltage = backend.maxYellowVoltage;
    maxRedVoltage = backend.maxRedVoltage;
    maxRedCurrent = backend.maxRedCurrent;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Edit System Safety Limits',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          color: Colors.black,
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 8,
                          right: 4,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            border: Border.all(
                              width: 2.0,
                              style: BorderStyle.solid,
                              color: Colors.grey.shade800,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: const Offset(
                                      0, 3) // changes position of shadow
                                  ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Minimum Voltage Safety Limit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 8),
                                IntrinsicWidth(
                                  child: SpinBox(
                                    value: minYellowVoltage,
                                    min: 0,
                                    max: 10,
                                    step: 0.1,
                                    decimals: 2,
                                    onChanged: (value) {
                                      minYellowVoltage = value;
                                    },
                                    incrementIcon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                    decrementIcon: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1.4),
                                      ),
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      hintText: "Centered Text",
                                      filled: true,
                                      fillColor: Colors.yellow,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IntrinsicWidth(
                                  child: SpinBox(
                                    value: minRedVoltage,
                                    min: 0.00,
                                    max: 10.00,
                                    step: 0.1,
                                    decimals: 2,
                                    onChanged: (value) {
                                      minRedVoltage = value;
                                    },
                                    incrementIcon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                    decrementIcon: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1.4),
                                      ),
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      hintText: "Centered Text",
                                      filled: true,
                                      fillColor: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "<Yellow Limit> Will Only Indicate a Warning if Crossed\n<Red Limit> Will Shut Off Test",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 16.0,
                          top: 8.0,
                          left: 4,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            border: Border.all(
                              width: 2.0,
                              style: BorderStyle.solid,
                              color: Colors.grey.shade800,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Maximum Voltage Safety Limit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 8),
                                IntrinsicWidth(
                                  child: SpinBox(
                                    value: maxYellowVoltage,
                                    min: 0.0,
                                    max: 10.0,
                                    decimals: 2,
                                    step: 0.1,
                                    onChanged: (value) {
                                      maxYellowVoltage = value;
                                    },
                                    incrementIcon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                    decrementIcon: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1.4),
                                      ),
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      hintText: "Centered Text",
                                      filled: true,
                                      fillColor: Colors.yellow,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IntrinsicWidth(
                                  child: SpinBox(
                                    value: maxRedVoltage,
                                    min: 0.0,
                                    max: 10.0,
                                    decimals: 2,
                                    step: 0.1,
                                    onChanged: (value) {
                                      maxRedVoltage = value;
                                    },
                                    incrementIcon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                    decrementIcon: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                    ),
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1.4),
                                      ),
                                      border: OutlineInputBorder(),
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      hintText: "Centered Text",
                                      filled: true,
                                      fillColor: Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "<Yellow Limit> Will Only Indicate a Warning if Crossed\n<Red Limit> Will Shut Off Test",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        border: Border.all(
                          width: 2.0,
                          style: BorderStyle.solid,
                          color: Colors.grey.shade800,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          children: [
                            const Text(
                              "Maximum Current Safety Limit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 8),
                            IntrinsicWidth(
                              child: SpinBox(
                                value: maxRedCurrent,
                                min: 0.0,
                                max: 10.0,
                                decimals: 2,
                                step: 0.1,
                                onChanged: (value) {
                                  maxRedCurrent = value;
                                },
                                incrementIcon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                decrementIcon: const Icon(
                                  Icons.remove,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.4),
                                  ),
                                  border: OutlineInputBorder(),
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  hintText: "Centered Text",
                                  filled: true,
                                  fillColor: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "<Red Limit> Will Shut Off Test\nValue is absolute (-/+)",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      backend.setSafetyLimits(minYellowVoltage, minRedVoltage,
                          maxYellowVoltage, maxRedVoltage, maxRedCurrent);
                    },
                    child: const Text("Save"),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                  /*const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Reset to Default"),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),*/
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}