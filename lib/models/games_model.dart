import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/constants.dart';

class Game {
  final int id;
  final String title;
  final String content;
  final String gameUrl;
  final String mediaUrl;
  String thumbnailUrl;
  final List<int> categories;

  Game({
    this.id,
    this.title,
    this.content,
    this.gameUrl,
    this.categories,
    this.mediaUrl,
    this.thumbnailUrl,
  });

  /// Get [Game] from JSON object.
  factory Game.fromJson(Map<String, dynamic> json) {
    /// Default values.
    int _id = has<int>(json["id"], value: -1);

    String _title =
        has<String>(json["title"]["rendered"], value: "", comp: [""]);

    String _content =
        has<String>(json["content"]["rendered"], value: "", comp: [""]);

    String _gameUrl =
        has<String>(json["wpcf-url-juego"], value: "", comp: [""]);

    List<int> _categories = [];
    has<List<dynamic>>(json["categories"], then: (object) {
      for (int i = 0; i < object.length; i++) {
        _categories.add(object[i]);
      }
    });

    String _thumbnail = MISSING_IMAGE_URL;
    String _mediaUrl =
        has<String>(json["_links"]["wp:featuredmedia"][0]["href"], value: "");

    return Game(
      id: _id,
      title: _title,
      content: _content,
      gameUrl: _gameUrl,
      categories: _categories,
      mediaUrl: _mediaUrl,
      thumbnailUrl: _thumbnail,
    );
  }

  factory Game.fromDatabaseJson(Map<String, dynamic> data) => Game(
      id: data["id"],
      title: data["title"],
      content: data["content"],
      gameUrl: data["gameUrl"],
      categories: data["categories"],
      mediaUrl: data["mediaUrl"]);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "title": this.title,
        "content": this.content,
        "gameUrl": this.gameUrl,
        "categories": this.categories,
        "mediaUrl": this.mediaUrl,
      };

  static Future<String> fetchThumbnail(String mediaUrl) async {
    /// Try get the requested data and wait.
    try {
      Response response = await customDio.get(
        mediaUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        return response.data["source_url"];
      } else {
        return MISSING_IMAGE_URL;
      }
    } on DioError catch (e) {
      if (DioErrorType.RECEIVE_TIMEOUT == e.type ||
          DioErrorType.CONNECT_TIMEOUT == e.type) {
        /// Couldn't reach the server.
        throw (ERROR_MESSAGE[ErrorTypes.UNREACHABLE]);
      } else if (DioErrorType.RESPONSE == e.type) {
        /// If request was badly formed.
        if (e.response.statusCode == 400) {
          print("error status 400");

          /// Otherwise.
        } else {
          print(e.message);
          print(e.request.toString());
        }
      } else if (DioErrorType.DEFAULT == e.type) {
        if (e.message.contains('SocketException')) {
          /// No connection to internet.
          throw (ERROR_MESSAGE[ErrorTypes.NO_CONNECTION]);
        }
      } else {
        /// Unknown problem connecting to server.
        throw (ERROR_MESSAGE[ErrorTypes.UNKNOWN]);
      }
    }

    return Future<String>.value("");
  }

  /// Compare object to null and to the elements in `comp`, if any. Returns
  /// `object` if it's not equal to any of those things; otherwise, return
  /// `value` which by default is null. `then` gets called if `object` is
  /// returned.
  static T has<T>(T object,
      {T value, List<T> comp = const [], void Function(T object) then}) {
    if (comp.length == 0) {
      if (object != null) {
        if (then != null) then(object);
        return object;
      } else {
        return value;
      }
    } else {
      bool res = object != null;

      for (int i = 0; i < comp.length; i++) {
        res &= object != comp[i];
      }

      if (res && then != null) then(object);

      return res ? object : value;
    }
  }
}
