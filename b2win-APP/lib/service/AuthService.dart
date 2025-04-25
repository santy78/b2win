import 'dart:ffi';

import 'package:b2winai/service/apiService.dart';
import 'package:b2winai/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class AuthService {
  static Future<void> saveSessionData({
    required String token,
    required String refreshToken,
    required String role,
    required String email,
    required String uid,
    required bool isLoggedIn,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionToken', token);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('role', role);
    if (email.isNotEmpty) {
      await prefs.setString('email', email);
    }
    await prefs.setString('uid', uid);
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<Map<String, dynamic?>> getSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sessionToken');
    String? refreshToken = prefs.getString('refreshToken');
    String? role = prefs.getString('role');
    String? email = prefs.getString('email');
    String? uid = prefs.getString('uid');
    return {
      'sessionToken': token,
      'refreshToken': refreshToken,
      'role': role,
      'email': email,
      'uid': uid,
    };
  }

  static Future<void> checkTokenAndLogout(BuildContext context) async {
    Map<String, dynamic> sessionData = await getSessionData();

    String? token = sessionData['sessionToken'];

    final bool isLoggedIn = sessionData['isLoggedIn'];
    if (token != null) {
      try {
        final jwt = JWT.decode(token);
        final int exp = jwt.payload['exp'] as int;
        final DateTime expiryDate =
            DateTime.fromMillisecondsSinceEpoch(exp * 1000);

        if (expiryDate.isBefore(DateTime.now())) {
          if (isLoggedIn) {
            // Token is expired
            final responses = await ApiService.getTkenByRefreshToken(context);

            if (responses['statuscode'] == 200) {
              final response = responses['data'];
              final email = response['profile']['email'];
              final uid = response['profile']['uid'];
              await AuthService.saveSessionData(
                token: response['access_token'],
                role: response['role_name'],
                email: email,
                uid: uid,
                refreshToken: response['refresh_token'],
                isLoggedIn: true,
              );
            } else {
              await _logout(context);
            }
          }
        }
      } catch (e) {
        // If decoding fails or any other error occurs, log out
        await _logout(context);
      }
    } else {
      // No token found, log out
      await _logout(context);
    }
  }

  static Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionToken');
    await prefs.remove('role');
    await prefs.remove('email');
    await prefs.remove('isLoggedIn');
    // Add more items to clear if needed
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Define this route in your RouterConstant
    );
    // Navigate to login page
    /*Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);*/
  }

  static Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionToken');
    await prefs.remove('refreshToken');
    await prefs.remove('role');
    await prefs.remove('email');
    await prefs.remove('isLoggedIn');
    // Add more items to clear if needed
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Define this route in your RouterConstant
    );
    // Navigate to login page
    /*Navigator.pushNamedAndRemoveUntil(
        context, '/login', (Route<dynamic> route) => false);*/
  }
}
