import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:localstore/localstore.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:tracked/constants/localstore_collections.dart';

class LocationTracker extends StatefulWidget {
  const LocationTracker({Key? key}) : super(key: key);

  @override
  State<LocationTracker> createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  final _db = Localstore.instance;
  bool _loading = false;
  bool _tracking = false;
  double _intervalInMinutes = 10;
  String _lastLocationString = '';
  String _lastLocationTsString = '';
  Position? _lastLocation;
  Timer? _timer;

  Future<void> _startTracking() async {
    setState(() {
      _loading = true;
    });
    const _androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Tracking Location",
      notificationText:
          "Background notification for keeping Tracked running in the background",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(
          name: 'background_icon',
          defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    await FlutterBackground.initialize(androidConfig: _androidConfig);
    await FlutterBackground.enableBackgroundExecution();
    await _logPosition();
    setState(() {
      _loading = false;
      _tracking = true;
    });
  }

  Future<void> _stopTracking() async {
    setState(() {
      _loading = true;
    });
    await FlutterBackground.disableBackgroundExecution();
    _timer?.cancel();
    setState(() {
      _loading = false;
      _tracking = false;
    });
  }

  Future<void> _logPosition() async {
    final position = await _determinePosition();
    final id = _db.collection(Collections.positions).doc().id;
    await _db.collection(Collections.positions).doc(id).set(position.toJson());
    _timer = Timer(Duration(minutes: _intervalInMinutes.toInt()), _logPosition);
    setState(() {
      _lastLocation = position;
      _lastLocationString = position.toString();
      _lastLocationTsString = position.timestamp.toString();
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final Position _position = await Geolocator.getCurrentPosition();

    return _position;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          Text(
            _tracking ? 'Tracking' : 'Not Tracking',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Column(children: [
            Text(_lastLocationString),
            Text(_lastLocationTsString)
          ]),
          Column(
            children: [
              Slider(
                value: _intervalInMinutes,
                divisions: 14,
                max: 15,
                min: 1,
                label: _intervalInMinutes.toString(),
                onChanged: (value) {
                  setState(() {
                    _intervalInMinutes = value;
                  });
                },
              ),
              Text(
                  'GPS ping interval: ${_intervalInMinutes.toString()} minutes')
            ],
          ),
          _loading
              ? const CircularProgressIndicator()
              : OutlinedButton(
                  child: Text(
                    _tracking ? 'Stop Tracking' : 'Start Tracking',
                    style:
                        TextStyle(color: _tracking ? Colors.red : Colors.blue),
                  ),
                  onPressed: _tracking ? _stopTracking : _startTracking,
                ),
        ]));
  }
}
