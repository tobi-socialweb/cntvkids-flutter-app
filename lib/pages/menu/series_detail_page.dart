import 'package:flutter/material.dart';

import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/common/cards/static_card_list.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

class SeriesCardDetail extends StatefulWidget {
  final Series series;
  final String heroId;
  final ImageProvider imgProvider;

  const SeriesCardDetail({
    Key key,
    this.imgProvider,
    this.series,
    this.heroId,
  }) : super(key: key);

  _SeriesCardDetailState createState() => _SeriesCardDetailState();
}

class _SeriesCardDetailState extends StaticCardListState<SeriesCardDetail> {
  @override
  String get avatarHeroId => widget.heroId;

  @override
  ImageProvider<Object> get avatarImgProvider => widget.imgProvider;

  @override
  Color get blobColor => Colors.cyan;

  @override
  Widget cardWidget(object, String heroId) {
    return VideoCard(
      video: object,
      heroId: heroId,
    );
  }

  @override
  List get cards => widget.series.videos;

  @override
  String get description => widget.series.shortDescription;

  @override
  String get title => widget.series.title;
}
