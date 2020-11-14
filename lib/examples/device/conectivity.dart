import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConnectivityRepository with ChangeNotifier {
  final _connectivity = Connectivity();
  ConnectivityResult _connectivityResult = ConnectivityResult.wifi;
  StreamSubscription _subscription;

  ConnectivityRepository() {
    _subscription = _connectivity.onConnectivityChanged.listen((event) {
      _connectivityResult = event;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  ConnectivityResult get status => _connectivityResult;
}

class ConnectivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityRepository>(
      builder: (context, connectivity, _) {
        final notificationHeight =
            connectivity.status == ConnectivityResult.none ? 40.0 : 0.0;
        return Scaffold(
          appBar: AppBar(
            title: Text('Connectivity example'),
          ),
          body: Stack(children: [
            Container(
              child: Center(
                child: Text(
                    'Connection status is: ${connectivity.status.toString()}'),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                elevation: 8.0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  color: Colors.red,
                  height: notificationHeight,
                  child: Center(
                      child: Text(
                    'No internet connection',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  )),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
