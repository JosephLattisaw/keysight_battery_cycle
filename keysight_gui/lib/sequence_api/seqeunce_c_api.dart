import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

class Test extends ffi.Struct {
  @ffi.Uint8()
  external int testType;

  @ffi.Uint8()
  external int testAction;

  @ffi.Double()
  external double value;

  @ffi.Uint8()
  external int timeType;

  @ffi.Uint32()
  external int timeLimit;
}

class Step extends ffi.Struct {
  @ffi.Uint8()
  external int mode;

  @ffi.Uint32()
  external int seconds;

  @ffi.Double()
  external double current;

  @ffi.Double()
  external double voltage;

  external ffi.Pointer<ffi.Pointer<Test>> tests;

  @ffi.Uint32()
  external int testsSize;
}

class Sequence extends ffi.Struct {
  external ffi.Pointer<Utf8> name;

  external ffi.Pointer<Utf8> comments;

  external ffi.Pointer<ffi.Pointer<Step>> steps;

  @ffi.Uint32()
  external int stepsSize;
}

class Sequences extends ffi.Struct {
  external ffi.Pointer<ffi.Pointer<Sequence>> sequences;

  @ffi.Uint32()
  external int size;
}
