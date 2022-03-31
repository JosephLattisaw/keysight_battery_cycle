import 'package:flutter/material.dart';
import 'package:keysight_gui/screens/profile_sequence/edit_steps_widget_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:keysight_gui/screens/profile_sequence/new_step_widget.dart';
import 'package:keysight_gui/screens/profile_sequence/new_test_widget.dart';

class StepWidgetView extends HookWidget {
  const StepWidgetView({Key? key, required this.value}) : super(key: key);

  final int value;

  @override
  Widget build(BuildContext context) {
    final screen = useState(0);
    final actionDropDownValue = useState(0);

    if (screen.value == 1) {
      return NewStepWidget();
    } else if (screen.value == 2) {
      return NewTestWidget();
    }

    return Column(
      children: [
        Container(
          color: Colors.green,
          child: SizedBox(
            width: 100,
            height: 100,
            child: Text("$value"),
          ),
        ),
        ElevatedButton(onPressed: () {}, child: Text("push")),
        EditStepsWidgetView(
          onStepPressed: () {
            screen.value = 1;
          },
          onTestPressed: () {
            screen.value = 2;
          },
          view: 0,
        )
      ],
    );
  }
}
