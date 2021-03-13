import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class LocationRepository {
  Location _location = new Location();
  bool serviceEnabled;
  PermissionStatus permissionStatus;
  late StreamSubscription _subscription;

  StreamController<LocationData> _streamController =
      StreamController<LocationData>();

  static LocationRepository stub() {
    return LocationRepository._(false, PermissionStatus.denied);
  }

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
    }

    return LocationRepository._(_serviceEnabled, _permissionGranted);
  }

  LocationRepository._(this.serviceEnabled, this.permissionStatus) {
    _subscription = _location.onLocationChanged.listen((event) {
      print('new location: $event');
      _streamController.sink.add(event);
    });

    _location.changeSettings(
      accuracy: LocationAccuracy.powerSave,
      interval: 10000, // Every 10 seconds
    );
  }

  Stream<LocationData> get locationData => _streamController.stream;

  void dispose() {
    _subscription.cancel();
    _streamController.close();
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

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationRepository>(
      builder: (context, repository, _) => StreamBuilder<LocationData>(
          stream: repository.locationData,
          builder: (context, snapshot) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Location Example'),
              ),
              body: Container(
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: _kGooglePlex,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    // final location = repository?.locationData;
                    // controller.moveCamera(CameraUpdate.newLatLng(
                    //     LatLng(location?.latitude ?? 0, location?.longitude ?? 0)));
                  },
                ),
              ),
              bottomSheet: Material(
                elevation: 6.0,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Location is (${snapshot.data?.latitude ?? '-'}, '
                      '${snapshot.data?.longitude ?? '-'}), '
                      'Heading = ${snapshot.data?.heading ?? '-'}'),
                ),
              ),
            );
          }),
    );
  }
}
