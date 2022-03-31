import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';

class AddSequenceStepWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final actionComboSelection = useState(0);

    return Scaffold(
      appBar: PreferredSize(
        child: const ApplicationBar(),
        preferredSize: AppBar().preferredSize,
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.blue,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Add a Step to the Profile Sequence:",
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Mode:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          border: Border.all(color: Colors.black38, width: 0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.57),
                              blurRadius: 5,
                            )
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: DropdownButton(
                          value: actionComboSelection.value,
                          items: [
                            DropdownMenuItem(child: Text("Charge"), value: 0),
                            DropdownMenuItem(
                                child: Text("Discharge"), value: 1),
                            DropdownMenuItem(child: Text("Rest"), value: 2),
                          ],
                          onChanged: (int? value) {
                            actionComboSelection.value = value ?? 0;
                          },
                          style: TextStyle(color: Colors.white),
                          underline: Container(), //empty line
                          dropdownColor: Colors.grey.shade800,
                          focusColor: Colors.black,
                          iconEnabledColor: Colors.white,
                          icon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "This specifies whether the channel is sinking current, sourcing current, or resting while the output is disconnected.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    Text("Duration"),
                    Text("Seconds"),
                  ],
                ),
                Text(
                  "Maximum Allowable Step Time in Seconds. Note that the step can terminate earlier than the duration due to a test condition being met.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    Text("Target Current (Current Limit) <CC>"),
                    Text("Amps"),
                  ],
                ),
                Text(
                  "The Current Limit for this Step. The channel will limit the current to this value.\n In charge mode <CC> refers to the current source limit. In discharge mode, the <CC> refers to the current sink limit. ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    Text("Target Voltage (Voltage Limit) <CV>"),
                    Text("Volts"),
                  ],
                ),
                Text(
                  "The Voltage Limit for this Step. The channel will limit the voltage to this value.",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(),
                          hintText: "Include any additional comments here.",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Save"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
