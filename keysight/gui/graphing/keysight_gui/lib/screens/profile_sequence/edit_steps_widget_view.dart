import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/profile_sequence/new_step_widget.dart';

class EditStepsWidget extends StatelessWidget {
  const EditStepsWidget({
    Key? key,
    required this.onStepPressed,
    required this.onTestPressed,
  }) : super(key: key);

  final void Function() onStepPressed;
  final void Function() onTestPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                      onPressed: () {
                        onStepPressed();
                      },
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Text("Test"),
                      onPressed: () {
                        onTestPressed();
                      },
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
                      child: Text("Edit"),
                      onPressed: () {},
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Text("Delete"),
                      onPressed: () {},
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Text("Move Up"),
                      onPressed: () {},
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      child: Text("Move Down"),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditStepsWidgetView extends StatelessWidget {
  const EditStepsWidgetView(
      {Key? key,
      required this.onStepPressed,
      required this.view,
      required this.onTestPressed})
      : super(key: key);

  final void Function() onStepPressed;
  final void Function() onTestPressed;
  final int view;

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case 1:
        return NewStepWidget();
    }

    return EditStepsWidget(
      onStepPressed: () {
        onStepPressed();
      },
      onTestPressed: () {
        onTestPressed();
      },
    );
  }
}
