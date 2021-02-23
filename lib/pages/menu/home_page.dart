/// Menu pages
import 'package:cntvkids_app/pages/menu/lists_page.dart';
import 'package:cntvkids_app/pages/menu/series_page.dart';
import 'package:cntvkids_app/pages/menu/games_page.dart';
import 'package:cntvkids_app/pages/menu/featured_page.dart';

/// Resources
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/widgets/top_navigation_bar.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Signals
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio plugins
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:focus_detector/focus_detector.dart';

/// The first page to be shown when starting the app.
class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// Currently selected index for navigation bar.
  int _selectedIndex = 0;
  static AudioCache cache = new AudioCache();
  static AudioPlayer player = new AudioPlayer();
  bool musicOn;
  bool visibility;

  /// All options from the navigation bar
  final List<Widget> _widgetOptions = [
    FeaturedCardList(),
    SeriesCardList(),
    ListsCardList(),
    GamesCardList(),
    FeaturedCardList(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startOneSignal();
    loopMusic();
    visibility = true;
  }

  // Dispose funtions
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Stop/play background music in agreement with de application state
  Future<AudioPlayer> loopMusic() async {
    player =
        await cache.loop('sounds/background/background_1.mp3', volume: 0.7);
    musicOn = true;
    return player;
  }

  Future<AudioPlayer> stopMusic() async {
    player?.stop();
    musicOn = false;
    return player;
  }

  Future<AudioPlayer> resumeMusic() async {
    player?.resume();
    musicOn = true;
    return player;
  }

  Future<AudioPlayer> pauseMusic() async {
    player?.pause();
    musicOn = false;
    return player;
  }

  // Change background sound in agreement of app state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive && musicOn)) {
      pauseMusic();
    } else if (state == AppLifecycleState.resumed && !musicOn & visibility) {
      resumeMusic();
    }
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
    final double navHeight = NAV_BAR_PERCENTAGE * size.height;

    return FocusDetector(
        onVisibilityLost: () {
          visibility = false;
          stopMusic();
        },
        onVisibilityGained: () {
          visibility = true;
          if (musicOn != null && !musicOn) {
            cache.clearCache();
            loopMusic();
          }
        },
        child: Scaffold(
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
                    height: navHeight,
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
                  height: navHeight / 2,
                ),
              ],
            )));
  }

  /// Play sounds efects
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes);
  }

  /// Change the selected index when button is tapped.
  void _onNavButtonTapped(int index) {
    playSound("sounds/click/click.mp3");
    setState(() {
      _selectedIndex = index;
    });
  }

  int getCurrentSelectedIndex() {
    return _selectedIndex;
  }
}

/// Custom painter for the colored bottom blob.
class BottomColoredBlob extends StatefulWidget {
  final Size size;
  final int currentSelectedIndex;
  final List<Color> colors;
  final int Function() getCurrentSelectedIndex;

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
      painter: BottomColoredBlobPainter(
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

class BottomColoredBlobPainter extends CustomPainter {
  final Size size;
  final Color color;

  BottomColoredBlobPainter({this.size, this.color});

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
    return true;
  }
}
