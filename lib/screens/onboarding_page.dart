// /Users/phoenix/Desktop/jeepway-clean/lib/screens/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String? selectedRole;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController routeController = TextEditingController();
  final TextEditingController seatSizeController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  bool isSubmitting = false;
  String? errorMessage;

  Future<void> saveUserRole(String role, String uid, String email, Map<String, dynamic> extraData) async {
    final data = {
      'role': role,
      'uid': uid, // Explicitly add UID
      'email': email, // Explicitly add email
      'createdAt': FieldValue.serverTimestamp(),
      ...extraData,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      print("✅ Firestore write successful for $uid with role: $role");
    } catch (e, stacktrace) {
      print("❌ Firestore write failed: $e");
      print("📄 Stacktrace: $stacktrace");
    }
  }

  Future<void> _submit() async {
    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      user ??= await FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null);

      if (user == null) {
        setState(() {
          errorMessage = "User authentication failed.";
          isSubmitting = false;
        });
        return;
      }

      final uid = user.uid;
      final email = user.email ?? '';

      final extraData = <String, dynamic>{};

      if (selectedRole == 'Driver') {
        final name = nameController.text.trim();
        final city = cityController.text.trim();
        final route = routeController.text.trim();
        final seatSize = seatSizeController.text.trim();
        final nickname = nicknameController.text.trim();

        if ([name, city, route, seatSize, nickname].any((field) => field.isEmpty)) {
          setState(() {
            isSubmitting = false;
            errorMessage = "Please fill in all driver fields.";
          });
          return;
        }

        extraData.addAll({
          'name': name,
          'city': city,
          'route': route,
          'seatSize': seatSize,
          'nickname': nickname,
        });
      }

      await saveUserRole(selectedRole!, uid, email, extraData); // Pass uid and email here

      Navigator.pushReplacementNamed(
        context,
        selectedRole == 'Rider' ? '/' : '/driver-verification',
      );
    } catch (e) {
      setState(() => errorMessage = "Error saving data: $e");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildDriverForm() {
    return Column(
      children: [
        TextField(controller: nameController, decoration: InputDecoration(labelText: 'Full Name')),
        TextField(controller: cityController, decoration: InputDecoration(labelText: 'City')),
        TextField(controller: routeController, decoration: InputDecoration(labelText: 'Route')),
        TextField(controller: seatSizeController, decoration: InputDecoration(labelText: 'Seat Size')),
        TextField(controller: nicknameController, decoration: InputDecoration(labelText: 'Nickname')),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const Text('Are you a Rider or Driver?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => selectedRole = 'Rider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRole == 'Rider' ? Colors.purple : Colors.grey[300],
                  ),
                  child: const Text('Rider'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => setState(() => selectedRole = 'Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRole == 'Driver' ? Colors.purple : Colors.grey[300],
                  ),
                  child: const Text('Driver'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (selectedRole == 'Driver') _buildDriverForm(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting || selectedRole == null ? null : _submit,
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}