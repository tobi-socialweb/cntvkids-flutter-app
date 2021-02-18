import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:r_dart_library/asset_svg.dart';

import 'package:cntvkids_app/common/clickable_card.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/models/series_model.dart';

class SeriesCard extends StatefulWidget {
  final Series series;
  final String heroId;

  const SeriesCard({Key key, this.series, this.heroId}) : super(key: key);

  _SeriesCardState createState() => _SeriesCardState();
}

class _SeriesCardState extends ClickableCardState<SeriesCard> {
  @override
  AssetSvg Function({double height, double width}) get badge =>
      R.svg.series_badge;

  @override
  double get heightFactor => 0.7;

  @override
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.025 * size.width);

  @override
  void onTap() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Container(color: Colors.cyan);
    }));
  }

  @override
  Size get size => Size(MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * (1 - 3 * NAV_BAR_PERCENTAGE / 2));

  @override
  Widget afterThumbnailWidget() {
    return Container(
      child: Text(widget.series.title),
      /*
        width: width,
        child: Text(
          widget.series.title,
          textAlign: TextAlign.left,
          softWrap: true,
          textScaleFactor: 0.006 * height,
          style: TextStyle(color: Colors.black),
        )*/
    );
  }

  @override
  String get thumbnailUrl => widget.series.thumbnailUrl;
}
