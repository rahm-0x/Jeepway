import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator for user location
import '../utils/constants.dart'; // Import the constants for jeepney data

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final PopupController popupController;
  final String selectedCity;

  const MapWidget({super.key, 
    required this.mapController,
    required this.popupController,
    required this.selectedCity,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<LatLng> jeepneyPositions = [];
  LatLng? userPosition; // Store user's current location
  Timer? _movementTimer;

  @override
  void initState() {
    super.initState();

    jeepneyPositions = jeepneyRoutes.map((route) => route[0]).toList();
    _startMovingJeepneys();
    _getUserLocation();
  }

  @override
  void dispose() {
    _movementTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Request location permissions and get the user's location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userPosition = LatLng(position.latitude, position.longitude);
    });
  }

  void _startMovingJeepneys() {
    _movementTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        for (int i = 0; i < jeepneyRoutes.length; i++) {
          LatLng currentPosition = jeepneyPositions[i];
          int nextIndex = (jeepneyRoutes[i].indexOf(currentPosition) + 1) %
              jeepneyRoutes[i].length;
          jeepneyPositions[i] = jeepneyRoutes[i][nextIndex];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: cityCoordinates[widget.selectedCity]!,
            maxZoom: 30.0,
            minZoom: 1.0,
            onTap: (_, __) => widget.popupController.hideAllPopups(),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: jeepneyPositions
                  .map((position) => Marker(
                        point: position,
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          // Replaced 'builder' with 'child'
                          'assets/jeepneyicon.png',
                        ),
                      ))
                  .toList(),
            ),
            PopupMarkerLayerWidget(
              options: PopupMarkerLayerOptions(
                markers: jeepneyPositions
                    .map((position) => Marker(
                          point: position,
                          width: 40,
                          height: 40,
                          key: Key(
                              'marker_${jeepneyPositions.indexOf(position)}'),
                          child: Image.asset(
                            // Replaced 'builder' with 'child'
                            'assets/jeepneyicon.png',
                          ),
                        ))
                    .toList(),
                popupController: widget.popupController,
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) {
                    int index = jeepneyPositions.indexOf(marker.point);

                    if (index >= 0 && index < jeepneyDetails.length) {
                      Map<String, dynamic> details = jeepneyDetails[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Route Number: ${details['routeNumber']}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text('Total Seats: ${details['seats']}'),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            if (userPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userPosition!,
                    child: Icon(
                      // Replaced 'builder' with 'child'
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
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
