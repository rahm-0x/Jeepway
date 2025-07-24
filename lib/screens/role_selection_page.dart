import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _setRole(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("❌ No user is authenticated.");
      return;
    }

    final uid = user.uid;
    final email = user.email;

    print("👉 Attempting to write role for $uid");

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

      print("✅ Successfully set role: $role for $uid");

      if (role == 'Rider') {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        Navigator.pushReplacementNamed(context, '/driver-verification');
      }
    } catch (e) {
      print("❌ Firestore write failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Are you a Rider or Driver?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _setRole(context, 'Rider'),
              child: const Text('I am a Rider'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _setRole(context, 'Driver'),
              child: const Text('I am a Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
