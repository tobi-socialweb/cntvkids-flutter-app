import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/menu/home_page.dart';
import 'package:cntvkids_app/pages/splash_screen_page.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'common/helpers.dart';
import 'dart:async';

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

  /// Theming and stuff probably related to OneSignal.
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
  Completer completer = new Completer();
  BetterPlayer videoSplashScreen;
  bool end = false;

  /// TODO: implement timer to test if video could not load and show
  /// error message. (and some retry attempts).
  void initState() {
    super.initState();
    videoSplashScreen = BetterPlayer.network(
        "https://cntvinfantil.cl/cntv/wp-content/uploads/2020/02/cntv-infantil-logo-mascotas.mp4",
        betterPlayerConfiguration: BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          autoPlay: true,
          autoDispose: false,
          controlsConfiguration:
              BetterPlayerControlsConfiguration(showControls: false),
        ));
    videoSplashScreen.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(videoSplashScreen);
      } else if (event.betterPlayerEventType ==
          BetterPlayerEventType.finished) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Consumer<AppStateNotifier>(
              builder: (context, appState, child) {
            print("DEBUG: $appState");
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'CNTV_KIDS',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: HomePage(
                appState: appState,
              ),
            );
          });
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: completer.future,
      // ignore: missing_return
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData && !end) {
          return SplashScreen(videoSplashScreen: videoSplashScreen);
        } else {
          return Container(color: Colors.black);
        }
      },
    );
  }
}
