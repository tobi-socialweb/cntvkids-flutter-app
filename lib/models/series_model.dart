import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/model_object.dart';
import 'package:cntvkids_app/models/video_model.dart';

/// Contains a list of videos.
class Series extends BaseModel {
  final String id;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String thumbnailUrl;
  final List<Video> videos;

  Series({
    this.id = "",
    this.title = "",
    this.shortDescription = "",
    this.longDescription = "",
    this.thumbnailUrl = "",
    this.videos,
  });

  /// Get `Series` from JSON object.
  factory Series.fromJson(Map<String, dynamic> json) {
    /// Get values from the json object.
    String _id = has<String>(json["id"].toString(), "-1");

    String _title = has<String>(json["title"]["rendered"], "", comp: [""]);

    String _shortDesc =
        has<String>(json["excerpt"]["rendered"], "", comp: [""]);

    String _longDesc = has<String>(json["content"]["rendered"], "", comp: [""]);

    String _thumbnailUrl =
        has<String>(json["fimg_url"], MISSING_IMAGE_URL, comp: [""]);

    List<Video> _videos = [];
    has<List<dynamic>>(json["serie_childs"], null, then: (object) {
      String _season;
      String _chapter;

      for (int i = 0; i < object.length; i++) {
        _season = has<String>(object[i]["season"], "", comp: [""]);
        _chapter = has<String>(object[i]["chapter"], "", comp: [""]);

        _videos.add(Video(
          id: has<String>(object[i]["id"].toString(), "-1"),
          title: has<String>(object[i]["title"], "", comp: [""]),
          thumbnailUrl:
              has<String>(object[i]["image"], MISSING_IMAGE_URL, comp: [""]),
          videoUrl: has<String>(object[i]["dl"], "", comp: [""]),
          signLangVideoUrl: has<String>(object[i]["dlsenas"], "", comp: [""]),
          series: _title,
          season: _season,
          chapter: _chapter,
          useSignLang: false,
          prev: i > 0 ? object[i - 1] : null,
          next: i < object.length - 1 ? object[i + 1] : null,
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
      obj.videos[i].originInfo =
          VideoOriginInfo(type: ModelType.series, origin: obj);
    }

    return obj;
  }

  static T has<T>(T object, T value,
          {List<T> comp = const [], void Function(T object) then}) =>
      BaseModel.has(object, value, comp: comp, then: then);
}
