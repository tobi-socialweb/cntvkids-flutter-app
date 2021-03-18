import 'package:cntvkids_app/common/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/pages/menu/lists_detail_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';

class ListsCard extends StatefulWidget {
  final Lists list;
  final String heroId;
  final double heightFactor;

  const ListsCard({Key key, this.list, this.heroId, this.heightFactor = 0.75})
      : super(key: key);

  @override
  _ListsCardState createState() => _ListsCardState();
}

class _ListsCardState extends ClickableCardState<ListsCard> {
  @override
  AssetResource get badge => SvgAsset.lists_badge;

  @override
  String get heroId => widget.heroId;

  @override
  void onTap() {
    MusicEffect.play(MediaAsset.mp3.click);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ListsCardDetail(
          list: widget.list, heroId: widget.heroId, imgProvider: imgProvider);
    }));
  }

  @override
  String get thumbnailUrl => widget.list.thumbnailUrl;

  @override
  String get cardText => widget.list.title;

  @override
  bool get hasTextDecoration => true;

  @override
  double get heightFactor => widget.heightFactor;
}
