import 'package:android_course/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ClockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clock (StatefulWidget)"),
      ),
      body: Center(
        child: DecoratedText(Clock()),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  @override
  State createState() {
    return ClockState();
  }
}

class ClockState extends State<Clock> {
  late String _timeString;
  late Timer _timer;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Text(_timeString, style: TextStyle(fontSize: 16.0));

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  String _formatDateTime(DateTime dateTime) => DateFormat('MM/dd/yyyy hh:mm:ss').format(dateTime);
}
