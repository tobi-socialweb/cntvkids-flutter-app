import 'dart:async';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/widgets/config_widget.dart';
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
  ColorFilter colorFilter;
  VisualFilter currentVisualFilter;

  bool hasSetFilter = false;

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

  void updateVisualFilter(bool value, VisualFilter filter) {
    if (!this.mounted) return;

    switch (filter) {
      case VisualFilter.grayscale:
        setState(() {
          colorFilter = value ? GRAYSCALE_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.grayscale : VisualFilter.normal;
        });
        break;

      case VisualFilter.inverted:
        setState(() {
          colorFilter = value ? INVERTED_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.inverted : VisualFilter.normal;
        });
        break;

      /// normal
      default:
        setState(() {
          colorFilter = NORMAL_FILTER;
          currentVisualFilter = VisualFilter.normal;
        });
        break;
    }
  }

  Widget build(BuildContext context) {
    if (!hasSetFilter) {
      hasSetFilter = true;

      currentVisualFilter = Config.of(context).configSettings.filter;

      switch (currentVisualFilter) {
        case VisualFilter.grayscale:
          colorFilter = GRAYSCALE_FILTER;
          break;

        case VisualFilter.inverted:
          colorFilter = INVERTED_FILTER;
          break;

        default:
          colorFilter = NORMAL_FILTER;
      }
    }
    final Size size = MediaQuery.of(context).size;
    return ColorFiltered(
      colorFilter: colorFilter,
      child: Scaffold(
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
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop),
    );
  }
}
