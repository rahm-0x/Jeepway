import 'dart:async'; // Import Timer
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../utils/constants.dart'; // Import the constants for jeepney data

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final PopupController popupController;
  final String selectedCity;

  MapWidget({
    required this.mapController,
    required this.popupController,
    required this.selectedCity,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<LatLng> jeepneyPositions = [];
  Timer? _movementTimer;

  @override
  void initState() {
    super.initState();

    // Initialize jeepney positions at the start of their respective routes
    jeepneyPositions = jeepneyRoutes.map((route) => route[0]).toList();

    // Start jeepney movement
    _startMovingJeepneys();
  }

  @override
  void dispose() {
    _movementTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: cityCoordinates[widget.selectedCity]!,
        initialZoom: 13.0,
        minZoom: 7.0,
        onTap: (_, __) => widget.popupController.hideAllPopups(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        // Update MarkerLayer to display the updated jeepney positions
        MarkerLayer(
          markers: jeepneyPositions
              .asMap()
              .entries
              .map((entry) => Marker(
                    width: 80.0,
                    height: 80.0,
                    point: entry.value, // Display updated jeepney position
                    child: Image.asset(
                      'assets/jeepneyicon.png',
                      width: 40,
                      height: 40,
                    ),
                  ))
              .toList(),
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            markers: jeepneyPositions
                .asMap()
                .entries
                .map((entry) => Marker(
                      width: 80.0,
                      height: 80.0,
                      point: entry.value,
                      key: Key('marker_${entry.key}'),
                      child: Image.asset(
                        'assets/jeepneyicon.png',
                        width: 40,
                        height: 40,
                      ),
                    ))
                .toList(),
            popupController: widget.popupController,
            popupDisplayOptions: PopupDisplayOptions(
              builder: (BuildContext context, Marker marker) {
                int index = jeepneyPositions
                    .indexWhere((position) => position == marker.point);

                if (index >= 0 && index < jeepneyDetails.length) {
                  Map<String, dynamic> details = jeepneyDetails[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Route Number: ${details['routeNumber']}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
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
      ],
    );
  }
}
