import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/models/series_model.dart';

enum ModelType { video, serie, lista }

class Video {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String series;
  final String season;
  final String chapter;
  final String extra;
  final List<int> categories;
  final String type;
  final ModelType originModelType;
  Series originSeries;
  Lists originList;

  Video({
    this.id,
    this.title,
    this.thumbnailUrl,
    this.videoUrl,
    this.series,
    this.season,
    this.chapter,
    this.extra,
    this.categories,
    this.type,
    this.originModelType,
    this.originSeries,
    this.originList,
  });

  /// Get `Video` from JSON object.
  factory Video.fromJson(Map<String, dynamic> json,
      {ModelType originModelType = ModelType.video,
      Series originSeries,
      Lists originList}) {
    /// Default values
    int _id = has<int>(json["id"], value: -1);

    String _title =
        has<String>(json["title"]["rendered"], value: "", comp: [""]);

    String _thumbnailUrl =
        has<String>(json["fimg_url"], value: MISSING_IMAGE_URL, comp: [""]);

    String _videoUrl =
        has<String>(json["wpcf-vimeo-player-dl"], value: "", comp: [""]);

    String _series = has<String>(json["serie_info"]["title"], comp: [""]);

    String _season =
        has<String>(json["wpcf-season"].toString(), value: "", comp: [""]);

    String _chapter =
        has<String>(json["wpcf-chapter"].toString(), value: "", comp: [""]);

    String _extra = (_season != "" ? "T$_season" : "") +
        (_chapter != "" ? "E$_chapter" : "");

    String _type = has<String>(json["type"], value: "", comp: [""]);

    List<int> _categories = new List<int>();
    has<List<dynamic>>(json["categories"], then: (object) {
      for (int i = 0; i < object.length; i++) {
        _categories.add(object[i]);
      }
    });

    return Video(
      id: _id,
      title: _title,
      thumbnailUrl: _thumbnailUrl,
      videoUrl: _videoUrl,
      series: _series,
      extra: _extra,
      categories: _categories,
      type: _type,
      originModelType: originModelType,
      originList: originList,
      originSeries: originSeries,
    );
  }

  factory Video.fromDatabaseJson(Map<String, dynamic> data) => Video(
      id: data["id"],
      title: data["title"],
      thumbnailUrl: data["thumbnailUrl"],
      videoUrl: data["videoUrl"],
      series: data["series"],
      extra: data["extra"],
      categories: data["categories"],
      type: data["type"]);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "title": this.title,
        "thumbnailUrl": this.thumbnailUrl,
        "videoUrl": this.videoUrl,
        "series": this.series,
        "extra": this.extra,
        "categories": this.categories,
        "type": this.type,
      };

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
