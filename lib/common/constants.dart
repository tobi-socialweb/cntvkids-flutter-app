library constants;

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
