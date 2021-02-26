import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/cards/variable_card_list.dart';
import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/widgets/cards/lists_card_widget.dart';

/// Shows video widgets that have 'lists' category.
class ListsCardList extends StatefulWidget {
  @override
  _ListsCardListState createState() => _ListsCardListState();
}

class _ListsCardListState extends CardListState<ListsCardList> {
  @override
  Widget cardWidget(object, heroId) {
    return ListsCard(
      list: object,
      heroId: heroId,
    );
  }

  @override
  String get modelUrl => LISTS_URL;

  /// ListsCardList lists have category 10564.
  @override
  int get categoryId => LISTS_ID;

  @override
  List dataToCardList(data) {
    return data.map((value) => Lists.fromJson(value)).toList();
  }
}
