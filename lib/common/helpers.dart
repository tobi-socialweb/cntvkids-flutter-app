import 'package:cntvkids_app/common/store_manager.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:cntvkids_app/common/constants.dart';

DioCacheManager customDioCacheManager =
    DioCacheManager(CacheConfig(baseUrl: WORDPRESS_URL));
Dio customDio = Dio()..interceptors.add(customDioCacheManager.interceptor);

class AppStateNotifier extends ChangeNotifier {
  bool notificationOn = true;

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColorLight: Colors.black,
    primaryColorDark: Colors.white,
    primaryColor: Color(0xFF390084),
    accentColor: Color(0xFFF95D58),
    canvasColor: Color(0xFF3F3F3F),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: Colors.white,
        fontFamily: "FredokaOne",
      ),
      bodyText2: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: Colors.white,
          fontFamily: "FredokaOne"),
    ),
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColorLight: Colors.white,
    primaryColorDark: Colors.black,
    primaryColor: Colors.red,
    accentColor: Color(0xFF390084),
    canvasColor: Color(0xFFE3E3E3),
    textTheme: TextTheme(
      bodyText1: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: Colors.black,
        fontFamily: "FredokaOne",
      ),
      bodyText2: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: Colors.black,
          fontFamily: "FredokaOne"),
    ),
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
  );

  ThemeData _themeData;
  ThemeMode getTheme() {
    print("DEBUG: getting theme mode: ${_themeData.brightness}");
    return _themeData == null || _themeData.brightness == Brightness.light
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  AppStateNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('DEBUG: value read from storage: ' + value.toString());
      var themeMode = value ?? 'dark';
      if (themeMode == 'light') {
        _themeData = lightTheme;
      } else {
        print('DEBUG: setting dark theme');
        _themeData = darkTheme;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }

  void updateNotifcationSetting(bool notificationOn) {
    this.notificationOn = notificationOn;
    notifyListeners();
  }
}

OneSignal onesignal = OneSignal();

DatabaseReference databaseReference = new FirebaseDatabase().reference();

Future<Null> enableNotification(context, bool val) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'notification';
  final value = val ? 1 : 0;
  await prefs.setInt(key, value);
  onesignal.setSubscription(val);
  Provider.of<AppStateNotifier>(context, listen: false)
      .updateNotifcationSetting(val);
}

class SvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final EdgeInsets padding;

  SvgIcon(
      {@required this.asset, this.size = 10.0, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
      ),
    );
  }
}

class SvgButton extends StatelessWidget {
  final void Function() onPressed;
  final String asset;
  final double size;
  final EdgeInsets padding;

  const SvgButton(
      {Key key,
      this.onPressed,
      this.asset,
      this.size,
      this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return FlatButton(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onPressed: onPressed,
      child: SvgIcon(
        asset: asset,
        size: size,
        padding: padding,
      ),
    );
  }
}

Size newSize({double width, double height, Size current}) {
  double _w = (width == null && current != null) ? current.width : width;
  double _h = (height == null && current != null) ? current.height : height;

  return Size(_w ?? 1.0, _h ?? 1.0);
}

// CODE GENERATED BY `svg.py` - DO NOT MODIFY BY HAND
// (DO NOT REMOVE OR EDIT THESE COMMENTS EITHER)

/// All of the available svg assets.
class SvgAsset {
  ///asset from file: `assets/images/back/back_icon.svg`
  // ignore: non_constant_identifier_names
  static final String back_icon = "assets/images/back/back_icon.svg";

  ///asset from file: `assets/images/backgrounds/18x9/background-red.svg`
  // ignore: non_constant_identifier_names
  static final String background_red =
      "assets/images/backgrounds/18x9/background-red.svg";

  ///asset from file: `assets/images/backgrounds/background-red.svg`
  // ignore: non_constant_identifier_names
  static final String background_red$1 =
      "assets/images/backgrounds/background-red.svg";

