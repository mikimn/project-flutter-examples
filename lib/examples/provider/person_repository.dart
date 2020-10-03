import 'package:flutter/foundation.dart';

class Person with ChangeNotifier {
  Person({this.name, this.age});

  final String name;
  int age;

  // when `notifyListeners` is called, it will invoke
  // any callbacks that have been registered with an instance of this object
  // `addListener`.
  void increaseAge() {
    this.age++;
    notifyListeners();
  }
}
