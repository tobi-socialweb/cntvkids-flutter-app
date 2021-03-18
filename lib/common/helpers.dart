import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/foundation.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:cntvkids_app/common/constants.dart';

import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import "dart:math";

/// Enumerator for the types of filters that can be used in the app.
enum VisualMode { normal, dark, inverted, grayscale }

VisualMode stringToVisualMode(String value) {
  for (int i = 0; i < VisualMode.values.length; i++) {
    if (value == VisualMode.values[i].toString()) return VisualMode.values[i];
  }

  return null;
}

DioCacheManager customDioCacheManager =
    DioCacheManager(CacheConfig(baseUrl: WORDPRESS_URL));
Dio customDio = Dio()..interceptors.add(customDioCacheManager.interceptor);

class AppStateNotifier extends ChangeNotifier {
  ColorFilter filter = NORMAL_FILTER;
  bool isDarkMode = false;
  bool notificationOn = true;
  double musicVolume = 0.5;
  bool isUsingSignLang = false;

  String ip = "";
  int userId;

  Future<void> setIp() async {
    this.ip = await WifiInfo().getWifiIP();
  }

  void setUserId(int user) {
    this.userId = user;
  }

  void setMusicVolume(double volume) {
    this.musicVolume = volume;
    notifyListeners();
  }

  void setUsingSignLang(bool usingSignLang) {
    this.isUsingSignLang = usingSignLang;
    notifyListeners();
  }

  void setVisualMode(VisualMode filter) {
    switch (filter) {
      case VisualMode.grayscale:
        this.filter = GRAYSCALE_FILTER;
        this.isDarkMode = false;
        break;

      case VisualMode.inverted:
        this.filter = INVERTED_FILTER;
        this.isDarkMode = false;
        break;

      case VisualMode.dark:
        this.filter = NORMAL_FILTER;
        this.isDarkMode = true;
        break;

      default:

        /// normal
        this.filter = NORMAL_FILTER;
        this.isDarkMode = false;
        break;
    }

    notifyListeners();
  }

  void updateNotifcationSetting(bool notificationOn) {
    this.notificationOn = notificationOn;
    notifyListeners();
  }

  /// Save visual mode to user preferences.
  static Future<Null> save(BuildContext context,
      {VisualMode filter, double musicVolume, bool isUsingSignLang}) async {
    final prefs = await SharedPreferences.getInstance();

    if (filter != null) {
      await prefs.setString(VISUAL_MODE_KEY, filter.toString());

      Provider.of<AppStateNotifier>(context, listen: false)
          .setVisualMode(filter);
    }

    if (musicVolume != null) {
      await prefs.setDouble(MUSIC_VOLUME_KEY, musicVolume);

      Provider.of<AppStateNotifier>(context, listen: false)
          .setMusicVolume(musicVolume);
    }

    if (isUsingSignLang != null) {
      await prefs.setBool(SIGN_LANG_KEY, isUsingSignLang);

      Provider.of<AppStateNotifier>(context, listen: false)
          .setUsingSignLang(isUsingSignLang);
    }
  }

  /// Load visual mode from user preferences.
  static void load(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    /// Get current platform brightness to use if no preferences were saved.
    final brightness =
        MediaQuery.of(context).platformBrightness == Brightness.light
            ? VisualMode.normal.toString()
            : VisualMode.dark.toString();

    /// Get visual filter enum from preferences or current platform's brightness
    Provider.of<AppStateNotifier>(context, listen: false).setVisualMode(
        stringToVisualMode(prefs.getString(VISUAL_MODE_KEY) ?? brightness));

    Provider.of<AppStateNotifier>(context, listen: false)
        .setMusicVolume(prefs.getDouble(MUSIC_VOLUME_KEY) ?? 0.5);

    Provider.of<AppStateNotifier>(context, listen: false).isUsingSignLang =
        prefs.getBool(SIGN_LANG_KEY) ?? false;
  }
}

class SvgIcon extends StatelessWidget {
  final AssetResource asset;
  final double size;
  final EdgeInsets padding;

  SvgIcon({this.asset, this.size = 10.0, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SvgPicture.asset(
        asset.name,
        width: size,
        height: size,
      ),
    );
  }
}

class SvgButton extends StatelessWidget {
  final void Function() onPressed;
  final AssetResource asset;
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

/// Create a new Size widget by giving either `widthFactor` and/or
/// `heightFactor` and the current `context` to use for the base when scaling
/// and filling the empty values of the new size, if any.
///
/// Code example:
/// ```dart
/// /// Assume current display size has values (`width:5`, `height:50`),
/// /// meaning that MediaQuery.of(context).size == Size(`5`, `50`).
///
/// Size newSize = scaleSize(context, widthFactor: 10);
/// /// `newSize` has values (`width:50`, `height:50`).
/// ```
Size scaleSize(BuildContext context,
    {double widthFactor = 1.0, double heightFactor = 1.0}) {
  Size size = MediaQuery.of(context).size;
  return Size(size.width * widthFactor, size.height * heightFactor);
}

Future<int> getUserId(BuildContext context) async {
  String userIp = Provider.of<AppStateNotifier>(context, listen: false).ip;
  int userId = Provider.of<AppStateNotifier>(context, listen: false).userId;
  if (userId == null) {
    if (userIp == "") {
      await Provider.of<AppStateNotifier>(context, listen: false).setIp();
      userIp = Provider.of<AppStateNotifier>(context, listen: false).ip;
    }
    RegExp regExp = RegExp(
        r"^([1-9]\d*|0[0-7]*|0x[\da-f]+)(?:\.([1-9]\d*|0[0-7]*|0x[\da-f]+))?(?:\.([1-9]\d*|0[0-7]*|0x[\da-f]+))?(?:\.([1-9]\d*|0[0-7]*|0x[\da-f]+))?$",
        multiLine: true);
    RegExpMatch matches = regExp.allMatches(userIp).elementAt(0);
    List<int> groupsMatches = [0];
    for (int i = 1; i < matches.groupCount + 1; i++) {
      String element = matches.group(i);
      groupsMatches.add(element != null ? int.parse(element) : 0);
      groupsMatches[0] += element != null ? 1 : 0;
    }
    groupsMatches.addAll([256, 256, 256, 256]);
    groupsMatches[4 + groupsMatches[0]] *= pow(256, 4 - groupsMatches[0]);
    if (groupsMatches[1] >= groupsMatches[5] ||
        groupsMatches[2] >= groupsMatches[6] ||
        groupsMatches[3] >= groupsMatches[7] ||
        groupsMatches[4] >= groupsMatches[8]) {
      return null;
    }
    userId = groupsMatches[1] * (groupsMatches[0] == 1 ? 1 : 16777216) +
        groupsMatches[2] * (groupsMatches[0] <= 2 ? 1 : 65536) +
        groupsMatches[3] * (groupsMatches[0] <= 3 ? 1 : 256) +
        groupsMatches[4];
    Provider.of<AppStateNotifier>(context, listen: false).setUserId(userId);
  }
  return userId;
}
