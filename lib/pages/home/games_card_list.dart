import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/cards/abstract_variable_card_list.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/cards/game_card_widget.dart';

/// Shows video widgets that have 'Games' category.
class GamesCardList extends StatefulWidget {
  final double leftMargin;

  const GamesCardList({Key key, this.leftMargin = 0.0}) : super(key: key);
  @override
  _GamesCardListState createState() => _GamesCardListState();
}

class _GamesCardListState extends VariableCardListState<GamesCardList> {
  @override
  Widget cardWidget(object, index) => GameCard(game: object);

  @override
  String get modelUrl => GAMES_URL;

  @override
  int get categoryId => null;

  @override
  List dataToCardList(data) {
    return data.map((value) => Game.fromDatabaseJson(value)).toList();
  }

  /// Remove GameCards that cannot be played by Android or iOS accordingly.
  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) async {
    if (!Platform.isAndroid && !Platform.isIOS) return [];

    int id = Platform.isAndroid ? ANDROID_GAMES_ID : IOS_GAMES_ID;

    for (int i = 0; i < newCards.length; i++) {
      if (newCards[i].categories.contains(id)) {
        newCards[i].thumbnailUrl =
            await Game.fetchThumbnail(newCards[i].mediaUrl);
      } else {
        newCards.removeAt(i);
        i--;
      }
    }
    return newCards;
  }

  @override
  double get leftMargin => widget.leftMargin;
}
