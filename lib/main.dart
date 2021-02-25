/// Splash screen page
import 'package:cntvkids_app/pages/splash_screen_page.dart';
import 'package:better_player/better_player.dart';

/// Home page
import 'package:cntvkids_app/pages/menu/home_page.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'common/helpers.dart';
import 'dart:async';

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
      child: Consumer<AppStateNotifier>(builder: (context, appState, child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CNTV Kids',
            theme: ThemeData(
                brightness: Brightness.light,
                primaryColorLight: Colors.white,
                primaryColorDark: Colors.black,
                primaryColor: Colors.red,
                accentColor: Color(0xFF390084),
                canvasColor: Color(0xFFE3E3E3),
                textTheme: TextTheme(
                  bodyText2: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                      fontFamily: "FredokaOne"),
                ),
                backgroundColor: Colors.white,
                scaffoldBackgroundColor: Colors.white),
            home: MyApp());
      })));
}

/// Main app widget class.
class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer completer = new Completer();
  BetterPlayer videoSplashScreen;
  bool end = false;
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
          return HomePage();
        }));
      }
    });
  }

  Future<dynamic> _futureSplash() {
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureSplash(),
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
