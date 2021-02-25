import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/models/video_model.dart';

/// Contains a list of videos.
class Lists {
  final int id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<Video> videos;

  Lists(
      {this.id, this.title, this.description, this.thumbnailUrl, this.videos});

  /// Get `Lists` from JSON object.
  factory Lists.fromJson(Map<String, dynamic> json) {
    /// Default values.
    int _id = has<int>(json["id"], value: -1);

    String _title =
        has<String>(json["title"]["rendered"], value: "Serie", comp: [""]);

    String _description =
        has<String>(json["content"]["rendered"], value: "", comp: [""]);

    String _thumbnailUrl =
        has<String>(json["fimg_url"], value: MISSING_IMAGE_URL, comp: [""]);

    List<Video> _videos = new List<Video>();
    has<List<dynamic>>(json["lista_childs"], then: (object) {
      String _season;
      String _chapter;
      String _extra;

      for (int i = 0; i < object.length; i++) {
        _season = has<String>(object[i]["season"], value: "", comp: [""]);
        _chapter = has<String>(object[i]["chapter"], value: "", comp: [""]);

        _extra = (_season != "" ? "T$_season" : "") +
            (_chapter != "" ? "E$_chapter" : "");

        _videos.add(Video(
            id: has<int>(object[i]["id"], value: -1),
            title: has<String>(object[i]["title"], value: "", comp: [""]),
            thumbnailUrl: has<String>(object[i]["image"],
                value: MISSING_IMAGE_URL, comp: [""]),
            videoUrl: has<String>(object[i]["dl"], comp: [""]),
            series: "",
            season: _season,
            chapter: _chapter,
            extra: _extra));
      }
    });

    return Lists(
      id: _id,
      title: _title,
      description: _description,
      thumbnailUrl: _thumbnailUrl,
      videos: _videos,
    );
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