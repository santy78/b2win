import 'dart:async';
import 'dart:io';
import 'package:b2winai/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:camera/camera.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:googleapis/youtube/v3.dart' as yt;

class LiveStreamingTab extends StatefulWidget {
  final int contestId;
  final int matchId;
  final String team1Name;
  final String team2Name;

  const LiveStreamingTab({
    super.key,
    required this.contestId,
    required this.matchId,
    required this.team1Name,
    required this.team2Name,
  });

  @override
  State<LiveStreamingTab> createState() => _LiveStreamingTabState();
}

class _LiveStreamingTabState extends State<LiveStreamingTab> {
  final TextEditingController _streamKeyController = TextEditingController();
  final TextEditingController _streamUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _isWatching = false;
  String _streamingMethod = '';
  late final WebViewController _webViewController;

  // Score variables
  int team1Score = 0;
  int team1WicketLost = 0;
  int team1overNumber = 0;
  int team1ballNumber = 0;
  double team1crr = 0.0;
  String team1runningOver = "0.0";
  int team2Score = 0;
  int team2WicketLost = 0;
  int team2overNumber = 0;
  int team2ballNumber = 0;
  double team2crr = 0.0;
  String team2runningOver = "0.0";

  late YoutubePlayerController _ytController;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  static const platform = MethodChannel('com.example.livestream/rtmp');

