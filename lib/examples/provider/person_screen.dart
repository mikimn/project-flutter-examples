import 'package:android_course/examples/provider/person_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Person(name: 'John', age: 21),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Person Provider Example'),
        ),
        body: Center(
          // A consumer for our person
          child: Consumer<Person>(
            builder: (context, person, _) => Text(
                'My name is ${person.name}, and I am ${person.age} years old'),
          ),
        ),
        // A different consumer!
        floatingActionButton: Consumer<Person>(
          builder: (context, person, _) => FloatingActionButton.extended(
            label: Text('Increase age'),
            icon: Icon(Icons.add),
            onPressed: () => person.increaseAge(),
          ),
        ),
      ),
    );
  }
}
