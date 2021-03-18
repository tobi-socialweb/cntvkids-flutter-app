import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/model_object.dart';

enum ModelType { video, series, list }

class Video extends BaseModel {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final String signLangVideoUrl;
  final String series;
  final String season;
  final String chapter;
  final String extra;
  final List<int> categories;
  final String type;
  VideoOriginInfo originInfo;

  Video({
    this.id = -1,
    this.title = "",
    this.thumbnailUrl = "",
    this.videoUrl = "",
    this.signLangVideoUrl = "",
    this.series = "",
    this.season = "",
    this.chapter = "",
    this.extra = "",
    this.categories = const [],
    this.type = "",
    this.originInfo,
  });

  /// Get `Video` from JSON object.
  factory Video.fromJson(Map<String, dynamic> json,
      {VideoOriginInfo originInfo}) {
    /// Default values
    int _id = has<int>(json["id"], -1);

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

    String _extra = (_season != "" ? "T$_season" : "") +
        (_chapter != "" ? "E$_chapter" : "");

    String _type = has<String>(json["type"], "", comp: [""]);

    List<int> _categories = [];
    has<List<dynamic>>(json["categories"], [], then: (object) {
      for (int i = 0; i < object.length; i++) {
        _categories.add(object[i]);
      }
    });

    VideoOriginInfo _originInfo = originInfo ?? VideoOriginInfo();

    return Video(
      id: _id,
      title: _title,
      thumbnailUrl: _thumbnailUrl,
      videoUrl: _videoUrl,
      signLangVideoUrl: _signLang,
      series: _series,
      extra: _extra,
      categories: _categories,
      type: _type,
      originInfo: _originInfo,
    );
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
