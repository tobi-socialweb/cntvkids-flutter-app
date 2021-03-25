import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/app_state_config.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

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
    return data.map((value) => Video.fromJson(value)).toList();
  }

  @override
  double get leftMargin => widget.leftMargin;

  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) async {
    /// Check if accessibility option for sign language is on.
    final bool isUsingSignLang =
        Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang;

    /// Itererate through all new cards.
    for (int i = 0; i < newCards.length; i++) {
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
}
