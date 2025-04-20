import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:camera/camera.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter/services.dart';

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
  // Stream controls
  final TextEditingController _streamKeyController = TextEditingController();
  final TextEditingController _streamUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _isWatching = false;
  String _streamingMethod = '';
  late final WebViewController _webViewController;

  // YouTube player
  late YoutubePlayerController _ytController;

  // Mobile streaming components
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  static const platform = MethodChannel('com.example.livestream/rtmp');

  @override
  void initState() {
    super.initState();

    // Initialize YouTube controller
    _ytController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    // Initialize WebView
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

  @override
  void dispose() {
    _streamKeyController.dispose();
    _streamUrlController.dispose();
    _stopMobileStreaming();
    _ytController.close();
    super.dispose();
  }

  Future<void> _startStreaming(String method) async {
    if (_streamKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your stream key')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (method == 'mobile') {
        await _startMobileStreaming();
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isStreaming = true;
          _streamingMethod = method;
          _isLoading = false;
        });
        _showOBSInstructions();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Streaming started via ${method.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting stream: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startMobileStreaming() async {
    try {
      final cameras = await availableCameras();
      // Use highest available resolution
      _cameraController = CameraController(
        cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back),
        ResolutionPreset.ultraHigh, // Changed to ultraHigh for best quality
      );
      await _cameraController!.initialize();

      final rtmpUrl =
          "rtmp://a.rtmp.youtube.com/live2/${_streamKeyController.text}";

      // Call native method with high quality parameters
      await platform.invokeMethod('startStreaming', {
        'rtmpUrl': rtmpUrl,
        'width': 1920,
        'height': 1080,
        'fps': 60,
        'videoBitrate': 5000, // in kbps
        'audioBitrate': 128, // in kbps
      });

      setState(() {
        _isCameraInitialized = true;
        _isStreaming = true;
        _streamingMethod = 'mobile';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      await _cameraController?.dispose();
      _cameraController = null;
      rethrow;
    }
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
      // Call native method to stop streaming
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
    if (_streamUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a stream URL')),
      );
      return;
    }

    String url = _streamUrlController.text;
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
  }

  String? _extractYoutubeVideoId(String url) {
    RegExp regExp = RegExp(
      r'^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    Match? match = regExp.firstMatch(url);
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstructionStep(1, 'Open OBS Studio'),
              _buildInstructionStep(2, 'Go to Settings → Stream'),
              _buildInstructionStep(
                  3, 'Select "YouTube / YouTube Gaming" as service'),
              _buildInstructionStep(4, 'Paste this server URL:'),
              const Padding(
                padding: EdgeInsets.only(left: 32, top: 4),
                child: Text(
                  'rtmp://a.rtmp.youtube.com/live2',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _buildInstructionStep(5, 'Enter your stream key in OBS'),
              _buildInstructionStep(6, 'Click "Start Streaming" in OBS'),
              const SizedBox(height: 16),
              const Text(
                'Your stream will appear on YouTube after a few seconds.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.'),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
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
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14),
                    ),
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
            Text(
              _streamingMethod == 'obs'
                  ? 'Streaming via OBS Studio'
                  : 'Streaming via Mobile',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Go to YouTube Studio to monitor your stream',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
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

          // Stream Controls
          const Text(
            'Stream Controls',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          // Stream Key Input
          const Text(
            'Enter YouTube Stream Key:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _streamKeyController,
            decoration: InputDecoration(
              hintText: 'YouTube Stream Key',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: Keep your stream key confidential. Never share it publicly.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 30),

          // Streaming Options
          if (!_isStreaming) ...[
            _buildStreamingOption(
              icon: Icons.desktop_windows,
              title: 'Stream via OBS',
              subtitle: 'High quality streaming using OBS Studio',
              onPressed: () => _startStreaming('obs'),
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            _buildStreamingOption(
              icon: Icons.phone_android,
              title: 'Stream via Mobile',
              subtitle: 'Direct streaming from your mobile device',
              onPressed: () => _startStreaming('mobile'),
              color: Colors.green,
            ),
          ] else if (_streamingMethod == 'mobile') ...[
            // Mobile Streaming Preview
            if (_isCameraInitialized)
              SizedBox(
                height: 250,
                width: 500,
                child: CameraPreview(_cameraController!),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopStreaming,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'STOP MOBILE STREAMING',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ] else ...[
            // OBS Streaming Status
            _buildStreamingStatus(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopStreaming,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'STOP STREAMING',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],

          // Playback Section
          const SizedBox(height: 40),
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

          if (_isWatching)
            SizedBox(
              height: 250,
              width: 500,
              child: YoutubePlayer(
                controller: _ytController,
                aspectRatio: 16 / 9,
              ),
            ),
        ],
      ),
    );
  }
}
