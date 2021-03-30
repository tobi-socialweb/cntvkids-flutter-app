import 'package:cntvkids_app/common/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/cards/abstract_variable_card_list.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/cards/series_card_widget.dart';
import 'package:provider/provider.dart';

/// Shows video widgets that have 'lists' category.
class SeriesCardList extends StatefulWidget {
  final double leftMargin;

  const SeriesCardList({Key key, this.leftMargin = 0.0}) : super(key: key);

  @override
  _SeriesCardListState createState() => _SeriesCardListState();
}

class _SeriesCardListState extends VariableCardListState<SeriesCardList> {
  @override
  Widget cardWidget(object, index) => SeriesCard(series: object);

  @override
  String get modelUrl => SERIES_URL;

  /// SeriesCardList Series have category 10287.
  @override
  int get categoryId => SERIES_ID;

  @override
  List dataToCardList(data) {
    return data.map((value) => Series.fromDatabaseJson(value)).toList();
  }

  @override
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) {
    /// Check if accessibility option for sign language is on.
    print(
        "Debug: bool sign lang = ${Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang} ");
    if (Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang) {
      /// Filter sign lang videos
      var contador = 1;
      for (int i = 0; i < newCards.length; i++) {
        print("Debug: number of series ${newCards.length}");
        print(
            "Debug: number of episode in series $contador, ${newCards[i].videos.length}");
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
