import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/home_page.dart';
import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  runApp(ChangeNotifierProvider<AppStateConfig>(
    create: (context) => AppStateConfig(),
    child: MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()),
  ));
}

/// Main app widget class.
class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BetterPlayer videoSplashScreen;
  bool end = false;

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
    videoSplashScreen = BetterPlayer.network(
        "https://cntvinfantil.cl/cntv/wp-content/uploads/2020/02/cntv-infantil-logo-mascotas.mp4",
        betterPlayerConfiguration: BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          autoPlay: true,
          controlsConfiguration:
              BetterPlayerControlsConfiguration(showControls: false),
        ));

    videoSplashScreen.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return Consumer<AppStateConfig>(builder: (context, appState, child) {
            print(
                "DEBUG from main: appState.filter:${appState.filter}, appState.musicVolume:${appState.musicVolume}, appState.isUsingSignLang: ${appState.isUsingSignLang} ");

            return ColorFiltered(
                colorFilter: appState.filter,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'CNTV_KIDS',
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode:
                      appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                  home: BackgroundMusic(
                    volume: appState.musicVolume,
                    child: HomePage(),
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
