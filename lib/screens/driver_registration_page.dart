import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jeepway/services/location_service.dart'; // ✅ Location stream service

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController seatSizeController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool isSubmitting = false;

  Future<void> _enableLocationAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      // Save to Firestore
      await FirebaseFirestore.instance.collection('drivers').doc(user.uid).set({
        'name': nameController.text.trim(),
        'city': cityController.text.trim(),
        'route': routeController.text.trim(),
        'seatSize': seatSizeController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'uid': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Request permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      // Get initial position
      Position position = await Geolocator.getCurrentPosition();
      final dbRef = FirebaseDatabase.instance.ref("jeep_positions/${user.uid}");

      await dbRef.set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'nickname': nicknameController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      // ✅ Start live stream after initial push
      await LocationService.startDriverLocationStream();

      // ✅ Navigate to home
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Driver Registration')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nameController, "Name"),
              _buildTextField(cityController, "City"),
              _buildTextField(routeController, "Route"),
              _buildTextField(seatSizeController, "Seat Size"),
              _buildTextField(nicknameController, "Nickname"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : _enableLocationAndSubmit,
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Enable Location & Submit'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
