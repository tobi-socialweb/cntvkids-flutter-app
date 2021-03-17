import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:cntvkids_app/common/constants.dart';

/// Enumerator for the types of filters that can be used in the app.
enum VisualMode { normal, dark, inverted, grayscale }

VisualMode visualModeFromString(String value) {
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

  void setMusicVolume(double volume) {
    this.musicVolume = volume;
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
      {VisualMode filter, double musicVolume}) async {
    final prefs = await SharedPreferences.getInstance();

    if (filter != null) {
      await prefs.setString(VISUAL_MODE_KEY, filter.toString());

      Provider.of<AppStateNotifier>(context, listen: false)
          .setVisualMode(filter);
    } else if (musicVolume != null) {
      await prefs.setDouble(MUSIC_VOLUME_KEY, musicVolume);

      Provider.of<AppStateNotifier>(context, listen: false)
          .setMusicVolume(musicVolume);
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
    final filterValue =
        visualModeFromString(prefs.getString(VISUAL_MODE_KEY) ?? brightness);

    final volumeValue = prefs.getDouble(MUSIC_VOLUME_KEY) ?? 0.5;

    await save(context, filter: filterValue, musicVolume: volumeValue);
  }
}

class SvgIcon extends StatelessWidget {
  final AssetResource asset;
  final double size;
  final EdgeInsets padding;

  SvgIcon(
      {@required this.asset, this.size = 10.0, this.padding = EdgeInsets.zero});

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

Size newSize({double width, double height, Size current}) {
  double _w = (width == null && current != null) ? current.width : width;
  double _h = (height == null && current != null) ? current.height : height;

  return Size(_w ?? 1.0, _h ?? 1.0);
}
