library constants;

/// The wordpress site url.
const String WORDPRESS_URL = "https://cntvinfantil.cl";

/// The differentiating parts of request urls.
const String VIDEOS_URL = "$WORDPRESS_URL/wp-json/wp/v2/videos?_embed";
const String GAMES_URL = "$WORDPRESS_URL/wp-json/wp/v2/juegos?_embed";
const String SERIES_URL = "$WORDPRESS_URL/wp-json/wp/v2/series?_embed";
const String LISTS_URL = "$WORDPRESS_URL/wp-json/wp/v2/listas?_embed";

/// Error messages to display.
enum ErrorTypes { NO_CONNECTION, NO_LAUNCH, UNREACHABLE, UNKNOWN }
const Map<ErrorTypes, String> ERROR_MESSAGE = {
  ErrorTypes.NO_CONNECTION: "Sin conexión a internet.",
  ErrorTypes.NO_LAUNCH: "No se pudo iniciar ",
  ErrorTypes.UNREACHABLE:
      "No se pudo alcansar el servidor. Por favor, verifique su conexión a internet e inténtelo de nuevo.",
  ErrorTypes.UNKNOWN:
      "Hubo un problema para conectarse con el servidor. Por favor, inténtelo de nuevo.",
};

/// Missing image url.
const String MISSING_IMAGE_URL =
    "$WORDPRESS_URL/cntv/wp-content/uploads/2019/09/noimage-1.jpg";

/// Featured category ID (for Home Screen top section)
const int FEATURED_ID = 10536;

/// Height percentage of the navigation bar that takes up.
const double NAV_BAR_PERCENTAGE = 0.2;

// Tab 2 page category name
const String PAGE2_CATEGORY_NAME = "Lifestyle";

// Tab 2 page category ID
const int PAGE2_CATEGORY_ID = 6;

// Custom categories in search tab
// Array in format
// ["Category Name", "Image Link", "Category ID"]
const List<dynamic> CUSTOM_CATEGORIES = [
  ["Lifestyle", "assets/boxed/lifestyle.png", 6],
  ["Fashion", "assets/boxed/fashion.png", 12],
  ["Music", "assets/boxed/music.png", 14],
  ["Photography", "assets/boxed/photography.png", 15],
  ["Sport", "assets/boxed/sport.png", 13],
  ["World", "assets/boxed/world.png", 11],
  ["Health", "assets/boxed/health.png", 8],
  ["Travel", "assets/boxed/travel.png", 7],
  ["Recipies", "assets/boxed/recipies.png", 10],
];

const String ONE_SIGNAL_APP_ID = "45e71839-7d7b-445a-b325-b9009d92171e";

const bool ENABLE_ADS = false;
const String ADMOB_ID = "ca-app-pub-3940256099942544~3347511713";
const String ADMOB_BANNER_ID_1 = "ca-app-pub-3940256099942544/6300978111";

const bool ENABLE_DYNAMIC_LINK = false;
