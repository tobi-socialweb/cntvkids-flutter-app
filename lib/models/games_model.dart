import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/model_object.dart';

class Game extends BaseModel {
  final String id;
  final String title;
  final String content;
  final String gameUrl;
  final String mediaUrl;
  String thumbnailUrl;
  final List<int> categories;

  Game({
    this.id = "-1",
    this.title = "",
    this.content = "",
    this.gameUrl = "",
    this.mediaUrl = "",
    this.thumbnailUrl = "",
    this.categories,
  });

  /// Get [Game] from JSON object.
  factory Game.fromDatabaseJson(Map<String, dynamic> json) {
    /// Default values.
    String _id = has<String>(json["id"].toString(), "-1");

    String _title =
        clean(has<String>(json["title"]["rendered"], "", comp: [""]));

    String _content =
        clean(has<String>(json["content"]["rendered"], "", comp: [""]));

    String _gameUrl = has<String>(json["wpcf-url-juego"], "", comp: [""]);

    List<int> _categories = [];
    has<List<dynamic>>(json["categories"], null, then: (object) {
      for (int i = 0; i < object.length; i++) {
        _categories.add(object[i]);
      }
    });

    String _thumbnail = MISSING_IMAGE_URL;
    String _mediaUrl =
        has<String>(json["_links"]["wp:featuredmedia"][0]["href"], "");

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

  static T has<T>(T object, T value,
          {List<T> comp = const [], void Function(T object) then}) =>
      BaseModel.has(object, value, comp: comp, then: then);
  static String clean(String input) => BaseModel.clean(input);
}
