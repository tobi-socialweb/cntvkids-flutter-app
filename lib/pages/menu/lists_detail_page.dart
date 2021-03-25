import 'package:flutter/material.dart';

import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/common/cards/static_card_list.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

class ListsCardDetail extends StatefulWidget {
  final Lists list;
  final ImageProvider imgProvider;

  const ListsCardDetail({Key key, this.imgProvider, this.list})
      : super(key: key);

  _ListsCardDetailState createState() => _ListsCardDetailState();
}

class _ListsCardDetailState extends StaticCardListState<ListsCardDetail> {
  @override
  String get avatarHeroId => widget.list.id;

  @override
  ImageProvider<Object> get avatarImgProvider => widget.imgProvider;

  @override
  Color get blobColor => Colors.cyan;

  @override
  Widget cardWidget(object) => VideoCard(video: object);

  @override
  List get cards => widget.list.videos;

  @override
  String get description => "";

  @override
  String get title => widget.list.title;

  @override
  void setPlayerEffects() {}
}
