import 'package:admob_flutter/admob_flutter.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/widgets/top_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/featured_page.dart';
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
    Featured(),
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
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// The colored curved blob in the background (white, yellow, etc.).
            BottomColoredBlob(
              size: size,
              currentSelectedIndex: _selectedIndex,
              colors: [
                Colors.white,
                Colors.cyan,
                Colors.yellow,
                Theme.of(context).accentColor,
                Colors.white
              ],
              getCurrentSelectedIndex: getCurrentSelectedIndex,
            ),

            /// Top Navigation Bar.
            Container(
                width: size.width,
                height: NAV_BAR_PERCENTAGE * size.height,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: TopNavigationBar(
                  getSelectedIndex: getCurrentSelectedIndex,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  defaultIconSizes: 0.125 * size.height,
                  defaultOnPressed: _onNavButtonTapped,
                  defaultTextScaleFactor: 0.0025 * size.height,
                  children: [
                    NavigationBarButton(
                      icon: R.svg.logo_icon,
                      size: 0.25 * size.height,
                      resetCount: true,
                    ),
                    NavigationBarButton(
                      icon: R.svg.videos_icon,
                      activeIcon: R.svg.videos_active_icon,
                      text: "Destacados",
                    ),
                    NavigationBarButton(
                      icon: R.svg.series_icon,
                      activeIcon: R.svg.series_active_icon,
                      text: "Series",
                    ),
                    NavigationBarButton(
                      icon: R.svg.lists_icon,
                      activeIcon: R.svg.lists_active_icon,
                      text: "Listas",
                    ),
                    NavigationBarButton(
                      icon: R.svg.games_icon,
                      activeIcon: R.svg.games_active_icon,
                      text: "Juegos",
                    ),
                    NavigationBarButton(
                      icon: R.svg.search_icon,
                      text: "Buscar",
                    ),
                  ],
                )),

            /// Video & Game Cards' List.
            Expanded(
              child: Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),

            /// Space filler to keep things kinda centered.
            Container(
              width: size.width,
              height: NAV_BAR_PERCENTAGE / 2 * size.height,
            )
          ],
        ));
  }

  /// Change the selected index when button is tapped.
  void _onNavButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int getCurrentSelectedIndex() {
    return _selectedIndex;
  }
}

typedef int IntCallback();

/// Custom painter for the colored bottom blob.
class BottomColoredBlob extends StatefulWidget {
  final Size size;
  final int currentSelectedIndex;
  final List<Color> colors;
  final IntCallback getCurrentSelectedIndex;

  BottomColoredBlob(
      {this.size,
      this.currentSelectedIndex,
      this.colors,
      this.getCurrentSelectedIndex});

  @override
  _BottomColoredBlobState createState() => _BottomColoredBlobState();
}

class _BottomColoredBlobState extends State<BottomColoredBlob> {
  int currentSelectedIndex;

  @override
  void initState() {
    currentSelectedIndex = widget.getCurrentSelectedIndex();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateSelectedIndex();
    return CustomPaint(
      painter: _BottomColoredBlobPainter(
        size: widget.size,
        color: widget.colors[currentSelectedIndex],
      ),
    );
  }

  void updateSelectedIndex() {
    setState(() {
      currentSelectedIndex = widget.getCurrentSelectedIndex();
    });
  }
}

class _BottomColoredBlobPainter extends CustomPainter {
  final Size size;
  final Color color;

  _BottomColoredBlobPainter({this.size, this.color});

  @override
  void paint(Canvas canvas, Size _) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path()..moveTo(0.5 * -size.width, 0.65 * size.height);

    path.quadraticBezierTo(
        0.0, 0.5 * size.height, 0.5 * size.width, 0.775 * size.height);
    path.lineTo(0.5 * size.width, size.height);
    path.lineTo(-0.5 * size.width, size.height);
    path.close();

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
