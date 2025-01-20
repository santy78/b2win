import 'dart:math';

import 'package:b2winai/service/apiService.dart';
import 'package:b2winai/login/otpVerify.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart'; // Import url_launcher for hyperlink functionality

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey =
      GlobalKey<FormBuilderState>(); // Form key to validate form fields
  final TextEditingController _emailController = TextEditingController();
  bool isButtonEnabled = false; // Track button state
  bool isLoading = false; // Loading state
  @override
  void initState() {
    super.initState();

    // Add listener to email field controller
    _emailController.addListener(_checkEmailField);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Method to check if email field is non-empty and valid
  void _checkEmailField() {
    setState(() {
      final email = _emailController.text;
      isButtonEnabled =
          email.isNotEmpty && _formKey.currentState?.validate() == true;
    });
  }

  Future<void> _sendResetCode(String email) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await ApiService.forgotPasswordResetCode(email);

      if (response['statuscode'] == 200) {
        // Handle success, navigate to the OTP verification page
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpVerificationPage(email: email, type: 'password_reset')));
      } else {
        // Show an error message if the API call fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send code: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forgot Password'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0), // General padding for the form
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Align content to center
            children: <Widget>[
              const Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "Just enter your email, and we’ll help you get it back!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20), // Space between text and form

              Center(
                child: Image.asset(
                  'assets/images/forgot_password.png', // Replace with your image path
                  height: 250, // Adjust the height as needed
                ),
              ),
              const SizedBox(height: 20),

              // Email field
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Semantics(
                        label: 'Email Field',
                        hint: 'Enter your email.',
                        textField: true,
                        child: FormBuilderTextField(
                          controller: _emailController, // Add the controller
                          name: 'email',
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            prefixIcon: const Icon(
                              Icons.email, // Email icon
                              color: Colors
                                  .blue, // Optional: Change the color to blue for attractiveness
                              size: 24, // Adjust the size of the icon
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                                errorText: 'Please enter your email'),
                            FormBuilderValidators.email(
                                errorText: 'Enter a valid email'),
                          ]),
                        ),
                      ),
                    ),

                    // Send Code button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: isButtonEnabled
                                    ? () {
                                        if (_formKey.currentState
                                                ?.saveAndValidate() ??
                                            false) {
                                          final email = _formKey
                                              .currentState?.value['email'];
                                          _sendResetCode(
                                              email); // Call API to send reset code
                                        }
                                      }
                                    : null, // Disable button if email is invalid
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: isButtonEnabled
                                      ? Colors.blue
                                      : Colors
                                          .grey, // Disable button color change
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: const Text('Send OTP'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Footer with "Remember Password? Login"
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Remember Password? ',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Handle login tap
                              Navigator.pop(
                                  context); // Navigate back to the login page
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
