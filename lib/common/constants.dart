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
const String LIKE_LIST_KEY = "likelist";
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
