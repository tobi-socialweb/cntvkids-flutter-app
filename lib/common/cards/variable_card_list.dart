import 'dart:async';

import 'package:cntvkids_app/widgets/background_music.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

abstract class VariableCardListState<T extends StatefulWidget>
    extends State<T> {
  /// Currently shown cards.
  List<dynamic> cards = [];

  /// Future cards.
  Future<List<dynamic>> futureCards;

  /// Controller for the `ListView` scrolling.
  ScrollController controller;

  /// How many cards will be loaded each time.
  int cardsPerPage = 25;

  /// The last page that was loaded.
  int currentPage = 1;

  /// If user began scrolling.
  bool startedScrolling;

  /// The model URL that should be one of the constants defined.
  String get modelUrl;

  /// The specific category ID to use when fetching the data.
  int get categoryId;

  ///
  bool flag = true;

  /// Recieves the snapshot data and converts each value into the model object,
  /// returning a list of these objects.
  ///
  /// ```dart
  ///   return data.map((value) => MODEL.fromJson(value)).toList();
  /// ```
  List<dynamic> dataToCardList(dynamic data);

  /// Returns the specific card widget corresponding to each model (with object).
  Widget cardWidget(dynamic object, String heroId, int index);

  /// Gets called after successfully fetching cards, and allows for further
  /// optional management of which cards to keep or any other use.
  Future<List<dynamic>> optionalCardManagement(List<dynamic> newCards) =>
      Future.value(newCards);

  double get leftMargin;

  @override
  void initState() {
    super.initState();
    print("debug: key = ${widget.key}");
    startedScrolling = false;
    controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    controller.addListener(_scrollControllerListener);
    futureCards = fetchCards(currentPage);
  }

  /// Listener for scroll changes.
  _scrollControllerListener() {
    if (!this.mounted) return;

    /// reach bottom
    if (controller.offset >= controller.position.maxScrollExtent / 2 && flag) {
      setState(() {
        currentPage += 1;
        futureCards = fetchCards(currentPage);
        flag = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // ignore: invalid_use_of_protected_member
      if (controller.positions.length > 0 &&
          controller.position.isScrollingNotifier.value &&
          !startedScrolling) {
        MusicEffect.play(MediaAsset.mp3.beam);
        startedScrolling = true;
      }
    });
  }

  /// Fetch cards videos by page.
  Future<List<dynamic>> fetchCards(int page) async {
    if (!this.mounted) return cards;

    /// Try get the requested data and wait.
    try {
      String requestUrl = categoryId != null
          ? "$modelUrl&categories[]=$categoryId&page=$page&per_page=$cardsPerPage"
          : "$modelUrl&page=$page&per_page=$cardsPerPage";
      Response response = await customDio.get(
        requestUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        /// Add new videos to [cards] by updating this widget's state.
        List<dynamic> newCards =
            await optionalCardManagement(dataToCardList(response.data));
        setState(() {
          cards.addAll(newCards);
          flag = true;
        });
        return cards;
      }
    } on DioError catch (e) {
      if (DioErrorType.RECEIVE_TIMEOUT == e.type ||
          DioErrorType.CONNECT_TIMEOUT == e.type) {
        /// Couldn't reach the server.
        throw (ERROR_MESSAGE[ErrorTypes.UNREACHABLE]);
      } else if (DioErrorType.RESPONSE == e.type) {
        /// If request was badly formed.
        if (e.response.statusCode == 400) {
          print("reponse 400");

          /// Otherwise.
        } else {
          print(e.message);
          print(e.request.toString());
        }
      } else if (DioErrorType.DEFAULT == e.type) {
        if (e.message.contains('SocketException')) {
          /// No connection to internet.
          throw (ERROR_MESSAGE[ErrorTypes.NO_CONNECTION]);
        }
      } else {
        /// Unknown problem connecting to server.
        throw (ERROR_MESSAGE[ErrorTypes.UNKNOWN]);
      }
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<List<dynamic>>(
          future: futureCards,
          builder: (context, snapshot) {
            /// If snapshot has values.
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Container();
              }

              return NotificationListener(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                          padding: EdgeInsets.only(left: leftMargin),
                          child: cardWidget(snapshot.data[index],
                              snapshot.data[index].id.toString(), index));
                    } else {
                      return cardWidget(snapshot.data[index],
                          snapshot.data[index].id.toString(), index);
                    }
                  },
                ),
                // ignore: missing_return
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    setState(() {
                      startedScrolling = false;
                    });
                  }
                },
              );
            } else if (snapshot.hasError && snapshot.data != null) {
              return Container(
                  height: 300,
                  alignment: Alignment.center,
                  child: Text("${snapshot.error}"));
            } else {
              return Center(
                child: Image.asset(
                  "assets/app/preload.gif",
                ),
              );
            }
          },
        )
      ],
    );
  }
}
