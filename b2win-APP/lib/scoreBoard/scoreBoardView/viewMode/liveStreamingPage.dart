import 'dart:async';
import 'dart:io';
import 'package:b2winai/service/apiService.dart';
import 'package:b2winai/service/credentialManager.dart';
import 'package:b2winai/service/youtubeService.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:camera/camera.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

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
  // Controllers and state
  final TextEditingController _streamKeyController = TextEditingController();
  final TextEditingController _streamUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _isWatching = false;
  String _streamingMethod = '';
  late final WebViewController _webViewController;
  late YoutubePlayerController _ytController;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  static const platform = MethodChannel('com.example.livestream/rtmp');

  // YouTube service
  YouTubeService? _youTubeService;
  String? _currentBroadcastId;

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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeYouTubeClient();
    _startScoreUpdates();
  }

  void _initializeControllers() {
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
  }

  Future<void> _initializeYouTubeClient() async {
    try {
      final credentials = await CredentialManager.getCredentials();
      final authClient = await _refreshAuthClient(
        credentials['clientId']!,
        credentials['clientSecret']!,
        credentials['refreshToken']!,
      );

      setState(() {
        _youTubeService = YouTubeService(authClient);
      });
    } catch (e) {
      debugPrint('YouTube initialization error: $e');
      _showErrorSnackbar('Failed to initialize YouTube: ${e.toString()}');
    }
  }

  Future<AuthClient> _refreshAuthClient(
    String clientId,
    String clientSecret,
    String refreshToken,
  ) async {
    // Create a ClientId from the credentials
    final clientIdObj = ClientId(clientId, clientSecret);

    // Create the existing credentials object
    final credentials = AccessCredentials(
      AccessToken('Bearer', 'initial-token', DateTime.now()),
      refreshToken,
      ['https://www.googleapis.com/auth/youtube'],
    );

    // Refresh the credentials
    try {
      final newCredentials = await refreshCredentials(
        clientIdObj,
        credentials,
        http.Client(),
      );

      // Return an authenticated client
      return authenticatedClient(
        http.Client(),
        newCredentials,
      );
    } catch (e) {
      debugPrint('Error refreshing credentials: $e');
      throw Exception('Failed to refresh credentials: $e');
    }
  }

  Future<void> _startScoreUpdates() async {
    await _fetchScore();
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
      Map<String, dynamic> response =
          await ApiService.getScore(context, widget.contestId, widget.matchId);

      if (response['statuscode'] == 200 && response['data'] != null) {
        final data = response['data'];
        setState(() {
          // Team 1 score updates
          team1Score = data['first_innings']['runs_scored'] ?? 0;
          team1WicketLost = data['first_innings']['wickets_lost'] ?? 0;
          team1crr =
              data['first_innings']['current_run_rate']?.toDouble() ?? 0.0;

          // Team 2 score updates
          team2Score = data['second_innings']['runs_scored'] ?? 0;
          team2WicketLost = data['second_innings']['wickets_lost'] ?? 0;
          team2crr =
              data['second_innings']['current_run_rate']?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching score: $e');
    }
  }

  Future<void> _startStreaming(String method) async {
    if (method == 'obs' && _streamKeyController.text.isEmpty) {
      _showErrorSnackbar('Please enter your stream key');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (method == 'mobile') {
        await _startMobileStreaming();
      } else {
        setState(() {
          _isStreaming = true;
          _streamingMethod = method;
        });
        _showOBSInstructions();
      }

      _showSuccessSnackbar('Streaming started via ${method.toUpperCase()}');
      _startScoreUpdates();
    } catch (e) {
      _showErrorSnackbar('Error starting stream: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startMobileStreaming() async {
    if (_youTubeService == null) {
      await _initializeYouTubeClient();
      if (_youTubeService == null)
        throw Exception('YouTube service not initialized');
    }

    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back),
      ResolutionPreset.ultraHigh,
    );
    await _cameraController!.initialize();

    final streamInfo = await _youTubeService!.createLiveStream(
      title: '${widget.team1Name} vs ${widget.team2Name}',
      description: 'Live cricket match',
    );

    await platform.invokeMethod('startStreaming', {
      'rtmpUrl': streamInfo['rtmpUrl'],
      'width': 1920,
      'height': 1080,
      'fps': 30,
    });

    setState(() {
      _isCameraInitialized = true;
      _isStreaming = true;
      _streamingMethod = 'mobile';
      _currentBroadcastId = streamInfo['broadcastId'];
      _streamKeyController.text = streamInfo['streamKey']!;
      _streamUrlController.text = streamInfo['streamUrl']!;
    });
  }

  Future<void> _stopStreaming() async {
    try {
      if (_streamingMethod == 'mobile') {
        await _stopMobileStreaming();
        if (_currentBroadcastId != null) {
          await _youTubeService?.endStream(_currentBroadcastId!);
        }
      }

      setState(() {
        _isStreaming = false;
        _streamingMethod = '';
        _currentBroadcastId = null;
      });

      _showSuccessSnackbar('Streaming stopped');
    } catch (e) {
      _showErrorSnackbar('Error stopping stream: $e');
    }
  }

  Future<void> _stopMobileStreaming() async {
    try {
      await platform.invokeMethod('stopStreaming');
      await _cameraController?.dispose();
      setState(() {
        _isCameraInitialized = false;
        _cameraController = null;
      });
    } catch (e) {
      debugPrint('Error stopping mobile stream: $e');
    }
  }

  void _startPlayback() {
    final videoId = _extractYoutubeVideoId(_streamUrlController.text);
    if (videoId == null) {
      _showErrorSnackbar('Invalid YouTube URL');
      return;
    }

    setState(() {
      _isWatching = true;
      _ytController.loadVideoById(videoId: videoId);
    });
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
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1. Open OBS Studio'),
            Text('2. Go to Settings > Stream'),
            Text('3. Set Service to "YouTube / YouTube Gaming"'),
            Text('4. Paste your Stream Key'),
            Text('5. Click "Start Streaming"'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
                _buildTeamScore(
                    widget.team1Name, team1Score, team1WicketLost, team1crr),
                _buildTeamScore(
                    widget.team2Name, team2Score, team2WicketLost, team2crr),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int score, int wickets, double crr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ), // Added missing parenthesis here
        Text(
          '$score/$wickets',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'CRR: ${crr.toStringAsFixed(1)}',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
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
          padding: const EdgeInsets.all(12),
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
                          color: color,
                        )),
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
            Text(
              'LIVE STREAMING ACTIVE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
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

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),

          // Stream Controls Section
          const Text(
            'Stream Controls',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const Text('YouTube Stream Key:'),
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

          // Streaming Options
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
              title: 'Stream via Mobile',
              subtitle: 'Auto create YouTube stream',
              onPressed: () => _startStreaming('mobile'),
              color: Colors.green,
            ),
          ] else if (_streamingMethod == 'mobile') ...[
            Stack(
              children: [
                if (_isCameraInitialized)
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: CameraPreview(_cameraController!),
                  ),
                _buildScoreOverlay(),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopStreaming,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('STOP MOBILE STREAMING'),
            ),
          ] else ...[
            _buildStreamingStatus(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopStreaming,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('STOP STREAMING'),
            ),
          ],

          const SizedBox(height: 40),

          // Playback Section
          const Text(
            'Stream Playback',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
            onPressed: _stopPlayback,
            child: const Text('Stop Playback'),
          ),
          const SizedBox(height: 16),

          // Video Player
          if (_isWatching)
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Stack(
                children: [
                  YoutubePlayer(
                    controller: _ytController,
                    aspectRatio: 16 / 9,
                  ),
                  _buildScoreOverlay(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _youTubeService?.dispose();
    _ytController.close();
    _stopMobileStreaming();
    _streamKeyController.dispose();
    _streamUrlController.dispose();
    super.dispose();
  }
}
