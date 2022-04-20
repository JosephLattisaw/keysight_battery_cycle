import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keysight_gui/application_bar.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:keysight_gui/screens/profile_sequence/common_profile_sequence.dart';

class AddSequenceTestWidget extends HookWidget {
  AddSequenceTestWidget({Key? key, required this.onSave}) : super(key: key) {
    for (var element in testTypeDescription) {
      assert(element.length == 2);
    }

    for (var element in timeTypeDescription) {
      assert(element.length == 2);
    }

    for (var element in testActionDescriptions) {
      assert(element.length == 2);
    }
  }

  final void Function(int testType, int testAction, double value, int timeType,
      int timeLimit) onSave;

  @override
  Widget build(BuildContext context) {
    final testType = useState(0);
    final testAction = useState(0);
    final value = useState(2.0);
    final timeType = useState(0);
    final timeLimit = useState(20);

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
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Add a Test to a Profile Sequence Step',
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
                                    "Select a Test From the Dropdown to Decide What Test Will Be Preformed During This Step",
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
                                        testTypeDescription.length,
                                        (index) => DropdownMenuItem(
                                          child: Text(testTypeDescription
                                              .elementAt(index)
                                              .elementAt(0)),
                                          value: index,
                                        ),
                                      ),
                                      value: testType.value,
                                      onChanged: (int? value) {
                                        testType.value = value ?? 0;
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
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    testTypeDescription
                                        .elementAt(testType.value)
                                        .elementAt(1),
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
                                  left: 16, top: 8, right: 4),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Specify the Test Action",
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
                                            testActionDescriptions.length,
                                            (index) => DropdownMenuItem(
                                              child: Text(testActionDescriptions
                                                  .elementAt(index)
                                                  .elementAt(0)),
                                              value: index,
                                            ),
                                          ),
                                          value: testAction.value,
                                          onChanged: (int? value) {
                                            testAction.value = value ?? 0;
                                          },
                                          dropdownColor: Colors.blueAccent,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1.4),
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
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        testActionDescriptions
                                            .elementAt(testAction.value)
                                            .elementAt(1),
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
                                        "Specify the Value of the Test Type Above",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      IntrinsicWidth(
                                        child: SpinBox(
                                          value: value.value,
                                          min: 2.0,
                                          max: 4.5,
                                          decimals: 2,
                                          step: 0.1,
                                          onChanged: (v) {
                                            value.value = v;
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
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "All values are in whole units.",
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
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, top: 8, right: 4),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Specify a Time Type",
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
                                            timeTypeDescription.length,
                                            (index) => DropdownMenuItem(
                                              child: Text(timeTypeDescription
                                                  .elementAt(index)
                                                  .elementAt(0)),
                                              value: index,
                                            ),
                                          ),
                                          value: timeType.value,
                                          onChanged: (int? value) {
                                            timeType.value = value ?? 0;
                                          },
                                          dropdownColor: Colors.blueAccent,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black,
                                                  width: 1.4),
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
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        timeTypeDescription
                                            .elementAt(timeType.value)
                                            .elementAt(1),
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
                                        "Specify a Time Limit for the Step (seconds)",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      IntrinsicWidth(
                                        child: SpinBox(
                                          value: timeLimit.value.toDouble(),
                                          min: 20,
                                          max: 2147483647,
                                          decimals: 0,
                                          step: 1,
                                          onChanged: (value) {
                                            timeLimit.value = value.toInt();
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
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        "A minimum of 20 seconds is required for the step to\ncomplete the initial setup procedure.",
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
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            onSave(testType.value, testAction.value,
                                value.value, timeType.value, timeLimit.value);
                            Navigator.of(context).maybePop();
                          },
                          child: const Text("Save"),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
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
