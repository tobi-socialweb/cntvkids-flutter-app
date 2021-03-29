import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/widgets/sound_effects.dart';
import 'package:cntvkids_app/widgets/video_display_controller_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/background_music.dart';

/// Card widget used to display a clickable video.
class SuggestedVideoCard extends StatefulWidget {
  final Video video;

  const SuggestedVideoCard({Key key, this.video}) : super(key: key);

  @override
  _SuggestedVideoCardState createState() => _SuggestedVideoCardState();
}

class _SuggestedVideoCardState extends ClickableCardState<SuggestedVideoCard> {
  String formatVideoText() => "";

  @override
  AssetResource get badge => SvgAsset.videos_badge;

  @override
  String get heroId => widget.video.id;

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
      return VideoDisplayController(
        video: widget.video,
      );
    }));
  }

  @override
  String get thumbnailUrl => widget.video.thumbnailUrl;

  @override
  double get heightFactor => 1.0; // widget.heightFactor;

  @override
  Size get size => MediaQuery.of(context).size;

  @override
  String get cardText => null;

  @override
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.005 * size.width);
}
