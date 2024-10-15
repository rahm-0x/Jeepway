import 'package:latlong2/latlong.dart';

final Map<String, LatLng> cityCoordinates = {
  'Manila': LatLng(14.5995, 120.9842),
  'Cebu': LatLng(10.3157, 123.8854),
  'Davao': LatLng(7.0731, 125.6128),
  'Baguio': LatLng(16.4023, 120.5960),
};

// Example jeepney routes
final List<List<LatLng>> jeepneyRoutes = [
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

// Example jeepney details
final List<Map<String, dynamic>> jeepneyDetails = [
  {'routeNumber': '17B', 'seats': 20, 'availableSeats': 10},
  {'routeNumber': '23C', 'seats': 25, 'availableSeats': 8},
];
