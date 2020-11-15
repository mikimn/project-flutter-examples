import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationRepository with ChangeNotifier {
  Location _location = new Location();
  bool serviceEnabled;
  PermissionStatus permissionStatus;
  LocationData _locationData;
  StreamSubscription _subscription;

  static Future<LocationRepository> getRepository() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    Location location = new Location();

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == PermissionStatus.granted ||
          _permissionGranted == PermissionStatus.grantedLimited) {
        await location.changeSettings();
      }
    }

    return LocationRepository._(_serviceEnabled, _permissionGranted);
  }

  LocationRepository._(this.serviceEnabled, this.permissionStatus) {
    _subscription = _location.onLocationChanged.listen((event) {
      _locationData = event;
      print('new location: $event');
      notifyListeners();
    });
  }

  LocationData get locationData => _locationData;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationRepository>(
      builder: (context, repository, _) => Scaffold(
        appBar: AppBar(
          title: Text('Location Example'),
        ),
        body: Container(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // final location = repository?.locationData;
              // controller.moveCamera(CameraUpdate.newLatLng(
              //     LatLng(location?.latitude ?? 0, location?.longitude ?? 0)));
            },
          ),
        ),
        bottomSheet: Card(
          child:
              Text('Location is (${repository?.locationData?.latitude ?? '-'}, '
                  '${repository?.locationData?.longitude ?? '-'}), '
                  'Heading = ${repository?.locationData?.heading ?? '-'}'),
        ),
      ),
    );
  }
}
