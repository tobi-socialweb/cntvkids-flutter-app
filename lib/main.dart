import 'dart:async';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/menu/home_page.dart';
import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/widgets/background_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:better_player/better_player.dart';

import 'package:provider/provider.dart';

import 'package:cntvkids_app/pages/menu/home_page.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Main function called at app start.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Set mobile orientations as landscape only.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  /// Currently, this setting will get lost after UI changes (when writing on
  /// a text box, for example). Needs the use of restoreSystemUIOverlays.
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  runApp(ChangeNotifierProvider<AppStateNotifier>(
    create: (context) => AppStateNotifier(),
    child: MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()),
  ));
}

/// Main app widget class.
class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// A future completer used when loading the splash screen.
  Completer completer = new Completer();

  /// The splash screen video loaded using BetterPlayer.
  BetterPlayer splashScreenVideo = BetterPlayer.network(
      "https://cntvinfantil.cl/cntv/wp-content/uploads/2020/02/cntv-infantil-logo-mascotas.mp4",
      betterPlayerConfiguration: BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        autoDispose: false,
        controlsConfiguration:
            BetterPlayerControlsConfiguration(showControls: false),
      ));

  /// If the splash screen video has ended or not.
  bool videoEnded = false;

  /// TODO: implement timer to test if video could not load and show error message. (and some retry attempts).
  void initState() {
    splashScreenVideo = BetterPlayer.network(
        "https://cntvinfantil.cl/cntv/wp-content/uploads/2020/02/cntv-infantil-logo-mascotas.mp4",
        betterPlayerConfiguration: BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          autoPlay: true,
          autoDispose: false,
          controlsConfiguration:
              BetterPlayerControlsConfiguration(showControls: false),
        ));

    splashScreenVideo.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(splashScreenVideo);
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.finished) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Consumer<AppStateNotifier>(
              builder: (context, appState, child) {
            print(
                "DEBUG: appState.filter:${appState.filter}, appState.musicVolume:${appState.musicVolume}");
            return ColorFiltered(
                colorFilter: appState.filter,
                child: BackgroundMusic(
                  volume: appState.musicVolume,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'CNTV_KIDS',
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode:
                        appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    home: HomePage(),
                  ),
                ));
          });
        }));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: completer.future,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && !videoEnded) {
          return Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: splashScreenVideo,
              ),
            ),
          );
        } else {
          /// If there was an error, just push the home page.
          if (snapshot.hasError) pushHomePage();
          return Container(color: Colors.black);
        }
      },
    );
  }

  void pushHomePage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomePage();
    }));
  }

  @override
  void dispose() {
    splashScreenVideo.controller.dispose(forceDispose: true);

    super.dispose();
  }
}
