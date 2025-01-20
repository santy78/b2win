import 'package:b2winai/service/AuthService.dart';
import 'package:b2winai/service/apiService.dart';
import 'package:b2winai/login/forgotPassword.dart';
import 'package:b2winai/login/login.dart';
import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  final String resetCode;
  final String email;
  const PasswordResetPage(
      {super.key, required this.resetCode, required this.email});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool isLoading = false; // Loading state variable
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool isButtonEnabled = false;
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    // Dispose the focus node to prevent memory leaks
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true; // Start loading
      });

      final newPassword = _newPasswordController.text;
      final resetCode = widget.resetCode;
      final email = widget.email;
      try {
        final response = await ApiService.forgotPasswordChanged(
            email, newPassword, resetCode);
        if (response['statuscode'] == 200) {
          final snackBar = SnackBar(
            content: Text(response['message']),
            duration: const Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Future.delayed(snackBar.duration, () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
          );
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
  }

  void _checkPasswords() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Enable the button if both fields are not empty
    setState(() {
      isButtonEnabled = newPassword.isNotEmpty && confirmPassword.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    // Request focus on the email field when the page loads
    _newPasswordController.addListener(_checkPasswords);
    _confirmPasswordController.addListener(_checkPasswords);
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
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Create New Password",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  "Your new password must be unique from those previously used.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20), // Space between text and form
                Center(
                  child: Image.asset(
                    'assets/images/changepassword.png',
                    height: 250,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Semantics(
                    label: 'New Password Field',
                    hint: 'Enter your password.',
                    textField: true,
                    child: TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'New Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.blue,
                          size: 24,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isNewPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Semantics(
                    label: 'Confirm Password Field',
                    hint: 'Enter your confirm password.',
                    textField: true,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Colors.blue,
                          size: 24,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: isButtonEnabled ? _resetPassword : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('Reset Password'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
