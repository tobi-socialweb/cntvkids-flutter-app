import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';

import 'package:cntvkids_app/common/card_list.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/widgets/series_card_widget.dart';

class SeriesList extends StatefulWidget {
  @override
  _SeriesListState createState() => _SeriesListState();
}

class _SeriesListState extends CardListState<SeriesList> {
  @override
  String get modelUrl => SERIES_URL;

  @override
  int get category => SERIES_ID;

  @override
  List<dynamic> dataToCardList(dynamic data) {
    return data.map((value) => Series.fromJson(value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height * (1 - 3 * NAV_BAR_PERCENTAGE / 2);

    return FutureBuilder(
      future: futureCards,
      builder: (context, snapshot) {
        /// If there are values.
        if (snapshot.hasData && snapshot.data.length > 0) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: height),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length + 1,
                    controller: controller,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      /// The `init` part of the list (all but the last element)
                      /// correspond to each series card.
                      if (index < snapshot.data.length) {
                        return SeriesCard(
                          series: snapshot.data[index],
                          heroId: snapshot.data[index].id.toString() +
                              new Random().nextInt(10000).toString(),
                        );

                        /// Otherwise, show the loading widget.
                      } else if (continueLoadingPages) {
                        /// If scroll controller cant get dimensions, it means that
                        /// the loading element is visible and should load more pages.
                        if (!controller.position.haveDimensions) {
                          futureCards = fetchCards(++currentPage);
                        }

                        return Container(
                            alignment: Alignment.center,
                            child: Loading(
                                indicator: BallSpinFadeLoaderIndicator(),
                                size: 0.4 * height,
                                color: Colors.white));
                      }

                      return Container();
                    },
                  ),
                ),
              )
            ],
          );

          /// If there is an error.
        } else if (snapshot.hasError) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              "${snapshot.error}",
              style: TextStyle(
                backgroundColor: Colors.black54,
                color: Colors.white,
              ),
            ),
          );

          /// Otherwise, show the loading widget.
        } else {
          return Container(
            alignment: Alignment.center,
            child: Loading(
              indicator: BallSpinFadeLoaderIndicator(),
              size: 0.4 * height,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
