import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static StreamSubscription<Position>? _subscription;

  static Future<void> startDriverLocationStream() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dbRef = FirebaseDatabase.instance.ref('driver_locations/${user.uid}');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) return;
    }

    _subscription?.cancel(); // avoid duplicates
    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      dbRef.update({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  static void stopStream() {
    _subscription?.cancel();
  }
}
