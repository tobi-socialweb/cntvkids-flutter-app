import 'dart:async';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart'
    show BallSpinFadeLoaderIndicator;

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
    if (widget.video == null ||
        widget.video.originModelType == ModelType.video) {
      return data
          .map((value) =>
              Video.fromJson(value, originModelType: ModelType.video))
          .toList();
    } else {
      return (widget.video.originSeries != null)
          ? widget.video.originSeries.videos
          : widget.video.originList.videos;
    }
  }

  @override
  Future<void> optionalCardManagement() async {
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].type == "series") {
        cards.removeAt(i);
      }
      if (widget.isMinimized && cards[i].id == widget.video.id) {
        cards.removeAt(i);
      }
    }
    return cards;
  }

  @override
  double get leftMargin => widget.leftMargin;

  @override
  Widget loadingWidget(size) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.05 * size.height),
      child: Loading(
          indicator: BallSpinFadeLoaderIndicator(),
          size: 0.225 * size.height,
          color: Colors.white),
    );
  }
}
