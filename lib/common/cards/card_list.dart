import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:http/http.dart' as http;

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart'
    show BallSpinFadeLoaderIndicator;

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

abstract class CardListState<T extends StatefulWidget> extends State<T> {
  /// Currently shown cards.
  List<dynamic> cards = [];

  /// Future cards.
  Future<List<dynamic>> futureCards;

  /// Controller for the `ListView` scrolling.
  ScrollController controller;

  /// How many cards will be loaded each time.
  final int cardsPerPage = 5;

  /// The last page that was loaded.
  int currentPage;

  /// If this should continue loading more pages.
  bool continueLoadingPages;

  /// If user began scrolling.
  bool startedScrolling;

  /// The model URL that should be one of the constants defined.
  String get modelUrl;

  /// The specific category ID to use when fetching the data.
  int get categoryId;

  /// Recieves the snapshot data and converts each value into the model object,
  /// returning a list of these objects.
  ///
  /// ```dart
  ///   return data.map((value) => MODEL.fromJson(value)).toList();
  /// ```
  List<dynamic> dataToCardList(dynamic data);

  /// Returns the specific card widget corresponding to each model (with object).
  Widget cardWidget(dynamic object, String heroId);

  /// Gets called after successfully fetching cards, and allows for further
  /// optional management of which cards to keep or any other use.
  Future<void> optionalCardManagement() => Future<void>.value();

  @override
  void initState() {
    super.initState();

    currentPage = 1;
    continueLoadingPages = true;
    startedScrolling = false;

    futureCards = fetchCards(currentPage);

    controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    controller.addListener(_scrollControllerListener);
  }

  /// Forces update if the first video does not correspond to the correct one.
  void _checkForForceUpdate(int id) async {
    if (!this.mounted) return;

    try {
      String requestUrl = categoryId != null
          ? "$modelUrl&categories[]=$categoryId&page=1&per_page=1"
          : "$modelUrl";
      var response = await http.get(
        requestUrl,
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        if (json.decode(response.body)[0]["id"] != id) {
          customDioCacheManager.clearAll();

          setState(() {
            cards = [];
            currentPage = 1;
            futureCards = fetchCards(currentPage);
          });
        }
      }
    } on SocketException {
      throw (ERROR_MESSAGE[ErrorTypes.NO_CONNECTION]);
    }
  }

  /// Play sounds.
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes);
  }

  /// Listener for scroll changes.
  ///
  /// Loads the next page (per page) for cards videos if the scroll is
  /// finished.
  _scrollControllerListener() {
    if (!this.mounted) return;

    /// reach bottom
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      setState(() {
        currentPage += 1;
        futureCards = fetchCards(currentPage);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.position.isScrollingNotifier.value) {
        if (!startedScrolling) {
          playSound("sounds/beam/beam.mp3");
          startedScrolling = true;
        }
      } else {
        startedScrolling = false;
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
          : "$modelUrl";
      Response response = await customDio.get(
        requestUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        /// Add new videos to [cards] by updating this widget's state.
        setState(() {
          cards.addAll(dataToCardList(response.data));

          if (cards.length % cardsPerPage != 0) continueLoadingPages = false;
        });

        await optionalCardManagement();

        if (page == 1) _checkForForceUpdate(cards[0].id);

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
          setState(() {
            continueLoadingPages = false;
          });

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
    /// Get size of the current context widget.
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<List<dynamic>>(
      future: futureCards,
      builder: (context, snapshot) {
        /// If snapshot has values.
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) return Container();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.6 * size.height),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length + 1,
                    shrinkWrap: true,
                    controller: controller,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      /// [itemCount] includes an extra item for the loading
                      /// element.

                      /// TODO: Fix bad scrolling when moving backwards.

                      /// If currently viewing video items.
                      if (index != snapshot.data.length) {
                        return cardWidget(
                            snapshot.data[index],
                            snapshot.data[index].id.toString() +
                                new Random().nextInt(10000).toString());

                        /// Otherwise, it's the loading widget.
                      } else if (continueLoadingPages) {
                        /// If scroll controller cant get dimensions, it means
                        /// that the loading element is visible and should load
                        /// more pages.
                        if (!controller.position.haveDimensions) {
                          futureCards = fetchCards(++currentPage);
                        }

                        /// Show the loading widget at the end.
                        return Container(
                            alignment: Alignment.center,
                            child: Loading(
                                indicator: BallSpinFadeLoaderIndicator(),
                                size: 0.2 * size.height,
                                color: Colors.white));
                      }

                      /// Otherwise show nothing at the end.
                      return Container();
                    },
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Container(
              height: 300,
              alignment: Alignment.center,
              child: Text("${snapshot.error}"));
        }
        return Container(
            alignment: Alignment.center,
            child: Loading(
                indicator: BallSpinFadeLoaderIndicator(),
                size: 0.2 * size.height,
                color: Colors.white));
      },
    );
  }
}
