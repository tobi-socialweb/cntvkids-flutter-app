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
  final bool isMinimized;
  final String search;
  final int id;
  final modelType type;

  SearchCardList({this.isMinimized = false, this.search, this.id, this.type});

  @override
  _SearchCardListState createState() => _SearchCardListState();
}

class _SearchCardListState extends VariableCardListState<SearchCardList> {
  @override
  Widget cardWidget(object, String heroId) {
    if (widget.isMinimized == false) {
      return VideoCard(
        video: object,
        heroId: heroId,
      );
    } else {
      return SuggestedVideoCard(
        video: object,
        heroId: heroId,
      );
    }
  }

  @override
  int get categoryId => null;

  @override
  List dataToCardList(data) {
    return data.map((value) => Video.fromJson(value)).toList();
  }

  @override
  String get modelUrl => "$VIDEOS_URL&search=${widget.search}";

  @override
  Future<void> optionalCardManagement() async {
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].type == "series") {
        cards.removeAt(i);
      } else if (widget.isMinimized && cards[i].id == widget.id) {
        cards.removeAt(i);
      }
    }
    return cards;
  }
}
