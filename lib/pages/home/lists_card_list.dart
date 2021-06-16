import 'package:cntvkids_app/common/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/cards/abstract_variable_card_list.dart';
import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/cards/lists_card_widget.dart';
import 'package:provider/provider.dart';

/// Shows video widgets that have 'lists' category.
class ListsCardList extends StatefulWidget {
  final double leftMargin;

  const ListsCardList({Key key, this.leftMargin = 0.0}) : super(key: key);

  @override
  _ListsCardListState createState() => _ListsCardListState();
}

class _ListsCardListState extends VariableCardListState<ListsCardList> {
  @override
  Widget cardWidget(object, index) => ListsCard(list: object);

  @override
  String get modelUrl => LISTS_URL;

  /// ListsCardList lists have category 10564.
  @override
  int get categoryId => LISTS_ID;

  @override
  List dataToCardList(data) {
    return data.map((value) => Lists.fromDatabaseJson(value)).toList();
  }

  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) {
    for (int i = 0; i < newCards.length; i++) {
      print(newCards[i].title);
    }

    /// Check if accessibility option for sign language is on.
    print(
        "Debug: bool sign lang = ${Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang} ");
    if (Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang) {
      /// Filter sign lang videos
      var contador = 1;
      for (int i = 0; i < newCards.length; i++) {
        print("Debug: number of list ${newCards.length}");
        print(
            "Debug: number of episode in list $contador, ${newCards[i].videos.length}");
        for (int j = 0; j < newCards[i].videos.length; j++) {
          if (newCards[i].videos[j].signLangVideoUrl != "") {
            newCards[i].videos[j].useSignLang = true;
          } else {
            newCards[i].videos.removeAt(j);
            j--;
          }
        }
        print(
            "Debug: number of episode with sign lang ${newCards[i].videos.length}");
        if (newCards[i].videos.length == 0) {
          newCards.removeAt(i);
          i--;
        }
        contador++;
      }
    }

    return Future.value(newCards);
  }

  @override
  double get leftMargin => widget.leftMargin;
}
