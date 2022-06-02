class Test {
  Test(
      {required this.testType,
      required this.testAction,
      required this.value,
      required this.timeType,
      required this.timeLimit});

  int testType;
  int testAction;
  double value;
  int timeType;
  int timeLimit;
}

class Step {
  Step(
      {required this.mode,
      required this.seconds,
      required this.current,
      required this.voltage,
      required this.tests});

  int mode;
  int seconds;
  double current;
  double voltage;
  List<Test> tests;
}

class Sequence {
  Sequence({required this.name, required this.comments, required this.steps});

  String name;
  String comments;
  List<Step> steps;
}

class Sequences {
  Sequences({required this.sequences});

  List<Sequence> sequences;
}
