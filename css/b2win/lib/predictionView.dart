import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PredictionViewPage extends StatelessWidget {
  const PredictionViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: WebView(
        initialUrl:
            'https://b2win.itisiya.com/', // Replace with your desired URL
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
