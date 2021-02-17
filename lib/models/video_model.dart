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

  Video(
      {this.id,
      this.title,
      this.thumbnailUrl,
      this.videoUrl,
      this.series,
      this.season,
      this.chapter,
      this.extra,
      this.categories});

  /// Get `Video` from JSON object.
  factory Video.fromJson(Map<String, dynamic> json) {
    /// Default values
    int id = -1;
    String title = "";
    String thumbnailUrl = "";
    String videoUrl = "";
    String series = "";
    String season = "";
    String chapter = "";
    String extra = "";

    List<int> categories = [];

    /// TODO: Check if values can be null or empty.
    id = json["id"];
    title = (json["title"] != null) ? json["title"]["rendered"] : "";
    thumbnailUrl = json["fimg_url"];
    videoUrl = json["wpcf-vimeo-player-dl"];
    series = json["serie_info"]["title"];

    season = json["wpcf-season"].toString();
    chapter = json["wpcf-chapter"].toString();
    extra = "T${season}E$chapter";

    for (int i = 0; i < json["categories"].length; i++) {
      categories.add(json["categories"][i]);
    }

    return Video(
      id: id,
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: videoUrl,
      series: series,
      extra: extra,
      categories: categories,
    );
  }

  factory Video.fromDatabaseJson(Map<String, dynamic> data) => Video(
      id: data["id"],
      title: data["title"],
      thumbnailUrl: data["thumbnailUrl"],
      videoUrl: data["videoUrl"],
      series: data["series"],
      extra: data["extra"],
      categories: data["categories"]);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "title": this.title,
        "thumbnailUrl": this.thumbnailUrl,
        "videoUrl": this.videoUrl,
        "series": this.series,
        "extra": this.extra,
        "categories": this.categories
      };
}
