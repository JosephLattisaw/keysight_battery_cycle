import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/material.dart';

class NewStepWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final actionDropDownValue = useState(0);

    return Column(
      children: [
        Container(
          color: Colors.green,
          child: SizedBox(height: 100, width: 100),
        ),
        Text("Create a New Step in the Profile Sequence:"),
        Text("Step:"),
        Row(
          children: [
            Text("Action:"),
            DropdownButton(
              value: actionDropDownValue.value,
              items: [
                DropdownMenuItem(
                  child: Text("Precharge"),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text("Charge"),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text("Discharge"),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text("Rest"),
                  value: 3,
                ),
              ],
              onChanged: (int? value) {
                actionDropDownValue.value = value ?? 0;
              },
            )
          ],
        ),
        Row(
          children: [
            Text("Duration:"),
            Expanded(
              child: SpinBox(
                min: 0,
                max: 17500,
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
                  labelText: "Hours",
                ),
              ),
            ),
            Expanded(
              child: SpinBox(
                min: 0,
                max: 60,
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
                  labelText: "Minutes",
                ),
              ),
            ),
            Expanded(
              child: SpinBox(
                min: 1,
                max: 60,
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
                  labelText: "Seconds",
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text("Current Limit:"),
            Expanded(
              child: SpinBox(
                min: 0,
                max: 60,
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
                  labelText: "Current Limit",
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text("Voltage Limit:"),
            Expanded(
              child: SpinBox(
                min: 2.0,
                max: 4.5,
                value: 2.0,
                decimals: 1,
                spacing: 24,
                step: 0.1,
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
                  labelText: "Voltage Limit",
                ),
              ),
            ),
          ],
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter Any Additional Comments for the Step",
          ),
        ),
      ],
    );
  }
}
