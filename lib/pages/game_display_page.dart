import 'dart:async';

import 'package:cntvkids_app/widgets/background_music.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Shows video widgets that have 'Games' category.
class WebViewPage extends StatefulWidget {
  final String url;
  WebViewPage({@required this.url});
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  //WebViewController controller;

  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();

  // web view controls

  _backButton() {
    Size size = MediaQuery.of(context).size;
    double iconSize = 0.3 * size.height;
    return FutureBuilder<WebViewController>(
      future: _controllerCompleter.future,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (controller.hasData) {
          return FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () async {
              MusicEffect.play("sounds/go_back/go_back.mp3");
              Navigator.of(context).pop();
            },
            child: SvgIcon(
              asset: SvgAsset.back_icon,
              size: iconSize,
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          margin: EdgeInsets.symmetric(vertical: size.height * 0.05),
          child: WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController c) {
              _controllerCompleter.complete(c);
            },
          ),
        ),
        floatingActionButton: _backButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop);
  }
}
