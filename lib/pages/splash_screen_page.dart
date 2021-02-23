import 'package:flutter/material.dart';

import 'package:better_player/better_player.dart';

/// The second splash screen to be shown when starting the app.
class SplashScreen extends StatefulWidget {
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final BetterPlayer videoSplashScreen = BetterPlayer.network(
    "https://cntvinfantil.cl/cntv/wp-content/uploads/2020/02/cntv-infantil-logo-mascotas.mp4",
    betterPlayerConfiguration: BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      autoPlay: true,
      autoDispose: false,
      controlsConfiguration:
          BetterPlayerControlsConfiguration(showControls: false),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: videoSplashScreen,
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoSplashScreen.controller.dispose();
    super.dispose();
  }
}
