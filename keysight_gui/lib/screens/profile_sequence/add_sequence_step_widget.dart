import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:keysight_gui/screens/profile_sequence/common_profile_sequence.dart';

class AddSequenceStepWidget extends HookWidget {
  const AddSequenceStepWidget(
      {Key? key,
      required this.onSave,
      this.editing = false,
      this.initialMode = 0,
      this.initialDurationSeconds = 1,
      this.initialCurrentLimit = 0.1,
      this.initialVoltageLimit = 2.0})
      : super(key: key);

  final void Function(int mode, int seconds, double current, double voltage)
      onSave;

  final int initialMode;
  final int initialDurationSeconds;
  final double initialCurrentLimit;
  final double initialVoltageLimit;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final modeSelection = useState(initialMode);
    final durationSeconds = useState(initialDurationSeconds);
    final currentLimit = useState(initialCurrentLimit);
    final voltageLimit = useState(initialVoltageLimit);

    return Scaffold(
      appBar: PreferredSize(
        child: const ApplicationBar(),
        preferredSize: AppBar().preferredSize,
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  editing
                      ? 'Edit a Step to a Profile Sequence'
                      : 'Add a Step to a Profile Sequence',
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
            Expanded(
              child: Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 8.0,
                        right: 16.0,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text(
                                    "Select a Mode From the Dropdown to Decide What Action Will Be Taken During This Step",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  IntrinsicWidth(
                                    child: DropdownButtonFormField(
                                      items: List.generate(
                                        modeDescription.length,
                                        (index) => DropdownMenuItem(
                                          child: Text(
                                              modeDescription.elementAt(index)),
                                          value: index,
                                        ),
                                      ),
                                      value: modeSelection.value,
                                      onChanged: (int? value) {
                                        modeSelection.value = value ?? 0;
                                      },
                                      dropdownColor: Colors.blueAccent,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black, width: 1.4),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        filled: true,
                                        fillColor: Colors.blueAccent,
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "This specifies whether the channel is sinking current, sourcing current, or resting.",
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        top: 8.0,
                        right: 16.0,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  const Text(
                                    "Specify the Duration. (The Maximum Allowable Step Time in Seconds)",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 8),
                                  IntrinsicWidth(
                                    child: SpinBox(
                                      value: durationSeconds.value.toDouble(),
                                      min: 1,
                                      max: 2147483647,
                                      step: 1.0,
                                      decimals: 0,
                                      onChanged: (value) {
                                        durationSeconds.value = value.toInt();
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
                                            color: Colors.black,
                                            width: 1.4,
                                          ),
                                        ),
                                        border: OutlineInputBorder(),
                                        hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        hintText: "Centered Text",
                                        filled: true,
                                        fillColor: Colors.blue,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Note: that the step can terminate earlier than the duration due to a test condition being met.",
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                        "Specify the Current Limit for the Step <CC> (Amps)",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const SizedBox(height: 8),
                                      IntrinsicWidth(
                                        child: SpinBox(
                                          value: currentLimit.value,
                                          min: 0.01,
                                          max: 6.25,
                                          step: 0.1,
                                          decimals: 2,
                                          onChanged: (value) {
                                            currentLimit.value = value;
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
                                                  color: Colors.black,
                                                  width: 1.4),
                                            ),
                                            border: OutlineInputBorder(),
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            hintText: "Centered Text",
                                            filled: true,
                                            fillColor: Colors.blue,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "In charge mode, this refers to the current source limit.\n In discharge mode, this refers to the current sink limit.",
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontStyle: FontStyle.italic,
                                        ),
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
                                        "Specify the Voltage Limit for the Step <CV> (Volts)",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const SizedBox(height: 8),
                                      IntrinsicWidth(
                                        child: SpinBox(
                                          value: voltageLimit.value,
                                          min: 2.0,
                                          max: 4.5,
                                          decimals: 2,
                                          step: 0.1,
                                          onChanged: (value) {
                                            voltageLimit.value = value;
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
                                                  color: Colors.black,
                                                  width: 1.4),
                                            ),
                                            border: OutlineInputBorder(),
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            hintText: "Centered Text",
                                            filled: true,
                                            fillColor: Colors.blue,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "The channel will limit the voltage to this value.",
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontStyle: FontStyle.italic,
                                        ),
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            onSave(modeSelection.value, durationSeconds.value,
                                currentLimit.value, voltageLimit.value);
                            Navigator.of(context).maybePop();
                          },
                          child: const Text("Save"),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          child: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(primary: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