  ///asset from file: `assets/images/chromecast/chromecast_active_icon.svg`
  // ignore: non_constant_identifier_names
  static final String chromecast_active_icon =
      "assets/images/chromecast/chromecast_active_icon.svg";

  ///asset from file: `assets/images/chromecast/chromecast_icon.svg`
  // ignore: non_constant_identifier_names
  static final String chromecast_icon =
      "assets/images/chromecast/chromecast_icon.svg";

  ///asset from file: `assets/images/games/games_active_icon.svg`
  // ignore: non_constant_identifier_names
  static final String games_active_icon =
      "assets/images/games/games_active_icon.svg";

  ///asset from file: `assets/images/games/games_badge.svg`
  // ignore: non_constant_identifier_names
  static final String games_badge = "assets/images/games/games_badge.svg";

  ///asset from file: `assets/images/games/games_icon.svg`
  // ignore: non_constant_identifier_names
  static final String games_icon = "assets/images/games/games_icon.svg";

  ///asset from file: `assets/images/lists/lists_active_icon.svg`
  // ignore: non_constant_identifier_names
  static final String lists_active_icon =
      "assets/images/lists/lists_active_icon.svg";

  ///asset from file: `assets/images/lists/lists_badge.svg`
  // ignore: non_constant_identifier_names
  static final String lists_badge = "assets/images/lists/lists_badge.svg";

  ///asset from file: `assets/images/lists/lists_icon.svg`
  // ignore: non_constant_identifier_names
  static final String lists_icon = "assets/images/lists/lists_icon.svg";

  ///asset from file: `assets/images/logo/logo_icon.svg`
  // ignore: non_constant_identifier_names
  static final String logo_icon = "assets/images/logo/logo_icon.svg";

  ///asset from file: `assets/images/player_next/player_next_icon.svg`
  // ignore: non_constant_identifier_names
  static final String player_next_icon =
      "assets/images/player_next/player_next_icon.svg";

  ///asset from file: `assets/images/player_pause/player_pause_icon.svg`
  // ignore: non_constant_identifier_names
  static final String player_pause_icon =
      "assets/images/player_pause/player_pause_icon.svg";

  ///asset from file: `assets/images/player_play/player_play_icon.svg`
  // ignore: non_constant_identifier_names
  static final String player_play_icon =
      "assets/images/player_play/player_play_icon.svg";

  ///asset from file: `assets/images/player_previous/player_previous_icon.svg`
  // ignore: non_constant_identifier_names
  static final String player_previous_icon =
      "assets/images/player_previous/player_previous_icon.svg";

  ///asset from file: `assets/images/record/record_icon.svg`
  // ignore: non_constant_identifier_names
  static final String record_icon = "assets/images/record/record_icon.svg";

  ///asset from file: `assets/images/search/search_icon.svg`
  // ignore: non_constant_identifier_names
  static final String search_icon = "assets/images/search/search_icon.svg";

  ///asset from file: `assets/images/series/series_active_icon.svg`
  // ignore: non_constant_identifier_names
  static final String series_active_icon =
      "assets/images/series/series_active_icon.svg";

  ///asset from file: `assets/images/series/series_badge.svg`
  // ignore: non_constant_identifier_names
  static final String series_badge = "assets/images/series/series_badge.svg";

  ///asset from file: `assets/images/series/series_icon.svg`
  // ignore: non_constant_identifier_names
  static final String series_icon = "assets/images/series/series_icon.svg";

  ///asset from file: `assets/images/videos/videos_active_icon.svg`
  // ignore: non_constant_identifier_names
  static final String videos_active_icon =
      "assets/images/videos/videos_active_icon.svg";

  ///asset from file: `assets/images/videos/videos_badge.svg`
  // ignore: non_constant_identifier_names
  static final String videos_badge = "assets/images/videos/videos_badge.svg";

  ///asset from file: `assets/images/videos/videos_icon.svg`
  // ignore: non_constant_identifier_names
  static final String videos_icon = "assets/images/videos/videos_icon.svg";
}
// -----
