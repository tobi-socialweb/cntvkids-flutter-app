import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/models/video_model.dart';

/// Contains a list of videos.
class Series {
  final int id;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String thumbnailUrl;
  final List<Video> videos;

  Series({
    this.id,
    this.title,
    this.shortDescription,
    this.longDescription,
    this.thumbnailUrl,
    this.videos,
  });

  /// Get `Series` from JSON object.
  factory Series.fromJson(Map<String, dynamic> json,
      {ModelType originModelType = ModelType.serie}) {
    /// Get values from the json object.
    int _id = has<int>(json["id"], value: -1);

    String _title = has<String>(json["title"]["rendered"], comp: [""]);

    String _shortDesc =
        has<String>(json["excerpt"]["rendered"], value: "", comp: [""]);

    String _longDesc =
        has<String>(json["content"]["rendered"], value: "", comp: [""]);

    String _thumbnailUrl =
        has<String>(json["fimg_url"], value: MISSING_IMAGE_URL, comp: [""]);

    List<Video> _videos = new List<Video>();
    has<List<dynamic>>(json["serie_childs"], then: (object) {
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
          series: _title,
          season: _season,
          chapter: _chapter,
          extra: _extra,
          originModelType: originModelType,
        ));
      }
    });

    Series obj = Series(
      id: _id,
      title: _title,
      shortDescription: _shortDesc,
      longDescription: _longDesc,
      thumbnailUrl: _thumbnailUrl,
      videos: _videos,
    );

    for (int i = 0; i < obj.videos.length; i++) {
      obj.videos[i].originSeries = obj;
    }

    return obj;
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
