class Video {
  final int id;
  final String title;
  final String thumbnailUrl;
  final String videoUrl;
  final List<int> categories;

  Video(
      {this.id, this.title, this.thumbnailUrl, this.videoUrl, this.categories});

  /// Get [Video] from JSON object.
  factory Video.fromJson(Map<String, dynamic> json) {
    /// Default values
    int id = -1;
    String title = "";
    String thumbnailUrl = "";
    String videoUrl = "";
    List<int> categories = [];

    /// TODO: check if values can be null or empty.
    id = json["id"];
    title = json["title"]["rendered"];
    thumbnailUrl = json["fimg_url"];
    videoUrl = json["wpcf-vimeo-player-dl"];

    for (int i = 0; i < json["categories"].length; i++) {
      categories.add(json["categories"][i]);
    }

    return Video(
        id: id,
        title: title,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        categories: categories);
  }

  factory Video.fromDatabaseJson(Map<String, dynamic> data) => Video(
      id: data["id"],
      title: data["title"],
      thumbnailUrl: data["thumbnailUrl"],
      videoUrl: data["videoUrl"],
      categories: data["categories"]);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "title": this.title,
        "thumbnailUrl": this.thumbnailUrl,
        "videoUrl": this.videoUrl,
        "categories": this.categories
      };
}
