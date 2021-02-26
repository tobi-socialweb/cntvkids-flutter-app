import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/widgets/cards/series_card_widget.dart';

/// Shows video widgets that have 'lists' category.
class SeriesCardList extends StatefulWidget {
  @override
  _SeriesCardListState createState() => _SeriesCardListState();
}

class _SeriesCardListState extends CardListState<SeriesCardList> {
  @override
  Widget cardWidget(object, heroId) {
    return SeriesCard(
      series: object,
      heroId: heroId,
    );
  }

  @override
  String get modelUrl => SERIES_URL;

  /// SeriesCardList Series have category 10287.
  @override
  int get categoryId => SERIES_ID;

  @override
  List dataToCardList(data) {
    return data.map((value) => Series.fromJson(value)).toList();
  }
}
