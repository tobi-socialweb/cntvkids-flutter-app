import 'dart:async';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/app_state_config.dart';
import 'package:cntvkids_app/widgets/cards/suggested_video_card_widget.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

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

    /// Itererate through all new cards.
    for (int i = 0; i < newCards.length; i++) {
      /// Remove if the result is not a video.
      if (newCards[i].type == "series") newCards.removeAt(i--);

      /// Remove if the result is the same video being displayed.
      if (widget.isMinimized && newCards[i].id == widget.video.id)
        newCards.removeAt(i--);

      if (isUsingSignLang) {
        /// Set value as true by default.
        newCards[i].useSignLang = true;

        /// Remove if video does not have sign language available.
        if (newCards[i].signLangVideoUrl == "") newCards.removeAt(i--);
      }

      /// If the current card is the first in the list.
      if (i == 0 && cards.length > 0) {
        /// Assign first card in [newCards] as the `next` for the last one
        /// in [cards].
        cards[cards.length - 1].next = newCards[i];

        /// Otherwise any other card.
      } else if (i > 0) {
        newCards[i].prev = newCards[i - 1];
        newCards[i - 1].next = newCards[i];
      }
    }

    return newCards;
  }

  @override
  double get leftMargin => widget.leftMargin;
}
