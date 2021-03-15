import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/common/helpers.dart';
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
  String get badge => SvgAsset.series_badge;

  @override
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.025 * size.width);

  @override
  void onTap() {
    playSound("sounds/click/click.mp3");
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
