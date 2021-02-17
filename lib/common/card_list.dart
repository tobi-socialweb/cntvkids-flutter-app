import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

abstract class CardListState<T extends StatefulWidget> extends State<T> {
  List<dynamic> cards = [];
  Future<List<dynamic>> futureCards;

  ScrollController controller;

  int currentPage;
  bool continueLoadingPages;
  final int cardsPerPage = 5;

  @override
  void initState() {
    super.initState();

    currentPage = 1;
    futureCards = fetchCards(currentPage);

    controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    controller.addListener(_scrollControllerListener);

    continueLoadingPages = true;
  }

  /// Forces update if the first video does not correspond to the correct one.
  void _checkForForceUpdate(int id) async {
    if (!this.mounted) return;
    try {
      String requestUrl =
          "$VIDEOS_URL&categories[]=$FEATURED_ID&page=1&per_page=1";
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

    /// Reach bottom.
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      playSound("sounds/beam/beam.mp3");
      setState(() {
        currentPage += 1;
        futureCards = fetchCards(currentPage);
      });
    }

    /// Reach top.
    if (controller.offset <= controller.position.minScrollExtent &&
        !controller.position.outOfRange) {
      playSound("sounds/beam/beam.mp3");
    }
  }

  /// The model URL that should be one of the constants defined.
  String get modelUrl;

  /// The specific category to use when fetching the data.
  int get category;

  /// Must convert the json recieved to the corresponding model object.
  ///
  /// After fetching the data when loading all the cards, the values obtained
  /// must be inserted to the object model that represents it and returned in
  /// the form of a list. For example, if fetching data for videos:
  ///
  /// ```dart
  ///   return data.map((value) => Video.fromJson(value)).toList());
  /// ```
  ///
  /// Which now is used as:
  ///
  /// ```dart
  ///   return data.map((value) => jsonToModel(value)).toList());
  /// ```
  List<dynamic> dataToCardList(dynamic data);

  /// Fetch cards videos by page.
  Future<List<dynamic>> fetchCards(int page) async {
    if (!this.mounted) return cards;

    /// Try get the requested data and wait.
    try {
      String requestUrl =
          "$modelUrl&categories[]=$category&page=$page&per_page=$cardsPerPage";
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

  Widget build(BuildContext context);
}
