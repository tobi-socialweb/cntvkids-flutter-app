import 'dart:async';
import 'package:cntvkids_app/cards/abstract_variable_card_list.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/cards/suggested_video_card_widget.dart';
import 'package:cntvkids_app/cards/video_card_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows videos 'searched'
class SearchCardList extends StatefulWidget {
  final String search;
  final bool isMinimized;
  final Video video;
  final double leftMargin;
  final double heightFactor;

  SearchCardList({
    this.search,
    this.isMinimized = false,
    this.video,
    this.leftMargin = 0.0,
    this.heightFactor = 0.75,
  });

  @override
  _SearchCardListState createState() => _SearchCardListState();
}

class _SearchCardListState extends VariableCardListState<SearchCardList> {
  bool sent = false;

  @override
  Widget cardWidget(object, index) {
    return widget.isMinimized == false
        ? VideoCard(video: object, heightFactor: widget.heightFactor)
        : SuggestedVideoCard(video: object);
  }

  @override
  String get modelUrl => "$VIDEOS_URL&search=${widget.search}";

  @override
  int get categoryId => null;

  @override
  List<dynamic> dataToCardList(data) {
    if (widget.video.originInfo.origin == null) {
      return data.map((value) => Video.fromDatabaseJson(value)).toList();
    } else {
      if (sent) return [];
      sent = true;
      return List.from(widget.video.originInfo.origin.videos);
    }
  }

  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) async {
    /// Check if accessibility option for sign language is on.
    final bool isUsingSignLang =
        Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang;

    newCards = newCards.where((e) {
      bool delete = false;
      delete = e.type == "series";
      delete = widget.isMinimized && e.id == widget.video.id;
      if (isUsingSignLang) {
        delete = e.signLangVideoUrl == "";
      }
      return !delete;
    }).toList();

    newCards.forEach((e) {
      e.useSignLang = isUsingSignLang;
    });

    for (int i = 0; i < newCards.length; i++) {
      newCards[i].next = newCards[(i + 1) % newCards.length];
      newCards[i].prev = newCards[(i - 1 + newCards.length) % newCards.length];
    }

    return newCards;
  }

  @override
  double get leftMargin => widget.leftMargin;
}
