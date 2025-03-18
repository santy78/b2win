import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PredictionViewPage extends StatefulWidget {
  const PredictionViewPage({super.key});

  @override
  State<PredictionViewPage> createState() => _PredictionViewPageState();
}

class _PredictionViewPageState extends State<PredictionViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://b2win.itisiya.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
