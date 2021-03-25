import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/widgets/cards/series_card_widget.dart';

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
    return data.map((value) => Series.fromJson(value)).toList();
  }

  @override
  double get leftMargin => widget.leftMargin;
}
