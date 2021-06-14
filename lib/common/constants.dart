library constants;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The wordpress site url.
const String WORDPRESS_URL = "https://cntvinfantil.cl";

/// The videos URL using `/videos?_embed`.
const String VIDEOS_URL = "$WORDPRESS_URL/wp-json/wp/v2/videos?_embed";

/// The games URL using `juegos/?_embed`.
const String GAMES_URL = "$WORDPRESS_URL/wp-json/wp/v2/juegos?_embed";

/// The series URL using `/series?_embed`.
const String SERIES_URL = "$WORDPRESS_URL/wp-json/wp/v2/series?_embed";

/// The lists URL using `/listas?_embed`.
const String LISTS_URL = "$WORDPRESS_URL/wp-json/wp/v2/listas?_embed";

/// Error messages to display.
enum ErrorTypes { NO_CONNECTION, NO_LAUNCH, UNREACHABLE, UNKNOWN }
const Map<ErrorTypes, String> ERROR_MESSAGE = {
  ErrorTypes.NO_CONNECTION: "Sin conexión a internet.",
  ErrorTypes.NO_LAUNCH: "No se pudo iniciar.",
  ErrorTypes.UNREACHABLE:
      "No se pudo alcansar el servidor. Por favor, verifique su conexión a internet e inténtelo de nuevo.",
  ErrorTypes.UNKNOWN:
      "Hubo un problema para conectarse con el servidor. Por favor, inténtelo de nuevo.",
};

/// Missing image url.
const String MISSING_IMAGE_URL =
    "$WORDPRESS_URL/cntv/wp-content/uploads/2019/09/noimage-1.jpg";

/// Featured category ID.
const int FEATURED_ID = 10536;

/// Series category ID.
const int SERIES_ID = 10287;

/// Lists category ID.
const int LISTS_ID = 10564;

/// iOS games category ID.
const int IOS_GAMES_ID = 10564;

/// Android games category ID.
const int ANDROID_GAMES_ID = 10563;

/// Height proportion for the navigator bar.
const double NAVBAR_HEIGHT_PROP = 0.275;

/// OneSignal's ID.
const String ONE_SIGNAL_APP_ID = "45e71839-7d7b-445a-b325-b9009d92171e";

const bool ENABLE_DYNAMIC_LINK = false;

const String VISUAL_MODE_KEY = "visualmode";
const String MUSIC_VOLUME_KEY = "musicvolume";
const String SIGN_LANG_KEY = "signlang";
const String HISTORY_VIDEOS_KEY = "historyvideos";

// ignore: non_constant_identifier_names
final ColorFilter NORMAL_FILTER =
    const ColorFilter.mode(Colors.transparent, BlendMode.color);
// ignore: non_constant_identifier_names
final ColorFilter GRAYSCALE_FILTER =
    const ColorFilter.mode(Colors.grey, BlendMode.saturation);
// ignore: non_constant_identifier_names
final ColorFilter INVERTED_FILTER =
    const ColorFilter.mode(Colors.white, BlendMode.difference);

