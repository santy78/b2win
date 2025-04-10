import 'dart:convert';
import 'dart:io';

import 'package:b2winai/service/AuthService.dart';
import 'package:b2winai/constant.dart';
import 'package:b2winai/login/login.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Method to retrieve session data from AuthService
  static Future<Map<String, dynamic>> _getSessionData() async {
    return await AuthService.getSessionData();
  }

  // Method to get headers including the token
  static Future<Map<String, String>> _getHeaders() async {
    final sessionData = await _getSessionData();
    final String? token = sessionData['sessionToken'];

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'x-token': token.toString(),
    };
  }

  // Method to check if the token is expired
  static Future<bool> isTokenExpired() async {
    final sessionData = await _getSessionData();
    final String? token = sessionData['sessionToken'];

    if (token != null) {
      try {
        final jwt = JWT.decode(token);
        final int exp = jwt.payload['exp'] as int;
        final DateTime expiryDate =
            DateTime.fromMillisecondsSinceEpoch(exp * 1000);

        return expiryDate.isBefore(DateTime.now());
      } catch (e) {
        print('Error decoding token: $e');
        return true;
      }
    }
    return true; // Consider token expired if null or decoding fails
  }

  // Method to logout the user
  static Future<void> _logout(BuildContext context) async {
    final client = _createHttpClient();
    // Clear session data
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate to the login screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  // Generic safe API call that checks for token expiry before making any API requests
  static Future<T> safeApiCall<T>(
      Future<T> Function() apiCall, BuildContext context) async {
    final client = _createHttpClient();

    if (await isTokenExpired()) {
      final responses = await ApiService.getTkenByRefreshToken(context);

      if (responses['statuscode'] == 200) {
        final response = responses['data'];
        await AuthService.saveSessionData(
          token: response['access_token'],
          role: response['role_name'],
          refreshToken: response['refresh_token'],
          email: "",
          isLoggedIn: true,
        );
        return await apiCall();
      } else if (responses['statuscode'] == 401) {
        await _logout(context);
        throw Exception("Session expired. User logged out.");
      } else {
        // If token refresh failed, handle the logout or exception
        throw Exception("Session expired and token refresh failed.");
      }
      // await _logout(context);
      //throw Exception("Session expired. User logged out.");
    } else {
      return await apiCall();
    }
  }

  static Future<Map<String, dynamic>> getTkenByRefreshToken(
      BuildContext context) async {
    final client = _createHttpClient();
    final sessionData = await _getSessionData();
    final String refreshToken = sessionData['refreshToken'];
    final response = await client.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.getRefreshToken}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-token': refreshToken.toString(),
      },
    );
    if (response.statusCode == 200 || response.statusCode == 401) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error: ${response.body}');
    }
  }

  static IOClient _createHttpClient() {
    final HttpClient client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(client);
  }

  static Future<Map<String, dynamic>> login(String email, String password,
      String deviceToken, String deviceType) async {
    final client = _createHttpClient();
    try {
      String url = ApiConstants.baseUrl + ApiConstants.loginEndpoint;

      final response = await client.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          "devicetoken": deviceToken ?? "",
          "devicetype": deviceType ?? "",
        }),
      );

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String email,
      String referralCode, String deviceToken, String deviceType) async {
    final client = _createHttpClient();
    try {
      String url = ApiConstants.baseUrl + ApiConstants.registerEndpoint;

      final response = await client.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email": email,
          "role": "",
          "referred_code": referralCode,
          "devicetoken": "",
          "devicetype": ""
        }),
      );

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> forgotPasswordResetCode(
      String email) async {
    final client = _createHttpClient();
    try {
      String url =
          "${ApiConstants.baseUrl}${ApiConstants.forgotPasswordOTPSendEndPoint}";

      final response = await client.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{'email': email, 'otp_type': "password_reset"}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> forgotPasswordChanged(
      String email, String password, String otp) async {
    final client = _createHttpClient();
    try {
      String url =
          ApiConstants.baseUrl + ApiConstants.forgotPasswordChangeEndpoint;

      final response = await client.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, String>{"email": email, "password": password, "otp": otp}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<Map<String, dynamic>> getContest(BuildContext context) async {
    final client = _createHttpClient();
    String url = "${ApiConstants.baseUrl}${ApiConstants.contestListEndpoint}";
    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //List<dynamic> data = jsonResponse;
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getTeams(
      BuildContext context, int contestId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getTeamsEndPoint}?contest_id=$contestId";
    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        //List<dynamic> data = jsonResponse;
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> createTeams(
      String contestId, File? file, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createTeamEndpoint;

      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);

      if (file != null) {
        List<int> fileBytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ));
      } else {
        request.fields['file'] = ''; // Send an empty value for file
      }
      request.fields['contest_id'] = contestId;

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getMatches(
      BuildContext context, int contestId) async {
    final client = _createHttpClient();

    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getMatchesEndPoint}?contest_id=$contestId";

    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        //List<dynamic> data = jsonResponse;

        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> createMatch(
      String contestId, File? file, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createMatchEndpoint;

      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);

      if (file != null) {
        List<int> fileBytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ));
      } else {
        request.fields['file'] = ''; // Send an empty value for file
      }
      request.fields['contest_id'] = contestId;

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> addPlayers(
      File? file, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.addPlayerEndpoint;

      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);

      if (file != null) {
        List<int> fileBytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ));
      } else {
        request.fields['file'] = ''; // Send an empty value for file
      }

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> addPlayersToTeam(
      File? file, int contestId, int teamId, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.addPlayerEndpoint;

      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);

      if (file != null) {
        List<int> fileBytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.path.split('/').last,
        ));
      } else {
        request.fields['file'] = ''; // Send an empty value for file
      }

      request.fields['contest_id'] = contestId.toString();

      request.fields['team_id'] = teamId.toString();
      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }
}
