import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/cards/abstract_variable_card_list.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/cards/video_card_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows video widgets that have 'featured' category.
class FeaturedCardList extends StatefulWidget {
  final bool isMinimized;
  final double leftMargin;
  final double contador;
  const FeaturedCardList(
      {Key key, this.isMinimized = false, this.leftMargin = 0.0, this.contador})
      : super(key: key);

  @override
  _FeaturedCardListState createState() => _FeaturedCardListState();
}

class _FeaturedCardListState extends VariableCardListState<FeaturedCardList> {
  @override
  Widget cardWidget(object, index) => VideoCard(video: object);

  @override
  String get modelUrl => VIDEOS_URL;

  /// FeaturedCardList videos have category 10536.
  @override
  int get categoryId => FEATURED_ID;

  @override
  List dataToCardList(data) {
    return data.map((value) => Video.fromDatabaseJson(value)).toList();
  }

  @override
  double get leftMargin => widget.leftMargin;

  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) async {
    /// Check if accessibility option for sign language is on.
    bool isUsingSignLang;

    if (context != null) {
      isUsingSignLang =
          Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang;
    }

    newCards = newCards.where((video) {
      bool delete = false;
      if (isUsingSignLang) {
        delete = video.signLangVideoUrl == "";
      }
      return !delete;
    }).toList();

    newCards.forEach((video) {
      video.useSignLang = isUsingSignLang;
    });

    for (int i = 0; i < newCards.length; i++) {
      newCards[i].next = newCards[(i + 1) % newCards.length];
      newCards[i].prev = newCards[(i - 1 + newCards.length) % newCards.length];
    }

    return newCards;
  }
}
