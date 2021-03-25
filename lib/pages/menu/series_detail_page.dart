import 'package:flutter/material.dart';

import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/common/cards/static_card_list.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

class SeriesCardDetail extends StatefulWidget {
  final Series series;
  final ImageProvider imgProvider;

  const SeriesCardDetail({
    Key key,
    this.imgProvider,
    this.series,
  }) : super(key: key);

  _SeriesCardDetailState createState() => _SeriesCardDetailState();
}

class _SeriesCardDetailState extends StaticCardListState<SeriesCardDetail> {
  @override
  String get avatarHeroId => widget.series.id;

  @override
  ImageProvider<Object> get avatarImgProvider => widget.imgProvider;

  @override
  Color get blobColor => Colors.cyan;

  @override
  Widget cardWidget(object) => VideoCard(video: object);

  @override
  List get cards => widget.series.videos;

  @override
  String get description => widget.series.shortDescription;

  @override
  String get title => widget.series.title;
}
