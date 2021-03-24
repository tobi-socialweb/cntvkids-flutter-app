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
  Widget cardWidget(object, heroId, index) {
    return VideoCard(
      video: object,
      heroId: heroId,
    );
  }

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
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) {
    /// Check if accessibility option for sign language is on.
    if (Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang) {
      print("Debug: largo inicial ${newCards.length}");

      /// Filter sign lang videos
      for (int i = 0; i < newCards.length; i++) {
        print("DEBUG: iteration =$i cards length = ${newCards.length}");
        if (newCards[i].signLangVideoUrl != "") {
          print("Debug: true use sign lang");
          print("Debug: ${newCards[i].title}");
          newCards[i].useSignLang = true;
        } else {
          print("DEBUG: removing element $i");
          print("Debug: ${newCards[i].title}");
          newCards.removeAt(i);
          i--;
        }
      }
      print("Debug: largo final ${newCards.length}");
    }
    return Future.value(newCards);
  }
}
