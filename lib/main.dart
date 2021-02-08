import 'package:admob_flutter/admob_flutter.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/widgets/nav_icon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/featured_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/helpers.dart';

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
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CNTV Kids',
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColorLight: Colors.white,
            primaryColorDark: Colors.black,
            primaryColor: Colors.red,
            accentColor: Colors.purple[900],
            canvasColor: Color(0xFFE3E3E3),
            textTheme: TextTheme(
              headline1: TextStyle(
                fontSize: 17,
                color: Colors.black,
                height: 1.2,
                fontWeight: FontWeight.w500,
                fontFamily: "Soleil",
              ),
              headline2: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Poppins'),
              caption: TextStyle(color: Colors.black45, fontSize: 10),
              bodyText1: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
              bodyText2: TextStyle(
                fontSize: 14,
                height: 1.2,
                color: Colors.black54,
              ),
            ),
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white),
        home: HomePage(),
      );
    });
  }
}

/// The first page to be shown when starting the app.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Currently selected index for navigation bar.
  int _selectedIndex = 0;

  /// All options from the navigation bar.
  final List<Widget> _widgetOptions = [
    Featured(),
    Featured(),
  ];

  @override
  void initState() {
    super.initState();
    _startOneSignal();
    if (ENABLE_ADS) _startAdMob();
  }

  _startAdMob() {
    Admob.initialize(ADMOB_ID);
  }

  _startOneSignal() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'notification';
    final value = prefs.getInt(key) ?? 1;

    onesignal.init(
      ONE_SIGNAL_APP_ID,
      iOSSettings: {
        OSiOSSettings.autoPrompt: true,
        OSiOSSettings.inAppLaunchUrl: true
      },
    );
    onesignal.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    onesignal.setInFocusDisplayType(OSNotificationDisplayType.notification);

    await enableNotification(context, value == 1);
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;

    /// TODO: Use custom navigator for routing.
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            width: size.width,
            height: NAV_BAR_PERCENTAGE * size.height,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NavIconButton(
                  icon: R.svg.logo_icon,
                  iconSize: 0.25 * size.height,
                  currentSelectedIndex: _selectedIndex,
                  buttonIndex: 0,
                  isLogo: true,
                  onPressed: _onNavButtonTapped,
                ),
                NavIconButton(
                  icon: R.svg.videos_icon,
                  iconWhenPressed: R.svg.videos_active_icon,
                  iconSize: 0.1 * size.height,
                  buttonText: "Destacados",
                  buttonIndex: 0,
                  currentSelectedIndex: _selectedIndex,
                  onPressed: _onNavButtonTapped,
                ),
                NavIconButton(
                  icon: R.svg.series_icon,
                  iconWhenPressed: R.svg.series_active_icon,
                  iconSize: 0.1 * size.height,
                  buttonText: "Series",
                  buttonIndex: 1,
                  currentSelectedIndex: _selectedIndex,
                  onPressed: _onNavButtonTapped,
                ),
                NavIconButton(
                  icon: R.svg.lists_icon,
                  iconWhenPressed: R.svg.lists_active_icon,
                  iconSize: 0.1 * size.height,
                  buttonText: "Listas",
                  buttonIndex: 1,
                  currentSelectedIndex: _selectedIndex,
                  onPressed: _onNavButtonTapped,
                ),
                NavIconButton(
                  icon: R.svg.games_icon,
                  iconWhenPressed: R.svg.games_active_icon,
                  iconSize: 0.1 * size.height,
                  buttonText: "Juegos",
                  buttonIndex: 1,
                  currentSelectedIndex: _selectedIndex,
                  onPressed: _onNavButtonTapped,
                ),
                NavIconButton(
                  icon: R.svg.search_icon,
                  iconWhenPressed: R.svg.search_icon,
                  iconSize: 0.13 * size.height,
                  buttonText: "Buscar",
                  buttonIndex: 1,
                  currentSelectedIndex: _selectedIndex,
                  onPressed: _onNavButtonTapped,
                ),
              ],
            )),
        Expanded(
          child: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
        Container(
          width: size.width,
          height: NAV_BAR_PERCENTAGE / 2 * size.height,
        )
      ],
    ));
  }

  /// Change the selected index when button is tapped.
  void _onNavButtonTapped(int index) {
    print("DEBUG: called by index: $index");
    setState(() {
      /// TODO: Remove following line once there are more pages to load.
      index = index > 1 ? 0 : index;
      _selectedIndex = index;
    });
  }
}
