
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/widgets/sound_effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/video_display_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';

/// Card widget used to display a clickable video.
class SuggestedVideoCard extends StatefulWidget {
  final Video video;
  final String heroId;
  final double heightFactor;

  const SuggestedVideoCard(
      {Key key, this.video, this.heroId, this.heightFactor = 0.25})
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
  AssetResource get badge => SvgAsset.videos_badge;

  @override
  String get heroId => widget.heroId;

  SoundEffect _soundEffect;

  void initState() {
    _soundEffect = SoundEffect();
    super.initState();
  }

  @override
  void onTap() {
    _soundEffect.play(MediaAsset.mp3.click);
    BackgroundMusicManager.instance.music.stopMusic();

    Navigator.pop(context);

    /// When tapped, open video.
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return VideoDisplay(
        video: widget.video,
        heroId: widget.heroId,
      );
    }));
  }

  @override
  String get thumbnailUrl => widget.video.thumbnailUrl;

  @override
  double get heightFactor => widget.heightFactor;

  @override
  Size get size => MediaQuery.of(context).size;

  @override
  String get cardText => null;

  @override
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.005 * size.width);
}
