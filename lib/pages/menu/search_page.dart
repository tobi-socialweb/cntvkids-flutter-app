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
class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  /// Currently selected index for navigation bar.
  static AudioCache cache = new AudioCache();
  static AudioPlayer player = new AudioPlayer();
  bool musicOn;
  bool visibility;
  bool hide;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startOneSignal();
    loopMusic();
    visibility = true;
    hide = true;
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
    final double navHeight = NAVBAR_HEIGHT_PROP * size.height;

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
                CustomPaint(
                  painter: BottomColoredBlobPainter(
                    size: size,
                    color: Colors.white,
                  ),
                ),

                /// Top Bar.
                Container(
                    constraints: BoxConstraints(
                        maxHeight: navHeight, maxWidth: size.width),
                    height: navHeight,
                    width: size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Back button.
                        SvgButton(
                          asset: SvgAsset.back_icon,
                          size: 0.5 * navHeight,
                          padding: EdgeInsets.fromLTRB(
                              0.125 * navHeight, 0.0, 0.0, 0.25 * navHeight),
                          onTap: () => Navigator.of(context).pop(),
                        ),

                        /// search container
                        Container(
                          width: 0.2 * size.width,
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter a search term'),
                          ),
                        ),

                        /// Search button
                        SvgButton(
                          asset: SvgAsset.search_icon,
                          size: 0.5 * navHeight,
                          padding: EdgeInsets.fromLTRB(
                              0.125 * navHeight, 0.0, 0.0, 0.25 * navHeight),
                          onTap: () {
                            setState(() {
                              hide = false;
                            });
                          },
                        ),
                      ],
                    )),
                if (!hide)

                  /// results
                  Center(
                    child: Text(
                      'Resultados',
                      style: TextStyle(fontSize: 24),
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
