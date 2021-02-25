import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

/// Shows small video card widgets when displaying a video and it's minimized.
class SuggestedVideosCardList extends StatefulWidget {
  final List<int> categories;
  final int skipIndex;

  const SuggestedVideosCardList({Key key, this.categories, this.skipIndex})
      : super(key: key);

  @override
  _SuggestedVideosCardListState createState() =>
      _SuggestedVideosCardListState();
}

class _SuggestedVideosCardListState extends State<SuggestedVideosCardList> {
  List<dynamic> suggestedVideos = [];
  Future<List<dynamic>> _futureSuggestedVideos;

  ScrollController _controller;

  int currentPage;
  bool _continueLoadingPages;
  final int suggestedVideosPerPage = 2;

  @override
  void initState() {
    super.initState();

    currentPage = 1;
    _futureSuggestedVideos = fetchSuggestedVideos(currentPage);

    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollControllerListener);

    _continueLoadingPages = true;
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
            suggestedVideos = [];
            currentPage = 1;
            _futureSuggestedVideos = fetchSuggestedVideos(currentPage);
          });
        }
      }
    } on SocketException {
      throw (ERROR_MESSAGE[ErrorTypes.NO_CONNECTION]);
    }
  }

  /// play sounds
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes);
  }

  /// Listener for scroll changes.
  ///
  /// Loads the next page (per page) for suggestedVideos videos if the scroll is
  /// finished.
  _scrollControllerListener() {
    if (!this.mounted) return;

    /// reach bottom
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      playSound("sounds/beam/beam.mp3");
      setState(() {
        currentPage += 1;
        _futureSuggestedVideos = fetchSuggestedVideos(currentPage);
      });
    }

    /// reach top
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      playSound("sounds/beam/beam.mp3");
    }
  }

  /// Fetch suggestedVideos videos by page.
  ///
  /// SuggestedVideos videos have category 10536 in their [categories].
  Future<List<dynamic>> fetchSuggestedVideos(int page) async {
    if (!this.mounted) return suggestedVideos;

    /// Try get the requested data and wait.
    try {
      String requestUrl =
          "$VIDEOS_URL&categories[]=$FEATURED_ID&page=$page&per_page=$suggestedVideosPerPage";

      Response response = await customDio.get(
        requestUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        if (!this.mounted) return suggestedVideos;

        /// Add new videos to [suggestedVideos] by updating this widget's state.
        setState(() {
          suggestedVideos.addAll(
              response.data.map((value) => Video.fromJson(value)).toList());

          if (suggestedVideos.length % suggestedVideosPerPage != 0)
            _continueLoadingPages = false;
        });

        if (page == 1) _checkForForceUpdate(suggestedVideos[0].id);

        return suggestedVideos;
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
            _continueLoadingPages = false;
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

    return suggestedVideos;
  }

  @override
  Widget build(BuildContext context) {
    /// Get size of the current context widget.
    Size size = MediaQuery.of(context).size;

    return FutureBuilder<List<dynamic>>(
      future: _futureSuggestedVideos,
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
                    /// TODO: Fix max scroll indicator being cut.
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length + 1,
                    shrinkWrap: true,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      /// [itemCount] includes an extra item for the loading
                      /// element.

                      /// TODO: Fix bad scrolling when moving backwards.

                      /// If currently viewing video items.
                      if (index != snapshot.data.length) {
                        return VideoCard(
                          video: snapshot.data[index],
                          heroId: snapshot.data[index].id.toString() +
                              new Random().nextInt(10000).toString(),
                        );

                        /// Otherwise, it's the loading widget.
                      } else if (_continueLoadingPages) {
                        /// If scroll controller cant get dimensions, it means
                        /// that the loading element is visible and should load
                        /// more pages.
                        if (!_controller.position.haveDimensions) {
                          _futureSuggestedVideos =
                              fetchSuggestedVideos(++currentPage);
                        }

                        /// TODO: Check if widget is visible, if so then load pages.
                        /// Show the loading widget at the end.
                        return Container(
                            alignment: Alignment.center,
                            height: 30,
                            child: Loading(
                                indicator: BallBeatIndicator(),
                                size: 60.0,
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
            width: MediaQuery.of(context).size.width,
            height: 150,
            child: Loading(
                indicator: BallBeatIndicator(),
                size: 60.0,
                color: Colors.white));
      },
    );
  }
}