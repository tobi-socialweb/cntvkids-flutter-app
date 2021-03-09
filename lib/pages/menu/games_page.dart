import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/widgets/cards/game_card_widget.dart';

/// Shows video widgets that have 'Games' category.
class GamesCardList extends StatefulWidget {
  final double leftMargin;

  const GamesCardList({Key key, this.leftMargin = 0.0}) : super(key: key);
  @override
  _GamesCardListState createState() => _GamesCardListState();
}

class _GamesCardListState extends VariableCardListState<GamesCardList> {
  @override
  Widget cardWidget(object, heroId, index) {
    return GameCard(
      game: object,
      heroId: heroId,
    );
  }

  @override
  String get modelUrl => GAMES_URL;

  @override
  int get categoryId => null;

  @override
  List dataToCardList(data) {
    return data.map((value) => Game.fromJson(value)).toList();
  }

  /// Remove GameCards that cannot be played by Android or iOS accordingly.
  @override
  Future<void> optionalCardManagement() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    int id = Platform.isAndroid ? ANDROID_GAMES_ID : IOS_GAMES_ID;

    for (int i = 0; i < cards.length; i++) {
      if (cards[i].categories.contains(id)) {
        cards[i].thumbnailUrl = await Game.fetchThumbnail(cards[i].mediaUrl);
      } else {
        cards.removeAt(i);
      }
    }
  }

  @override
  double get leftMargin => widget.leftMargin;
}
