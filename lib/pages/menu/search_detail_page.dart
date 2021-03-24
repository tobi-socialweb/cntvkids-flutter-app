import 'dart:async';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/cards/suggested_video_card_widget.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum modelType { video, serie, lista }

/// Shows videos 'searched'
class SearchCardList extends StatefulWidget {
  final String search;
  final bool isMinimized;
  final Video video;
  final double leftMargin;

  SearchCardList(
      {this.search,
      this.isMinimized = false,
      this.video,
      this.leftMargin = 0.0});

  @override
  _SearchCardListState createState() => _SearchCardListState();
}

class _SearchCardListState extends VariableCardListState<SearchCardList> {
  bool sent = false;
  @override
  Widget cardWidget(object, String heroId, index) {
    return widget.isMinimized == false
        ? VideoCard(
            video: object,
            heroId: heroId,
          )
        : SuggestedVideoCard(
            video: object,
            heroId: heroId,
          );
  }

  @override
  String get modelUrl => "$VIDEOS_URL&search=${widget.search}";

  @override
  int get categoryId => null;

  @override
  List<dynamic> dataToCardList(data) {
    if (widget.video == null || widget.video.originInfo.origin == null) {
      return data.map((value) => Video.fromJson(value)).toList();
    } else {
      if (sent) return [];
      sent = true;
      return widget.video.originInfo.origin;
    }
  }

  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) async {
    for (int i = 0; i < newCards.length; i++) {
      if (newCards[i].type == "series") {
        newCards.removeAt(i);
        i--;
      }
      if (widget.isMinimized && newCards[i].id == widget.video.id) {
        newCards.removeAt(i);
        i--;
      }
    }
    return newCards;
  }

  @override
  double get leftMargin => widget.leftMargin;
}
