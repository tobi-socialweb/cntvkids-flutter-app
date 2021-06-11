import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:cntvkids_app/widgets/video_display_controller_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/cards/abstract_clickable_card.dart';
import 'package:cntvkids_app/models/video_model.dart';

/// Card widget used to display a clickable video.
class VideoCard extends StatefulWidget {
  final Video video;
  final double heightFactor;

  const VideoCard({Key key, this.video, this.heightFactor = 0.75})
      : super(key: key);

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends ClickableCardState<VideoCard> {
  String formatVideoText() {
    String result =
        (widget.video.season != "" ? "T${widget.video.season}" : "") +
            (widget.video.chapter != "" ? "E${widget.video.chapter} - " : "");

    result += "${widget.video.title}";
    return result;
  }

  @override
  AssetResource get badge => SvgAsset.videos_badge;

  @override
  String get cardText => formatVideoText();

  @override
  String get heroId => widget.video.id;

  @override
  void onTap() {
    Audio.play(MediaAsset.mp3.click);
    BackgroundMusicManager.stop();

    /// When tapped, open video.
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VideoDisplayController(
        video: widget.video,
        startFullScreen: true,
      );
    }));
  }

  @override
  String get thumbnailUrl => widget.video.thumbnailUrl;

  @override
  double get heightFactor => widget.heightFactor;
}
