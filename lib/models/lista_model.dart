import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/models/video_model.dart';

/// Contains a list of videos.
class Series {
  final int id;
  final String title;
  final String content;
  final String thumbnailUrl;
  final List<Video> videos;

  Series({this.id, this.title, this.content, this.thumbnailUrl, this.videos});

  /// Get `Series` from JSON object.
  factory Series.fromJson(Map<String, dynamic> json) {
    /// Default values;
    int _id = has<int>(json["id"], value: -1);
    String _title = has<String>(json["title"]["rendered"], value: "Serie");
    String _content = has<String>(json["content"]["rendered"]);
    String _thumbnailUrl =
        has<String>(json["fimg_url"], value: MISSING_IMAGE_URL);

    List<Video> _videos = new List<Video>();

    List<dynamic> children = json["serie_childs"];
    if (children != null) {
      String _season;
      String _chapter;
      String _extra;
      for (int i = 0; i < children.length; i++) {
        _season = has<String>(children[i]["season"]);
        _chapter = has<String>(children[i]["chapter"]);

        _extra = (_season != "" ? "T$_season" : "") +
            (_chapter != "" ? "E$_chapter" : "");

        _videos.add(Video(
            id: children[i]["id"],
            title: children[i]["title"],
            thumbnailUrl:
                has<String>(children[i]["image"], value: MISSING_IMAGE_URL),
            videoUrl: children[i]["dl"],
            series: "",
            season: _season,
            chapter: _chapter,
            extra: _extra));
      }
    }

    return Series(
      id: _id,
      title: _title,
      content: _content,
      thumbnailUrl: _thumbnailUrl,
      videos: _videos,
    );
  }

  /// Checks if object is null or empty. If null, return `value`, otherwise
  /// return the object.
  static T has<T>(T object, {T value}) {
    if (T is String) {
      return (object != null && object != "")
          ? object
          : (value == null ? "" : value);
    } else {
      return object != null ? object : value;
    }
  }
}
