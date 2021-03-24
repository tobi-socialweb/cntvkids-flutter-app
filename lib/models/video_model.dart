import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/model_object.dart';

enum ModelType { video, series, list }

class Video extends BaseModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String signLangVideoUrl;
  final String series;
  final String season;
  final String chapter;
  final List<int> categories;
  final String type;
  VideoOriginInfo originInfo;
  bool useSignLang;
  Video next;
  Video prev;

  Video({
    this.id = "-1",
    this.title = "",
    this.thumbnailUrl = "",
    this.videoUrl = "",
    this.signLangVideoUrl = "",
    this.series = "",
    this.season = "",
    this.chapter = "",
    this.categories = const [],
    this.type = "",
    this.originInfo,
    this.useSignLang,
    this.next,
    this.prev,
  }) {
    this.originInfo = originInfo ?? VideoOriginInfo();
  }

  /// Get `Video` from JSON object.
  factory Video.fromJson(Map<String, dynamic> json,
      {VideoOriginInfo originInfo, Video prev}) {
    /// Default values
    String _id = has<String>(json["id"].toString(), "-1");

    String _title = has<String>(json["title"]["rendered"], "", comp: [""]);

    String _thumbnailUrl =
        has<String>(json["fimg_url"], MISSING_IMAGE_URL, comp: [""]);

    String _videoUrl =
        has<String>(json["wpcf-vimeo-player-dl"], "", comp: [""]);

    String _signLang = has<String>(json["wpcf-vimeo-senas-dl"], "", comp: [""]);

    String _series = has<String>(json["serie_info"]["title"], "", comp: [""]);

    String _season =
        has<String>(json["wpcf-season"].toString(), "", comp: [""]);

    String _chapter =
        has<String>(json["wpcf-chapter"].toString(), "", comp: [""]);

    String _type = has<String>(json["type"], "", comp: [""]);

    List<int> _categories = [];
    has<List<dynamic>>(json["categories"], [], then: (object) {
      for (int i = 0; i < object.length; i++) {
        _categories.add(object[i]);
      }
    });

    VideoOriginInfo _originInfo = originInfo ?? VideoOriginInfo();

    Video obj = Video(
      id: _id,
      title: _title,
      thumbnailUrl: _thumbnailUrl,
      videoUrl: _videoUrl,
      signLangVideoUrl: _signLang,
      series: _series,
      season: _season,
      chapter: _chapter,
      categories: _categories,
      type: _type,
      useSignLang: false,
      originInfo: _originInfo,
    );

    if (prev != null) {
      obj.prev = prev;
      prev.next = obj;
    }

    return obj;
  }

  static T has<T>(T object, T value,
          {List<T> comp = const [], void Function(T object) then}) =>
      BaseModel.has(object, value, comp: comp, then: then);
}

class VideoOriginInfo {
  final ModelType type;
  final dynamic origin;

  VideoOriginInfo({this.type = ModelType.video, this.origin});
}
