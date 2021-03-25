import 'package:flutter/material.dart';

import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/common/cards/static_card_list.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

class ListsCardDetail extends StatefulWidget {
  final Lists list;
  final String heroId;
  final ImageProvider imgProvider;

  const ListsCardDetail({Key key, this.imgProvider, this.list, this.heroId})
      : super(key: key);

  _ListsCardDetailState createState() => _ListsCardDetailState();
}

class _ListsCardDetailState extends StaticCardListState<ListsCardDetail> {
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
  List get cards => widget.list.videos;

  @override
  String get description => "";

  @override
  String get title => widget.list.title;
}
