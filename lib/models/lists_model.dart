import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/model_object.dart';
import 'package:cntvkids_app/models/video_model.dart';

/// Contains a list of videos.
class Lists extends BaseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<Video> videos;

  Lists({
    this.id = "-1",
    this.title = "",
    this.description = "",
    this.thumbnailUrl = "",
    this.videos,
  });

  /// Get `Lists` from JSON object.
  factory Lists.fromDatabaseJson(Map<String, dynamic> json) {
    /// Default values.
    String _id = has<String>(json["id"].toString(), "-1");

    String _title = has<String>(json["title"]["rendered"], "", comp: [""]);

    String _description =
        has<String>(json["content"]["rendered"], "", comp: [""]);

    String _thumbnailUrl =
        has<String>(json["fimg_url"], MISSING_IMAGE_URL, comp: [""]);

    List<Video> _videos = [];
    has<List<dynamic>>(json["lista_childs"], null, then: (object) {
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
            series: "",
            season: _season,
            chapter: _chapter,
            useSignLang: false,
            prev: i > 0 ? _videos[i - 1] : null,
            next: null));

        if (i > 0) _videos[i - 1].next = _videos[i];
      }
    });

    Lists obj = Lists(
      id: _id,
      title: _title,
      description: _description,
      thumbnailUrl: _thumbnailUrl,
      videos: _videos,
    );

    for (int i = 0; i < obj.videos.length; i++) {
      obj.videos[i].originInfo =
          VideoOriginInfo(type: ModelType.list, origin: obj);
    }

    return obj;
  }

  static T has<T>(T object, T value,
          {List<T> comp = const [], void Function(T object) then}) =>
      BaseModel.has(object, value, comp: comp, then: then);
}
