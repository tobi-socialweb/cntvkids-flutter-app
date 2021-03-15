import 'dart:async';

/// Menu pages
import 'package:cntvkids_app/pages/menu/lists_page.dart';
import 'package:cntvkids_app/pages/menu/series_page.dart';
import 'package:cntvkids_app/pages/menu/games_page.dart';
import 'package:cntvkids_app/pages/menu/featured_page.dart';
import 'package:cntvkids_app/pages/menu/search_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';
import 'package:cntvkids_app/widgets/menu_drawer_widget.dart';

/// Widget
import 'package:cntvkids_app/widgets/top_navigation_bar.dart';

/// General plugins
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Signals
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio plugins
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

///
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// The first page to be shown when starting the app.
class HomePage extends StatefulWidget {
  const HomePage({
    Key key,
  }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  /// Currently selected index for navigation bar.
  int _selectedIndex = 0;
  stt.SpeechToText speech;
  String word;

  final double length = 15.0;
  final double innerRadius = 5.0;
  final double outerRadius = 30.0;

  /// All options from the navigation bar
  List<Widget> _widgetOptions;

  /// volumen controls variables
  double _val;
  Timer timer;
  @override
  void initState() {
    super.initState();
    _checkDarkTheme();
    _checkFilter();
    //_startOneSignal();

    speech = stt.SpeechToText();
    initSpeechState();
    _val = BackgroundMusicManager.instance.volume;
    _widgetOptions = [
      FeaturedCardList(
        leftMargin: innerRadius + outerRadius,
      ),
      SeriesCardList(
        leftMargin: innerRadius + outerRadius,
      ),
      ListsCardList(
        leftMargin: innerRadius + outerRadius,
      ),
      GamesCardList(
        leftMargin: innerRadius + outerRadius,
      ),
    ];
  }

  _checkDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'darktheme';
    final platformTheme = MediaQuery.of(context).platformBrightness;
    final platformThemeCode = platformTheme == Brightness.dark ? 1 : 0;
    final value = prefs.getInt(key) ?? platformThemeCode;
    await changeToDarkTheme(context, value == 1);
    await Future.delayed(Duration(seconds: 1));
  }

