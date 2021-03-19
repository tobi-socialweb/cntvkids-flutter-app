import 'package:cntvkids_app/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Enumerator for the types of filters that can be used in the app.
enum VisualMode { normal, dark, inverted, grayscale }

VisualMode stringToVisualMode(String value) {
  for (int i = 0; i < VisualMode.values.length; i++) {
    if (value == VisualMode.values[i].toString()) return VisualMode.values[i];
  }
  return null;
}

class AppStateConfig extends ChangeNotifier {
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

      Provider.of<AppStateConfig>(context, listen: false).setVisualMode(filter);
    }

    if (musicVolume != null) {
      await prefs.setDouble(MUSIC_VOLUME_KEY, musicVolume);

      Provider.of<AppStateConfig>(context, listen: false)
          .setMusicVolume(musicVolume);
    }

    if (isUsingSignLang != null) {
      await prefs.setBool(SIGN_LANG_KEY, isUsingSignLang);

      Provider.of<AppStateConfig>(context, listen: false)
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
    Provider.of<AppStateConfig>(context, listen: false).setVisualMode(
        stringToVisualMode(prefs.getString(VISUAL_MODE_KEY) ?? brightness));

    Provider.of<AppStateConfig>(context, listen: false)
        .setMusicVolume(prefs.getDouble(MUSIC_VOLUME_KEY) ?? 0.5);

    Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang =
        prefs.getBool(SIGN_LANG_KEY) ?? false;
  }
}
