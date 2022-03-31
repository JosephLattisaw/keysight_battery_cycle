import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinbox/material.dart';

class NewTestWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final actionDropDownValue = useState(0);

    return Column(
      children: [
        Container(
          color: Colors.green,
          child: SizedBox(height: 100, width: 100),
        ),
        Text("Create a New Test in the current step:"),
        Row(
          children: [
            Text("Action:"),
            DropdownButton(
              value: actionDropDownValue.value,
              items: [
                DropdownMenuItem(
                  child: Text("Voltage >="),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text("Voltage <="),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text("Current >="),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text("Current <="),
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
            Text("Current:"),
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
          ],
        ),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter Any Additional Comments for the Test",
          ),
        ),
      ],
    );
  }
}
