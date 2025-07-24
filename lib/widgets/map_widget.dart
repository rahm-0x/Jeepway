import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart'; // Still needed for cityCoordinates

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final PopupController popupController;
  final String selectedCity;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.popupController,
    required this.selectedCity,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? userPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('jeep_positions');

    return Stack(
      children: [
        StreamBuilder<DatabaseEvent>(
          stream: dbRef.onValue,
          builder: (context, snapshot) {
            List<Marker> jeepMarkers = [];

            if (snapshot.hasData &&
                snapshot.data!.snapshot.value != null) {
              final data = Map<String, dynamic>.from(
                  snapshot.data!.snapshot.value as Map);

              data.forEach((_, value) {
                final jeep = Map<String, dynamic>.from(value);
                if (jeep.containsKey('latitude') &&
                    jeep.containsKey('longitude')) {
                  final lat = double.tryParse(jeep['latitude'].toString());
                  final lng = double.tryParse(jeep['longitude'].toString());
                  if (lat != null && lng != null) {
                    jeepMarkers.add(
                      Marker(
                        point: LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: Image.asset('assets/jeepneyicon.png'),
                      ),
                    );
                  }
                }
              });
            }

            return FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: cityCoordinates[widget.selectedCity]!,
                maxZoom: 30.0,
                minZoom: 1.0,
                onTap: (_, __) => widget.popupController.hideAllPopups(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: jeepMarkers),
                if (userPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: userPosition!,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            child: Icon(Icons.my_location),
            onPressed: () {
              if (userPosition != null) {
                widget.mapController.move(userPosition!, 15.0);
              }
            },
          ),
        ),
      ],
    );
  }
}