  // Google Sign-In
  GoogleSignInAccount? _currentUser;
  AuthClient? _authClient;
  yt.YouTubeApi? _youtubeApi;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      yt.YouTubeApi.youtubeScope,
      yt.YouTubeApi.youtubeForceSslScope,
    ],
  );

  @override
  void initState() {
    super.initState();

    _ytController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
      ));

    if (Platform.isAndroid) {
      final androidController =
          _webViewController.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    // Start score updates
    _startScoreUpdates();
  }

  @override
  void dispose() {
    _streamKeyController.dispose();
    _streamUrlController.dispose();
    _stopMobileStreaming();
    _ytController.close();
    super.dispose();
  }

  Future<void> _startScoreUpdates() async {
    // Initial fetch
    await _fetchScore();

    // Set up periodic updates
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isStreaming || _isWatching) {
        _fetchScore();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchScore() async {
    try {
      // Replace with your actual API call
      Map<String, dynamic> response =
          await ApiService.getScore(context, widget.contestId, widget.matchId);
      if (response['statuscode'] == 200 && response['data'] != null) {
        Map<String, dynamic> data = response['data'];
        Map<String, dynamic> firstInnings = data['first_innings'];
        Map<String, dynamic> secondInnings = data['second_innings'];

        setState(() {
          //team1 details
          team1Score = firstInnings["runs_scored"] ?? 0;
          team1WicketLost = firstInnings["wickets_lost"] ?? 0;
          team1overNumber = firstInnings["over_number"] ?? 0;
          team1ballNumber = firstInnings["ball_number"] ?? 0;
          team1crr = firstInnings["current_run_rate"]?.toDouble() ?? 0.0;
          team1runningOver = firstInnings["total_overs"]?.toString() ?? "0.0";
          //team2 details
          team2Score = secondInnings["runs_scored"] ?? 0;
          team2WicketLost = secondInnings["wickets_lost"] ?? 0;
          team2overNumber = secondInnings["over_number"] ?? 0;
          team2ballNumber = secondInnings["ball_number"] ?? 0;
          team2crr = secondInnings["current_run_rate"]?.toDouble() ?? 0.0;
          team2runningOver = secondInnings["total_overs"]?.toString() ?? "0.0";
        });
      }
    } catch (e) {
      debugPrint('Error fetching score: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return;

    final authHeaders = await account.authHeaders;
    final client = authenticatedClient(
      Client(),
      AccessCredentials(
        AccessToken(
          'Bearer',
          authHeaders['Authorization']!.split(" ").last,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        _googleSignIn.scopes,
      ),
    );

    setState(() {
      _currentUser = account;
      _authClient = client;
      _youtubeApi = yt.YouTubeApi(client);
    });
  }

  Future<Map<String, String>> createLiveStreamAndBroadcast() async {
    final now = DateTime.now();
    final startTime = now.add(const Duration(minutes: 1));
    final endTime = startTime.add(const Duration(hours: 2));

    final broadcast = yt.LiveBroadcast()
      ..snippet = (yt.LiveBroadcastSnippet()
        ..title = 'Live Match: ${widget.team1Name} vs ${widget.team2Name}'
        ..scheduledStartTime = startTime
        ..scheduledEndTime = endTime)
      ..status = (yt.LiveBroadcastStatus()..privacyStatus = 'public')
      ..kind = 'youtube#liveBroadcast';

    final insertedBroadcast = await _youtubeApi!.liveBroadcasts.insert(
      broadcast,
      ['snippet', 'status', 'contentDetails'],
    );

    final stream = yt.LiveStream()
      ..snippet = (yt.LiveStreamSnippet()..title = 'Mobile Stream')
      ..cdn = (yt.CdnSettings()
        ..format = '1080p'
        ..ingestionType = 'rtmp');

    final insertedStream = await _youtubeApi!.liveStreams.insert(
      stream,
      ['snippet', 'cdn'],
    );

    await _youtubeApi!.liveBroadcasts.bind(
      insertedBroadcast.id!,
      [insertedStream.id!],
    );

    final ingestionAddress =
        insertedStream.cdn?.ingestionInfo?.ingestionAddress;
    final streamName = insertedStream.cdn?.ingestionInfo?.streamName;

    if (ingestionAddress == null || streamName == null) {
      throw Exception('Failed to get RTMP info');
    }

    return {
      'rtmpUrl': '$ingestionAddress/$streamName',
      'streamKey': streamName,
    };
  }

  Future<void> _startStreaming(String method) async {
    if (_streamKeyController.text.isEmpty && method == 'obs') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your stream key')),
      );
      return;
    }

    _showLoadingDialog('Preparing stream...');

    try {
      if (_currentUser == null) {
        await signInWithGoogle();
      }

      if (method == 'mobile') {
        final streamInfo = await createLiveStreamAndBroadcast();
        _streamKeyController.text = streamInfo['streamKey']!;
        await _startMobileStreaming(streamInfo['rtmpUrl']!);
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isStreaming = true;
          _streamingMethod = method;
        });
        _showOBSInstructions();
      }

      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Streaming started via ${method.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );

      // Start score updates when streaming begins
      _startScoreUpdates();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting stream: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startMobileStreaming(String rtmpUrl) async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back),
      ResolutionPreset.ultraHigh,
    );
    await _cameraController!.initialize();

    await platform.invokeMethod('startStreaming', {
      'rtmpUrl': rtmpUrl,
      'width': 1920,
      'height': 1080,
      'fps': 60,
      'videoBitrate': 5000,
      'audioBitrate': 128,
    });

    setState(() {
      _isCameraInitialized = true;
      _isStreaming = true;
      _streamingMethod = 'mobile';
    });
  }

  void _stopStreaming() {
    if (_streamingMethod == 'mobile') {
      _stopMobileStreaming();
    } else {
      setState(() {
        _isStreaming = false;
        _streamingMethod = '';
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Streaming stopped'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _stopMobileStreaming() async {
    try {
      await platform.invokeMethod('stopStreaming');
      await _cameraController?.dispose();
      setState(() {
        _isCameraInitialized = false;
        _isStreaming = false;
        _streamingMethod = '';
        _cameraController = null;
      });
    } catch (e) {
      debugPrint('Error stopping mobile stream: $e');
    }
  }

  void _startPlayback() {
    final url = _streamUrlController.text;
    final videoId = _extractYoutubeVideoId(url);
    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL')),
      );
      return;
    }
    setState(() {
      _isWatching = true;
      _ytController.loadVideoById(videoId: videoId);
    });
    // Start score updates when playback begins
    _startScoreUpdates();
  }

  String? _extractYoutubeVideoId(String url) {
    final regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(2)!.length == 11)
        ? match.group(2)
        : null;
  }

  void _stopPlayback() {
    setState(() => _isWatching = false);
  }

  void _showOBSInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OBS Streaming Instructions'),
        content: const Text(
            'Set RTMP server to rtmp://a.rtmp.youtube.com/live2 and paste your stream key.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreOverlay() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '${widget.team1Name} vs ${widget.team2Name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.team1Name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$team1Score/$team1WicketLost ($team1runningOver)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'CRR: ${team1crr.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.team2Name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$team2Score/$team2WicketLost ($team2runningOver)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'CRR: ${team2crr.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Streaming: ${widget.team1Name} vs ${widget.team2Name}',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 20),
          const Text('Stream Controls',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const Text('YouTube Stream Key (auto-filled for mobile):'),
          const SizedBox(height: 8),
          TextField(
            controller: _streamKeyController,
            decoration: InputDecoration(
              hintText: 'Stream Key',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          if (!_isStreaming) ...[
            _buildStreamingOption(
              icon: Icons.desktop_windows,
              title: 'Stream via OBS',
              subtitle: 'Manual stream with custom key',
              onPressed: () => _startStreaming('obs'),
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildStreamingOption(
              icon: Icons.phone_android,
              title: 'Stream via Mobile (YouTube Setup)',
              subtitle: 'Auto create stream and go live',
              onPressed: () => _startStreaming('mobile'),
              color: Colors.green,
            ),
          ] else if (_streamingMethod == 'mobile') ...[
            Stack(
              children: [
                if (_isCameraInitialized)
                  SizedBox(
                    height: 250,
                    width: 500,
                    child: CameraPreview(_cameraController!),
                  ),
                _buildScoreOverlay(),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopStreaming,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('STOP MOBILE STREAMING'),
            ),
          ] else ...[
            _buildStreamingStatus(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopStreaming,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('STOP STREAMING'),
            ),
          ],
          const SizedBox(height: 40),
          const Text('Stream Playback',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 16),
          TextField(
            controller: _streamUrlController,
            decoration: InputDecoration(
              hintText: 'Enter YouTube Stream URL or Video ID',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: _startPlayback,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
              onPressed: _stopPlayback, child: const Text('Stop Playback')),
          const SizedBox(height: 16),
          if (_isWatching)
            SizedBox(
              height: 250,
              width: 500,
              child: Stack(
                children: [
                  YoutubePlayer(controller: _ytController, aspectRatio: 16 / 9),
                  _buildScoreOverlay(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreamingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    Text(subtitle, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingStatus() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 50, color: Colors.green),
            const SizedBox(height: 16),
            Text('LIVE STREAMING ACTIVE',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800])),
            const SizedBox(height: 8),
            Text(_streamingMethod == 'obs'
                ? 'Streaming via OBS Studio'
                : 'Streaming via Mobile'),
            const SizedBox(height: 16),
            const Text('Go to YouTube Studio to monitor your stream'),
          ],
        ),
      ),
    );
  }
}
