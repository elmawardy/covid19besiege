import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../globals.dart';


final webViewKey = GlobalKey<WebViewContainerState>();

class WebViewContainer extends StatefulWidget {
  WebViewContainer({Key key}) : super(key: key);

  @override
  WebViewContainerState createState() => WebViewContainerState();
}

class WebViewContainerState extends State<WebViewContainer> {
  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: '${cfg["statsPageEgypt"]}',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      // TODO(iskakaushik): Remove this when collection literals makes it to stable.
      // ignore: prefer_collection_literals
      javascriptChannels: <JavascriptChannel>[
        _toasterJavascriptChannel(context),
      ].toSet(),
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          print('blocking navigation to $request}');
          return NavigationDecision.prevent;
        }
        print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
    );
  }

  void reloadWebView() {
    _webViewController?.reload();
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

}

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WebViewContainer(key: webViewKey),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          webViewKey.currentState?.reloadWebView();
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue,
      ),
    );
  }

}