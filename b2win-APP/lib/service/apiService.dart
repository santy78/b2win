import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  String lastTeamName = "";
  List<Map<String, dynamic>> lastSelectedPlayers = [];

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
          uid: "",
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

  static Future<Map<String, dynamic>> updateScore(
    int contestId,
    int matchId,
    int teamId,
    int inningsId,
    int bowlerId,
    String runsType,
    int overNumber,
    int ballNumber,
    int strikerId,
    int nonStrikerId,
    int extraRun,
    String outType,
    int playerOutId,
    int wicketTakerId,
  ) async {
    int run = 0;
    bool isFour = false;
    bool isSix = false;
    //int extraRun = 0;
    String extraType = "";
    if (runsType == '4') {
      isFour = true;
      run = 4;
    } else if (runsType == '6') {
      isSix = true;
      run = 6;
    } else if (runsType == 'WB') {
      extraType = "wide";
      extraRun = extraRun + 1;
    } else if (runsType == 'BYE') {
      extraType = "bye";
    } else if (runsType == 'LB') {
      extraType = "legBye";
    } else if (runsType == 'NB') {
      extraType = "noBall";
      extraRun = extraRun + 1;
    } else if (runsType == 'OUT') {
      run = extraRun;
    } else {
      run = int.parse(runsType);
    }
    final client = _createHttpClient();
    try {
      String url = ApiConstants.baseUrl + ApiConstants.updateScoreEndpouint;

      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(<String, dynamic>{
          "contest_id": contestId,
          "match_id": matchId,
          "team_id": teamId,
          "inning_id": inningsId,
          "over_number": overNumber,
          "ball_number": ballNumber + 1,
          "batsman_id": strikerId,
          "non_striker_id": nonStrikerId,
          "bowler_id": bowlerId,
          "runs_scored": run,
          "extra_type": extraType,
          "extra_runs": extraRun,
          "dismissal": outType,
          "fielding_position": '',
          "player_out_id": playerOutId,
          "wicket_taker_id": wicketTakerId,
          "is_four": isFour,
          "is_six": isSix
        }),
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

  static Future<Map<String, dynamic>> undo(
      int contestId, int matchId, int teamId, int inningsId) async {
    final client = _createHttpClient();
    try {
      String url = ApiConstants.baseUrl + ApiConstants.undoEndpoint;

      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(<String, dynamic>{
          "contest_id": contestId,
          "match_id": matchId,
          "team_id": teamId,
          "inning_id": inningsId,
        }),
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

  static Future<Map<String, dynamic>> getScoreBoard(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getScoreBoardEndpoint}?contest_id=$contestId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.get(
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

  static Future<Map<String, dynamic>> getPlayerInfo(
      BuildContext context, int playerId) async {
    final client = _createHttpClient();

    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getPlayerInfoEndpoint}?player_id=$playerId";

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

  static Future<Map<String, dynamic>> getMatchPlayers(
      BuildContext context, int contestId, int matchId, int teamId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getMatchPlayers}?contest_id=$contestId&team_id=$teamId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.get(
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

  static Future<Map<String, dynamic>> tossDetails(
      BuildContext context,
      int contestId,
      int matchId,
      int teamId,
      int inningOver,
      String tossDecision) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.tossDetaileEndpoint}?contest_id=$contestId&toss_winner_id=$teamId&match_id=$matchId&toss_decision=$tossDecision&overs_per_innings=$inningOver";
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

  static Future<Map<String, dynamic>> getBallingScore(
      BuildContext context,
      int contestId,
      int matchId,
      int inningNo,
      int startOver,
      int endOver) async {
    final client = _createHttpClient();

    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getBallingScoreEndpoint}?contest_id=$contestId&match_id=$matchId&inning_number=$inningNo&over_start=$startOver&over_end=$endOver";

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

  static Future<Map<String, dynamic>> getBatsmanScore(BuildContext context,
      int contestId, int matchId, int inningNo, int playerId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getBatsmanScoreEndpoint}?contest_id=$contestId&match_id=$matchId&inning_number=$inningNo&player_id=$playerId";
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

  static Future<Map<String, dynamic>> getScore(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getScoreEndpoint}?contest_id=$contestId&match_id=$matchId";
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

  static Future<Map<String, dynamic>> getTossDetails(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();

    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getTossDetailsEndpoint}?contest_id=$contestId&match_id=$matchId";

    return safeApiCall(() async {
      final response = await client.get(
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

  static Future<Map<String, dynamic>> getAllPlayers(
      BuildContext context) async {
    final client = _createHttpClient();
    String url = "${ApiConstants.baseUrl}${ApiConstants.getPlayersEndpoint}";
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

  static Future<Map<String, dynamic>> getPlayersByTeamby(
      BuildContext context, int contestId, int teamId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getPlayerByTeamEndpoint}?contest_id=$contestId&team_id=$teamId";
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
      String contestId,
      String teamName,
      String city,
      String info,
      String flag,
      BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createTeamEndpoint;
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(<String, dynamic>{
          "contest_id": contestId,
          "teams": [
            {
              "team_name": teamName,
              "logo_url": "",
              "city": city,
              "info": info,
              "flag": flag
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> addTeamSquardPlayer(
      int contestId, int teamId, List Players, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url =
          ApiConstants.baseUrl + ApiConstants.addTeamSquardPlayerEndpoint;
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(<String, dynamic>{
          "contest_id": contestId,
          "team_id": teamId,
          "players": Players
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> addMatchSquardPlayer(int contestId,
      int teamId, int matchId, List Players, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url =
          ApiConstants.baseUrl + ApiConstants.addMatchSquardPlayerEndpoint;
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(<String, dynamic>{
          "contest_id": contestId,
          "team_id": teamId,
          "match_id": matchId,
          "players": Players
        }),
      );
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

  static Future<Map<String, dynamic>> createMatchByFile(
      String contestId, File? file, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createMatchByFileEndpoint;

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

  static Future<Map<String, dynamic>> createContest(
      String name, String title, String game_type, BuildContext context) async {
    final client = _createHttpClient();
    DateTime now = DateTime.now().toUtc(); // Ensure UTC time
    String isoDate = now.toIso8601String();
    print("ISO 8601 Date and Time: ${isoDate}Z"); // Append 'Z' to indicate UTC
    String currentTime = "${isoDate}Z";

    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createContestEndpoint;
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(<String, dynamic>{
          "name": name,
          "title": title,
          "game_type": game_type,
          "start_time": currentTime,
          "end_time": currentTime,
          "info": {}
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> updateProfilePicture(
      File? file, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.userProfilePictureUpdate;

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

  static Future<Uint8List> profilePictureDownloadFile(
      BuildContext context) async {
    return safeApiCall<Uint8List>(() async {
      final client = _createHttpClient();
      String url =
          "${ApiConstants.baseUrl}${ApiConstants.profilePictureDownloadEndpoint}";

      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: ${response.reasonPhrase}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> createNoContest(
      BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createNoContestEndpoint;

      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> uploadTeamLogo(
      String? contestId, int teamId, File? file, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.uploadTeamLogoEndpoint;

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

  static Future<Uint8List> downlaodTeamLogo(BuildContext context) async {
    return safeApiCall<Uint8List>(() async {
      final client = _createHttpClient();

      String url =
          "${ApiConstants.baseUrl}${ApiConstants.downloadTeamLogoEndpoint}";

      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: ${response.reasonPhrase}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getTeamInfo(
      int contestId, int teamId, BuildContext context) async {
    final client = _createHttpClient();

    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.getTeamInfoEndpoint;
      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];
      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };
      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);
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

  static Future<Map<String, dynamic>> getPlayerByPhone(
      String player_phone, BuildContext context) async {
    final client = _createHttpClient();

    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.getPlayerByPhone;
      final sessionData = await _getSessionData();
      final String? token = sessionData['sessionToken'];

      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
        'x-token': token.toString(),
      };

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(headers);
      request.fields['player_phone'] = player_phone;

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // var responseBody = json.decode(response.body) as Map<String, dynamic>;
        final jsonResponse = json.decode(response.body);
        return Map<String, dynamic>.from(jsonResponse);
        // Extract 'data' key from response if present
        // if (responseBody.containsKey('data')) {
        //   print(responseBody['data']);
        //   return responseBody['data'] as Map<String, dynamic>;
        // } else {
        //   throw Exception('Invalid response: "data" key missing');
        // }
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> createPlayer(
      String playerName,
      String dob,
      String phoneNumber,
      String email,
      String gender,
      String playerRole,
      String info,
      BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createPlayerEndpoint;
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode([
          {
            "fullname": playerName,
            "dob": dob,
            "phonenumber": phoneNumber,
            "email": email,
            "gender": gender,
            "player_role": playerRole,
            "info": info,
            "flag": "I"
          }
        ]),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> createMatch(
      Map<String, dynamic> requestBody, BuildContext context) async {
    final client = _createHttpClient();
    return safeApiCall(() async {
      const url = ApiConstants.baseUrl + ApiConstants.createMatchEndpoint;
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getExtras(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getExtrasEndpoint}?contest_id=$contestId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> updateMatchInnings(
      BuildContext context, contestId, matchId, inningsNo) async {
    final client = _createHttpClient();

    String url =
        "${ApiConstants.baseUrl}${ApiConstants.updateMatchInningsEndPoint}?contest_id=$contestId&match_id=$matchId&innings_id=$inningsNo";

    return safeApiCall(() async {
      final response = await client.put(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> endMatch(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();

    String url =
        "${ApiConstants.baseUrl}${ApiConstants.endMatchEndpoint}?contest_id=$contestId&match_id=$matchId&won_team_id=0&player_of_match_id=0";

    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getFallOfWickets(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getFallOfWicketsEndpoint}?contest_id=$contestId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getMatchInfo(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getMatchInfoEndpoint}?contest_id=$contestId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getBestPerformance(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getBestPerformanceEndpoint}?contest_id=$contestId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.post(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return Map<String, dynamic>.from(jsonResponse);
      } else {
        throw Exception('Failed to load data');
      }
    }, context);
  }

  static Future<Map<String, dynamic>> getMvp(
      BuildContext context, contestId, matchId) async {
    final client = _createHttpClient();
    String url =
        "${ApiConstants.baseUrl}${ApiConstants.getMvpEndpoint}?contest_id=$contestId&match_id=$matchId";
    return safeApiCall(() async {
      final response = await client.get(
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
}
