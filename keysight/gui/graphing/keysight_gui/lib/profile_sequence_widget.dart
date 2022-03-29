import 'package:flutter/material.dart';
import 'package:keysight_gui/sequence_list_view.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_spinbox/cupertino.dart';

class ProfileSequenceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
              child: SequenceListView(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter Name of Sequence",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "C Rating (A)",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "Over Voltage (V)",
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Enter Serial Number of Cell",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "Capacity (Ah)",
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: SpinBox(
                            min: 0,
                            max: 50,
                            value: 15,
                            spacing: 24,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: const EdgeInsets.only(
                                left: 0,
                                bottom: 20,
                                right: 0,
                                top: 20,
                              ),
                              hintText: "hint",
                              labelText: "Under Voltage (V)",
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Include any additional comments here.",
                      ),
                    ),
                    Spacer(),
                    Text(
                      "The sequence is empty. Use Create New Step to add a step.",
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.black,
                          child: Column(
                            children: [
                              Text(
                                "Create New",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Test"),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          color: Colors.black,
                          child: Column(
                            children: [
                              Text(
                                "Selection",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      child: Text("Step"),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
