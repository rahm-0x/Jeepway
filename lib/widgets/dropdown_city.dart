import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CityDropdown extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String?> onCityChanged;

  CityDropdown({required this.selectedCity, required this.onCityChanged});

  @override
  Widget build(BuildContext context) {
    final Map<String, LatLng> cityCoordinates = {
      'Manila': LatLng(14.5995, 120.9842),
      'Cebu': LatLng(10.3157, 123.8854),
      'Davao': LatLng(7.0731, 125.6128),
      'Baguio': LatLng(16.4023, 120.5960),
    };

    return DropdownButton<String>(
      value: selectedCity,
      onChanged: onCityChanged,
      items: cityCoordinates.keys.map<DropdownMenuItem<String>>((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
    );
  }
}
