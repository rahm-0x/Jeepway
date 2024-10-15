import 'package:flutter/material.dart';
import 'screens/home_page.dart'; // Import the correct file for JeepwayHomePage

void main() {
  runApp(JeepwayApp());
}

class JeepwayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JeepwayHomePage(), // This is now correctly imported
    );
  }
}
