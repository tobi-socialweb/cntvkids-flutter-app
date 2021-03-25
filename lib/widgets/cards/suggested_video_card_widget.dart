import 'package:cntvkids_app/common/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/video_display_page.dart';
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

  @override
  void onTap() {
    MusicEffect.play(MediaAsset.mp3.click);
    Navigator.pop(context);

    /// When tapped, open video.
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return VideoDisplay(
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
