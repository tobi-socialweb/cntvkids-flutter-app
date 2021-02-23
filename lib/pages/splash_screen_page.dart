import 'package:flutter/material.dart';

import 'package:better_player/better_player.dart';

/// The second splash screen to be shown when starting the app.
class SplashScreen extends StatefulWidget {
  final BetterPlayer videoSplashScreen;

  SplashScreen({this.videoSplashScreen});

  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: widget.videoSplashScreen,
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("dispose ----------");
    widget.videoSplashScreen.controller.dispose(forceDispose: true);
    super.dispose();
  }
}
