import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:r_dart_library/asset_svg.dart';

import 'package:cntvkids_app/common/constants.dart';

DioCacheManager customDioCacheManager =
    DioCacheManager(CacheConfig(baseUrl: WORDPRESS_URL));
Dio customDio = Dio()..interceptors.add(customDioCacheManager.interceptor);

class AppStateNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  bool notificationOn = true;

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    notifyListeners();
  }

  void updateNotifcationSetting(bool notificationOn) {
    this.notificationOn = notificationOn;
    notifyListeners();
  }
}

Future<Null> changeToDarkTheme(BuildContext context, bool val) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'darktheme';
  final value = val ? 1 : 0;
  await prefs.setInt(key, value);
  Provider.of<AppStateNotifier>(context, listen: false).updateTheme(val);
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
  final AssetSvg Function({double width, double height}) asset;
  final double size;
  final EdgeInsets padding;

  SvgIcon(
      {@required this.asset, this.size = 10.0, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SvgPicture.asset(
        asset(width: 0.0, height: 0.0).asset,
        width: size,
        height: size,
      ),
    );
  }
}
