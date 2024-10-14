import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

void main() {
  runApp(JeepwayApp());
}

class JeepwayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeepway',
      home: JeepwayHomePage(),
    );
  }
}

class JeepwayHomePage extends StatefulWidget {
  @override
  _JeepwayHomePageState createState() => _JeepwayHomePageState();
}

class _JeepwayHomePageState extends State<JeepwayHomePage> {
  // Default city is Cebu for this demo
  String _selectedCity = 'Cebu';

  // Create a MapController to control the map programmatically
  final MapController _mapController = MapController();

  // Create a PopupController for displaying info popups
  final PopupController _popupController = PopupController();

  // Coordinates for each city
  final Map<String, LatLng> _cityCoordinates = {
    'Manila': LatLng(14.5995, 120.9842),
    'Cebu': LatLng(10.3157, 123.8854), // Center of Cebu
    'Davao': LatLng(7.0731, 125.6128),
    'Baguio': LatLng(16.4023, 120.5960),
  };

  // Example jeepney routes extracted from the website
  final List<List<LatLng>> _jeepneyRoutes = [
    [
      LatLng(10.3157, 123.8854), // Cebu City
      LatLng(10.3175, 123.8910), // Mango Avenue
      LatLng(10.3214, 123.8938), // Fuente Osmeña
      LatLng(10.3271, 123.9117), // Mabolo Church
      LatLng(10.3375, 123.9188), // Talamban Terminal
    ],
    [
      LatLng(10.3051, 123.8850), // South Road Properties (SRP)
      LatLng(10.3080, 123.8900),
      LatLng(10.3105, 123.8955),
      LatLng(10.3150, 123.9000),
    ],
  ];

  // Jeepney mock data
  final List<Map<String, dynamic>> _jeepneyDetails = [
    {'routeNumber': '17B', 'seats': 20, 'availableSeats': 10}, // First route
    {'routeNumber': '23C', 'seats': 25, 'availableSeats': 8}, // Second route
  ];

  // Jeepney positions
  List<LatLng> _jeepneyPositions = [];

  // Timer for simulating movement
  Timer? _movementTimer;

  @override
  void initState() {
    super.initState();

    // Initialize jeepney positions at the start of their respective routes
    _jeepneyPositions = _jeepneyRoutes.map((route) => route[0]).toList();

    // Start moving jeepneys
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
        for (int i = 0; i < _jeepneyRoutes.length; i++) {
          // Move each jeepney to the next point in its route
          LatLng currentPosition = _jeepneyPositions[i];
          int nextIndex = (_jeepneyRoutes[i].indexOf(currentPosition) + 1) %
              _jeepneyRoutes[i].length;
          _jeepneyPositions[i] = _jeepneyRoutes[i][nextIndex];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Jeepway',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Drop-down menu below the header
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedCity,
              onChanged: (String? newCity) {
                setState(() {
                  _selectedCity = newCity!;
                  _mapController.move(_cityCoordinates[_selectedCity]!, 13.0);
                });
              },
              items: _cityCoordinates.keys
                  .map<DropdownMenuItem<String>>((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
            ),
          ),

          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _cityCoordinates[_selectedCity]!,
                initialZoom: 13.0,
                minZoom: 7.0,
                onTap: (_, __) => _popupController
                    .hideAllPopups(), // Hide popups when the map is tapped
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _jeepneyPositions
                      .asMap()
                      .entries
                      .map((entry) => Marker(
                            width: 80.0,
                            height: 80.0,
                            point: entry.value,
                            child: Image.asset(
                              'assets/jeepneyicon.png', // Use your custom PNG image
                              width: 10,
                              height: 10,
                            ),
                          ))
                      .toList(),
                ),
                PopupMarkerLayerWidget(
                  options: PopupMarkerLayerOptions(
                    markers: _jeepneyPositions
                        .asMap()
                        .entries
                        .map((entry) => Marker(
                              width: 10.0,
                              height: 10.0,
                              point: entry.value,
                              key: Key(
                                  'marker_${entry.key}'), // Assign a unique key for each marker
                              child: Image.asset(
                                'assets/jeepneyicon.png', // Use your custom PNG image
                                width: 10,
                                height: 10,
                              ),
                            ))
                        .toList(),
                    popupController: _popupController,
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: (BuildContext context, Marker marker) {
                        // Find the corresponding jeepney by its position
                        int index = _jeepneyPositions
                            .indexWhere((position) => position == marker.point);

                        // Check if a valid index is found
                        if (index >= 0 && index < _jeepneyDetails.length) {
                          Map<String, dynamic> details = _jeepneyDetails[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      'Route Number: ${details['routeNumber']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Total Seats: ${details['seats']}'),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // If no valid index is found, return an empty container
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