  _checkFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'filter';
    final value = prefs.getString(key);
    if (value == 'greyscale') {
      await changeFilter(context, true, VisualFilters.grayscale);
    } else if (value == 'inverted') {
      await changeFilter(context, true, VisualFilters.inverted);
    }
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> initSpeechState() async {
    await speech.initialize();
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    final Size size = MediaQuery.of(context).size;
    final double navHeight = NAVBAR_HEIGHT_PROP * size.height;

    return BackgroundMusic(
      child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          drawerScrimColor: Colors.transparent,
          drawer: MenuDrawer(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "CHANGE THEME",
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    onChanged: (val) async {
                      await changeToDarkTheme(context, val);
                    },
                    activeColor: Colors.white,
                    value: Provider.of<AppStateNotifier>(context).isDarkMode,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "GRAYSCALE",
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    onChanged: (val) async {
                      await changeFilter(context, val, VisualFilters.grayscale);
                    },
                    activeColor: Colors.white,
                    value: Provider.of<AppStateNotifier>(context).colorFilter ==
                        GRAYSCALE_FILTER,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "INVERTED",
                    textScaleFactor: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    onChanged: (val) async {
                      await changeFilter(context, val, VisualFilters.inverted);
                    },
                    activeColor: Colors.white,
                    value: Provider.of<AppStateNotifier>(context).colorFilter ==
                        INVERTED_FILTER,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.audiotrack,
                        color: Colors.green,
                        size: navHeight * 0.3,
                      ),
                      title: Text(
                        'VOLUMEN MÚSICA',
                        textScaleFactor: 2,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Slider(
                      value: _val,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      onChanged: (val) {
                        _val = val;
                        setState(() {});
                        if (timer != null) {
                          timer.cancel();
                        }
                        //use timer for the smoother sliding
                        timer = Timer(Duration(milliseconds: 200), () {
                          BackgroundMusicManager.instance.music
                              .changeVolume(val);
                          BackgroundMusicManager.instance.volume = val;
                        });
                      })
                ],
              )
            ],
          ),
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: length),
                child: Column(
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
                        defaultIconSizes: 0.425 * navHeight,
                        defaultOnPressed: _onNavButtonTapped,
                        defaultTextScaleFactor: 0.00275 * size.height,
                        children: [
                          NavigationBarButton(
                            icon: SvgAsset.logo_icon,
                            resetCount: true,
                            text: " ",
                            size: 0.435 * navHeight,
                          ),
                          NavigationBarButton(
                            icon: SvgAsset.videos_icon,
                            activeIcon: SvgAsset.videos_active_icon,
                            text: "Destacados",
                          ),
                          NavigationBarButton(
                            icon: SvgAsset.series_icon,
                            activeIcon: SvgAsset.series_active_icon,
                            text: "Series",
                          ),
                          NavigationBarButton(
                            icon: SvgAsset.lists_icon,
                            activeIcon: SvgAsset.lists_active_icon,
                            text: "Listas",
                          ),
                          NavigationBarButton(
                            icon: SvgAsset.games_icon,
                            activeIcon: SvgAsset.games_active_icon,
                            text: "Juegos",
                          ),
                          NavigationBarButton(
                            icon: SvgAsset.search_icon,
                            text: "Buscar",
                            onPressed: (index) {
                              playSound("sounds/click/click.mp3");
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return SearchPage(
                                  speech: speech,
                                );
                              }));
                            },
                          ),
                        ],
                      ),
                    ),

                    /// Video & Game Cards' List.
                    Expanded(
                      child: Center(
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    ),
                  ],
                ),
              ),
              PullableDrawerBlob(
                size: size,
                color: Theme.of(context).accentColor,
                length: length,
                innerRadius: innerRadius,
                outerRadius: outerRadius,
                iconSizePercentage: 0.65,
              ),
            ],
          )),
    );
  }

  /// Play sounds efects
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes,
        volume: BackgroundMusicManager.instance.volume);
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
      foregroundPainter: BottomColoredBlobPainter(
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

class PullableDrawerBlob extends StatelessWidget {
  final Size size;
  final Color color;
  final double length;
  final double innerRadius;
  final double outerRadius;
  final double iconSizePercentage;

  const PullableDrawerBlob(
      {Key key,
      this.size,
      this.color,
      this.length,
      this.innerRadius,
      this.outerRadius,
      this.iconSizePercentage = 0.8})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double iconSize = (outerRadius * 2 * iconSizePercentage);
    final double iconPos = length +
        (innerRadius - outerRadius) +
        (1 - iconSizePercentage) * outerRadius;

    return Stack(
      children: [
        CustomPaint(
          painter: PullableDrawerBlobPainter(
            size: size,
            color: color,
            length: length,
            innerRadius: innerRadius,
            outerRadius: outerRadius,
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: iconPos > 0 ? iconPos : 0.0),
                child: SvgIcon(
                  asset: SvgAsset.back_icon,
                  size: iconSize,
                ),
              )
            ])
      ],
    );
  }
}

class PullableDrawerBlobPainter extends CustomPainter {
  final Size size;
  final Color color;
  final double length;
  final double innerRadius;
  final double outerRadius;

  PullableDrawerBlobPainter(
      {this.color, this.length, this.innerRadius, this.outerRadius, this.size});

  @override
  void paint(Canvas canvas, Size _) {
    Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(length + innerRadius, 0.5 * size.height), outerRadius, p);
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, length, size.height), p);

    Path path = Path()
      ..moveTo(length - 5.0, 0.5 * size.height - outerRadius - innerRadius)
      ..relativeLineTo(5.0, 0.0)
      ..relativeQuadraticBezierTo(0.0, innerRadius, innerRadius, innerRadius)
      ..relativeLineTo(0.0, outerRadius * 2)
      ..relativeQuadraticBezierTo(-innerRadius, 0.0, -innerRadius, innerRadius)
      ..relativeLineTo(-5.0, 0.0)
      ..close();

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
