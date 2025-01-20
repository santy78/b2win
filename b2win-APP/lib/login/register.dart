import 'package:b2winai/service/apiService.dart';
import 'package:b2winai/home.dart';
import 'package:flutter/material.dart';

import '../service/AuthService.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color.fromARGB(255, 69, 116, 155),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: referralCodeController,
              decoration: InputDecoration(
                labelText: 'Referral Code (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.card_giftcard),
              ),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _isTermsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      _isTermsAccepted = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Handle terms and conditions link
                    },
                    child: Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color.fromARGB(255, 69, 116, 155),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      _handleRegister();
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 69, 116, 155),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    String email = emailController.text.trim();
    String referralCode = referralCodeController.text.trim();

    if (email.isEmpty) {
      _showDialog(context, 'Error', 'Please enter your email ID.');
      return;
    }

    if (!_isTermsAccepted) {
      _showDialog(context, 'Error',
          'You must accept the Terms and Conditions to proceed.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate registration process
    try {
      final responses =
          await ApiService.register(email, referralCode, 'device_token', "");

      if (responses['statuscode'] == 200) {
        final response = responses['data'];
        final email = response['profile']['email'];
        await AuthService.saveSessionData(
          token: response['access_token'],
          role: response['role_name'],
          email: email,
          refreshToken: response['refresh_token'],
          isLoggedIn: true,
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responses['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
