import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/video_display_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';

/// Card widget used to display a clickable video.
class SuggestedVideoCard extends StatefulWidget {
  final Video video;
  final String heroId;

  const SuggestedVideoCard({Key key, this.video, this.heroId})
      : super(key: key);

  @override
  _SuggestedVideoCardState createState() => _SuggestedVideoCardState();
}

class _SuggestedVideoCardState extends ClickableCardState<SuggestedVideoCard> {
  String formatVideoText() {
    String result = "";

    if (widget.video.series != "") result += "${widget.video.series}\n";
    if (widget.video.extra != "") result += "${widget.video.extra} - ";

    result += widget.video.title;
    return result;
  }

  @override
  String get badge => SvgAsset.videos_badge;

  @override
  String get heroId => widget.heroId;

  @override
  void onTap() {
    BackgroundMusicManager.instance.music.stopMusic();

    /// When tapped, open video.
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VideoDisplay(
        video: widget.video,
        heroId: widget.heroId,
      );
    }));
  }

  @override
  String get thumbnailUrl => widget.video.thumbnailUrl;

  @override
  double get heightFactor => 0.25;

  @override
  Size get size => MediaQuery.of(context).size;

  @override
  String get cardText => null;

  @override
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.005 * size.width);
}
