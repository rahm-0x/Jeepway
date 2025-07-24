import 'package:flutter/material.dart';

class DriverVerificationPage extends StatelessWidget {
  const DriverVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Verification In Progress...',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'To get started, please complete the registration form.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/driver-registration');
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