final darkTheme = ThemeData(
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

final lightTheme = ThemeData(
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


// CODE GENERATED BY `assets.py` - DO NOT MODIFY BY HAND
// (DO NOT REMOVE OR EDIT THESE COMMENTS EITHER)
class AssetResource {
  final String name;

  const AssetResource(this.name);
}

/// All available `image` assets.
// ignore: camel_case_types
class ImageAsset {

  // ignore: non_constant_identifier_names
  static const png = _PngAsset();

  // ignore: non_constant_identifier_names
  static const gif = _GifAsset();

}

/// All available `png` assets.
// ignore: camel_case_types
class _PngAsset {

  const _PngAsset();

  /// Asset from file: `assets/app/icon-android-google-play.png`
  // ignore: non_constant_identifier_names, unused_field
  final icon_android_google_play = const AssetImage("assets/app/icon-android-google-play.png");

  /// Asset from file: `assets/app/icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final icon = const AssetImage("assets/app/icon.png");

  /// Asset from file: `assets/app/splash.png`
  // ignore: non_constant_identifier_names, unused_field
  final splash = const AssetImage("assets/app/splash.png");

  /// Asset from file: `assets/images/backgrounds/background-red.png`
  // ignore: non_constant_identifier_names, unused_field
  final background_red = const AssetImage("assets/images/backgrounds/background-red.png");

  /// Asset from file: `assets/images/logo/logo_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final logo_icon = const AssetImage("assets/images/logo/logo_icon.png");

  /// Asset from file: `assets/images/pets/oveja1.png`
  // ignore: non_constant_identifier_names, unused_field
  final oveja1 = const AssetImage("assets/images/pets/oveja1.png");

  /// Asset from file: `assets/images/pets/ranito1.png`
  // ignore: non_constant_identifier_names, unused_field
  final ranito1 = const AssetImage("assets/images/pets/ranito1.png");

  /// Asset from file: `assets/images/pets/zorro1.png`
  // ignore: non_constant_identifier_names, unused_field
  final zorro1 = const AssetImage("assets/images/pets/zorro1.png");

  /// Asset from file: `assets/images/record/record_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final record_icon = const AssetImage("assets/images/record/record_icon.png");

  /// Asset from file: `assets/images/search/search_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final search_icon = const AssetImage("assets/images/search/search_icon.png");

  /// Asset from file: `assets/images/videos/videos_badge.png`
  // ignore: non_constant_identifier_names, unused_field
  final videos_badge = const AssetImage("assets/images/videos/videos_badge.png");

  /// Asset from file: `assets/images/chromecast/old/chromecast_active_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final chromecast_active_icon = const AssetImage("assets/images/chromecast/old/chromecast_active_icon.png");

  /// Asset from file: `assets/images/chromecast/old/chromecast_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final chromecast_icon = const AssetImage("assets/images/chromecast/old/chromecast_icon.png");

  /// Asset from file: `assets/images/record/2.0x/record_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final record_icon$1 = const AssetImage("assets/images/record/2.0x/record_icon.png");

  /// Asset from file: `assets/images/search/2.0x/search_icon.png`
  // ignore: non_constant_identifier_names, unused_field
  final search_icon$1 = const AssetImage("assets/images/search/2.0x/search_icon.png");

}

/// All available `gif` assets.
// ignore: camel_case_types
class _GifAsset {

  const _GifAsset();

  /// Asset from file: `assets/app/preload.gif`
  // ignore: non_constant_identifier_names, unused_field
  final preload = const AssetImage("assets/app/preload.gif");

}

/// All available font families.
// ignore: camel_case_types
class FontAsset {

  /// Font family: `FredokaOne`
  // ignore: non_constant_identifier_names, unused_field
  static final String fredoka_one = "FredokaOne";

}

/// All available `svg` assets.
// ignore: camel_case_types
class SvgAsset {

  /// Asset from file: `assets/images/back/back_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final back_icon = const AssetResource("assets/images/back/back_icon.svg");

  /// Asset from file: `assets/images/backgrounds/background-red.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final background_red = const AssetResource("assets/images/backgrounds/background-red.svg");

  /// Asset from file: `assets/images/chromecast/chromecast_active_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final chromecast_active_icon = const AssetResource("assets/images/chromecast/chromecast_active_icon.svg");

  /// Asset from file: `assets/images/chromecast/chromecast_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final chromecast_icon = const AssetResource("assets/images/chromecast/chromecast_icon.svg");

  /// Asset from file: `assets/images/games/games_active_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final games_active_icon = const AssetResource("assets/images/games/games_active_icon.svg");

  /// Asset from file: `assets/images/games/games_badge.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final games_badge = const AssetResource("assets/images/games/games_badge.svg");

  /// Asset from file: `assets/images/games/games_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final games_icon = const AssetResource("assets/images/games/games_icon.svg");

  /// Asset from file: `assets/images/lists/lists_active_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final lists_active_icon = const AssetResource("assets/images/lists/lists_active_icon.svg");

  /// Asset from file: `assets/images/lists/lists_badge.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final lists_badge = const AssetResource("assets/images/lists/lists_badge.svg");

  /// Asset from file: `assets/images/lists/lists_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final lists_icon = const AssetResource("assets/images/lists/lists_icon.svg");

  /// Asset from file: `assets/images/logo/logo_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final logo_icon = const AssetResource("assets/images/logo/logo_icon.svg");

  /// Asset from file: `assets/images/player_next/player_next_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final player_next_icon = const AssetResource("assets/images/player_next/player_next_icon.svg");

  /// Asset from file: `assets/images/player_next/player_next_unavailable_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final player_next_unavailable_icon = const AssetResource("assets/images/player_next/player_next_unavailable_icon.svg");

  /// Asset from file: `assets/images/player_pause/player_pause_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final player_pause_icon = const AssetResource("assets/images/player_pause/player_pause_icon.svg");

  /// Asset from file: `assets/images/player_play/player_play_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final player_play_icon = const AssetResource("assets/images/player_play/player_play_icon.svg");

  /// Asset from file: `assets/images/player_previous/player_previous_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final player_previous_icon = const AssetResource("assets/images/player_previous/player_previous_icon.svg");

  /// Asset from file: `assets/images/player_previous/player_previous_unavailable_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final player_previous_unavailable_icon = const AssetResource("assets/images/player_previous/player_previous_unavailable_icon.svg");

  /// Asset from file: `assets/images/record/record_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final record_icon = const AssetResource("assets/images/record/record_icon.svg");

  /// Asset from file: `assets/images/search/search_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final search_icon = const AssetResource("assets/images/search/search_icon.svg");

  /// Asset from file: `assets/images/series/series_active_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final series_active_icon = const AssetResource("assets/images/series/series_active_icon.svg");

  /// Asset from file: `assets/images/series/series_badge.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final series_badge = const AssetResource("assets/images/series/series_badge.svg");

  /// Asset from file: `assets/images/series/series_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final series_icon = const AssetResource("assets/images/series/series_icon.svg");

  /// Asset from file: `assets/images/videos/videos_active_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final videos_active_icon = const AssetResource("assets/images/videos/videos_active_icon.svg");

  /// Asset from file: `assets/images/videos/videos_badge.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final videos_badge = const AssetResource("assets/images/videos/videos_badge.svg");

  /// Asset from file: `assets/images/videos/videos_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final videos_icon = const AssetResource("assets/images/videos/videos_icon.svg");

  /// Asset from file: `assets/images/backgrounds/18x9/background-red.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final background_red$1 = const AssetResource("assets/images/backgrounds/18x9/background-red.svg");

  /// Asset from file: `assets/images/chromecast/old/chromecast_active_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final chromecast_active_icon$1 = const AssetResource("assets/images/chromecast/old/chromecast_active_icon.svg");

  /// Asset from file: `assets/images/chromecast/old/chromecast_icon.svg`
  // ignore: non_constant_identifier_names, unused_field
  static final chromecast_icon$1 = const AssetResource("assets/images/chromecast/old/chromecast_icon.svg");

}

/// All available `media` assets.
// ignore: camel_case_types
class MediaAsset {

  // ignore: non_constant_identifier_names
  static const mp3 = _Mp3Asset();

  // ignore: non_constant_identifier_names
  static const mp4 = _Mp4Asset();

  // ignore: non_constant_identifier_names
  static const aif = _AifAsset();

}

/// All available `mp3` assets.
// ignore: camel_case_types
class _Mp3Asset {

  const _Mp3Asset();

  /// Asset from file: `assets/sounds/background/background_1.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final background_1 = const AssetResource("assets/sounds/background/background_1.mp3");

  /// Asset from file: `assets/sounds/background/background_2.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final background_2 = const AssetResource("assets/sounds/background/background_2.mp3");

  /// Asset from file: `assets/sounds/beam/beam.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final beam = const AssetResource("assets/sounds/beam/beam.mp3");

  /// Asset from file: `assets/sounds/click/click.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final click = const AssetResource("assets/sounds/click/click.mp3");

  /// Asset from file: `assets/sounds/go_back/go_back.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final go_back = const AssetResource("assets/sounds/go_back/go_back.mp3");

  /// Asset from file: `assets/sounds/intro/intro.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final intro = const AssetResource("assets/sounds/intro/intro.mp3");

  /// Asset from file: `assets/sounds/notification/notification.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final notification = const AssetResource("assets/sounds/notification/notification.mp3");

  /// Asset from file: `assets/sounds/results/resultados.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final resultados = const AssetResource("assets/sounds/results/resultados.mp3");

  /// Asset from file: `assets/sounds/wave/wave.mp3`
  // ignore: non_constant_identifier_names, unused_field
  final wave = const AssetResource("assets/sounds/wave/wave.mp3");

}

/// All available `mp4` assets.
// ignore: camel_case_types
class _Mp4Asset {

  const _Mp4Asset();

  /// Asset from file: `assets/sounds/background/background_1.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final background_1 = const AssetResource("assets/sounds/background/background_1.mp4");

  /// Asset from file: `assets/sounds/background/background_2.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final background_2 = const AssetResource("assets/sounds/background/background_2.mp4");

  /// Asset from file: `assets/sounds/beam/beam.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final beam = const AssetResource("assets/sounds/beam/beam.mp4");

  /// Asset from file: `assets/sounds/click/click.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final click = const AssetResource("assets/sounds/click/click.mp4");

  /// Asset from file: `assets/sounds/go_back/go_back.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final go_back = const AssetResource("assets/sounds/go_back/go_back.mp4");

  /// Asset from file: `assets/sounds/intro/intro.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final intro = const AssetResource("assets/sounds/intro/intro.mp4");

  /// Asset from file: `assets/sounds/notification/notification.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final notification = const AssetResource("assets/sounds/notification/notification.mp4");

  /// Asset from file: `assets/sounds/unavailable_action/unavailable_action.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final unavailable_action = const AssetResource("assets/sounds/unavailable_action/unavailable_action.mp4");

  /// Asset from file: `assets/sounds/wave/wave.mp4`
  // ignore: non_constant_identifier_names, unused_field
  final wave = const AssetResource("assets/sounds/wave/wave.mp4");

}

/// All available `aif` assets.
// ignore: camel_case_types
class _AifAsset {

  const _AifAsset();

  /// Asset from file: `assets/sounds/click/click.aif`
  // ignore: non_constant_identifier_names, unused_field
  final click = const AssetResource("assets/sounds/click/click.aif");

  /// Asset from file: `assets/sounds/go_back/go_back.aif`
  // ignore: non_constant_identifier_names, unused_field
  final go_back = const AssetResource("assets/sounds/go_back/go_back.aif");

  /// Asset from file: `assets/sounds/notification/notification.aif`
  // ignore: non_constant_identifier_names, unused_field
  final notification = const AssetResource("assets/sounds/notification/notification.aif");

  /// Asset from file: `assets/sounds/results/resultados.aif`
  // ignore: non_constant_identifier_names, unused_field
  final resultados = const AssetResource("assets/sounds/results/resultados.aif");

  /// Asset from file: `assets/sounds/unavailable_action/unavailable_action.aif`
  // ignore: non_constant_identifier_names, unused_field
  final unavailable_action = const AssetResource("assets/sounds/unavailable_action/unavailable_action.aif");

  /// Asset from file: `assets/sounds/wave/wave.aif`
  // ignore: non_constant_identifier_names, unused_field
  final wave = const AssetResource("assets/sounds/wave/wave.aif");

}
// --- END OF GENERATED CODE BY `assets.py` ---