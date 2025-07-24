import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String? message;
  bool loading = false;

  Future<void> _resetPassword() async {
    setState(() {
      loading = true;
      message = null;
    });

    try {
      final email = emailController.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        message = "Password reset email sent!";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message;
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (message != null)
              Text(
                message!,
                style: TextStyle(color: message!.contains('sent') ? Colors.green : Colors.red),
              ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Enter your email'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : _resetPassword,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
