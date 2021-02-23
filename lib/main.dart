/// Splash screen page
import 'package:cntvkids_app/pages/splash_screen_page.dart';

/// Home page
import 'package:cntvkids_app/pages/menu/home_page.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Provider
import 'package:provider/provider.dart';

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

  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(),
      child: MyApp(),
    ),
  );
}

/// Main app widget class.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 7)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
              debugShowCheckedModeBanner: false, home: SplashScreen());
        } else {
          // Loading is done, return the app:
          return Consumer<AppStateNotifier>(
              builder: (context, appState, child) {
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
                    bodyText1: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                        fontFamily: "FredokaOne"),
                  ),
                  backgroundColor: Colors.white,
                  scaffoldBackgroundColor: Colors.white),
              home: HomePage(),
            );
          });
        }
      },
    );
  }
}
