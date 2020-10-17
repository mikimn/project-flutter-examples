import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FutureBuilderExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FutureBuilder Example"),
      ),
      body: Center(child: FutureBuilderExample()),
    );
  }
}

class FutureBuilderExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FutureBuilderExampleState();
}

class _FutureBuilderExampleState extends State<FutureBuilderExample> {
  Future<String> _calculation = Future<String>.delayed(
    Duration(seconds: 2),
    () => 'Data Loaded',
  );

  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2,
      textAlign: TextAlign.center,
      child: FutureBuilder<String>(
        future: _calculation, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Result: ${snapshot.data}'),
              )
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = <Widget>[
              SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
