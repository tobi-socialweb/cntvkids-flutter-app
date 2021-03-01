import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cntvkids_app/pages/menu/search_detail_page.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Signals
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The first page to be shown when starting the app.
class SearchPage extends StatefulWidget {
  const SearchPage({Key key}) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  /// Currently selected index for navigation bar.
  bool hide = true;
  SearchCardList lista;
  @override
  void initState() {
    super.initState();
    _startOneSignal();
    lista = SearchCardList();
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

    return Scaffold(
        resizeToAvoidBottomInset: true,
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
            Stack(
              children: [
                Container(
                    constraints: BoxConstraints(
                        maxHeight: navHeight,
                        maxWidth: size.width,
                        minWidth: size.width,
                        minHeight: navHeight),
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),

                        /// search container
                        Container(
                            margin: EdgeInsets.only(bottom: 0.25 * navHeight),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(navHeight)),
                            width: 0.5 * size.width,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.05),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: "FredokaOne"),
                                onTap: () {
                                  setState(() {
                                    hide = true;
                                  });
                                },
                                onSubmitted: (string) {
                                  print(string);
                                  setState(() {
                                    hide = false;
                                    lista = SearchCardList(search: string);
                                  });
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Buscar aquí',
                                    hintStyle: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: "FredokaOne")),
                              ),
                            )),

                        /// Search button
                        SvgButton(
                          asset: SvgAsset.search_icon,
                          size: 0.5 * navHeight,
                          padding: EdgeInsets.fromLTRB(
                            0.125 * navHeight,
                            0.0,
                            0.0,
                            0.25 * navHeight,
                          ),
                          onPressed: () {
                            setState(() {
                              hide = false;
                            });
                          },
                        ),
                      ],
                    )),
                if (!hide)
                  Container(
                    margin: EdgeInsets.only(top: navHeight),
                    child: lista,
                  ),
              ],
            )
          ],
        ));
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
