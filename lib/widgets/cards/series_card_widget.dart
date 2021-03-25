import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/widgets/sound_effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/pages/menu/series_detail_page.dart';

class SeriesCard extends StatefulWidget {
  final Series series;
  final String heroId;
  final double heightFactor;

  const SeriesCard(
      {Key key, this.series, this.heroId, this.heightFactor = 0.75})
      : super(key: key);

  _SeriesCardState createState() => _SeriesCardState();
}

class _SeriesCardState extends ClickableCardState<SeriesCard> {
  @override
  AssetResource get badge => SvgAsset.series_badge;

  @override
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.025 * size.width);

  SoundEffect _soundEffect;

  void initState() {
    _soundEffect = SoundEffect();

    super.initState();
  }

  @override
  void onTap() {
    _soundEffect.play(MediaAsset.mp3.click);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SeriesCardDetail(
          series: widget.series,
          heroId: widget.heroId,
          imgProvider: imgProvider);
    }));
  }

  @override
  String get cardText => widget.series.title;

  @override
  String get thumbnailUrl => widget.series.thumbnailUrl;

  @override
  String get heroId => widget.heroId;

  @override
  bool get hasTextDecoration => true;

  @override
  double get heightFactor => widget.heightFactor;
}
