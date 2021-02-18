import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/constants.dart';

class Game {
  final int id;
  final String guid;
  final String title;
  final String content;
  final String gameUrl;
  final List<int> categories;
  String mediaUrl;

  Game(
      {this.id,
      this.guid,
      this.title,
      this.content,
      this.gameUrl,
      this.categories,
      this.mediaUrl});

  /// Get [Game] from JSON object.
  factory Game.fromJson(Map<String, dynamic> json) {
    /// Default values
    int id = -1;
    String guid = "";
    String title = "";
    String content = "";
    String gameUrl = "";
    List<int> categories = [];
    String mediaUrl = "";
    //
    id = json["id"];
    guid = (json["guid"] != null) ? json["title"]["rendered"] : "";
    title = (json["title"] != null) ? json["title"]["rendered"] : "";
    content = (json["content"] != null) ? json["content"]["rendered"] : "";
    gameUrl = json["wpcf-url-juego"];
    for (int i = 0; i < json["categories"].length; i++) {
      categories.add(json["categories"][i]);
    }
    mediaUrl = (json["_links"]["wp:featuredmedia"][0]["href"] != null)
        ? json["_links"]["wp:featuredmedia"][0]["href"]
        : "";
    return Game(
      id: id,
      guid: guid,
      title: title,
      content: content,
      gameUrl: gameUrl,
      categories: categories,
      mediaUrl: mediaUrl,
    );
  }

  factory Game.fromDatabaseJson(Map<String, dynamic> data) => Game(
      id: data["id"],
      guid: data["guid"],
      title: data["title"],
      content: data["content"],
      gameUrl: data["gameUrl"],
      categories: data["categories"],
      mediaUrl: data["mediaUrl"]);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "guid": this.guid,
        "title": this.title,
        "content": this.content,
        "gameUrl": this.gameUrl,
        "categories": this.categories,
        "mediaUrl": this.mediaUrl,
      };

  Future<String> fetchMedia(String url) async {
    /// Try get the requested data and wait.
    try {
      String requestUrl = "$url";

      Response response = await customDio.get(
        requestUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        return response.data["source_url"];
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
    return "";
  }
}
