import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // You can add Firebase authentication here later.
                Navigator.pop(context, true); // Signals successful login
              },
              child: Text('Login'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup'); // ✅ Use named route
              },
              child: Text('Signup'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/forgot'); // ✅ Go to forgot password screen
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
