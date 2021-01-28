import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/video.dart';
import 'package:cntvkids_app/widgets/video_container.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';

class Featured extends StatefulWidget {
  @override
  _FeaturedState createState() => _FeaturedState();
}

class _FeaturedState extends State<Featured> {
  List<dynamic> featured = [];
  Future<List<dynamic>> _futureFeatured;

  ScrollController _controller;

  int currentPage = 1;
  bool _continueLoadingPages;

  @override
  void initState() {
    super.initState();

    currentPage = 1;
    _futureFeatured = fetchFeatured(currentPage);

    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollControllerListener);

    _continueLoadingPages = true;
  }

  ///
  void _checkForForceUpdate(int id) async {
    if (!this.mounted) return;

    try {
      String requestUrl =
          "$WORDPRESS_URL/$VIDEOS_URL?page=1&per_page=1&_fields=id";
      var response = await http.get(
        requestUrl,
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        if (json.decode(response.body)[0]["id"] != id) {
          customDioCacheManager.clearAll();

          setState(() {
            featured = [];
            currentPage = 1;
            _futureFeatured = fetchFeatured(currentPage);
          });
        }
      }
    } on SocketException {
      throw (ERROR_MESSAGE["NO_CONNECTION"]);
    }
  }

  _scrollControllerListener() {
    if (!this.mounted) return;

    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        currentPage += 1;
        _futureFeatured = fetchFeatured(currentPage);
      });
    }
  }

  /// Fetch featured videos by page.
  ///
  /// Featured videos have category 10536 in their [categories].
  Future<List<dynamic>> fetchFeatured(int page) async {
    if (!this.mounted) return featured;

    final int featuredPerPage = 4;

    try {
      String requestUrl =
          "$VIDEOS_URL&categories[]=$FEATURED_ID&page=$page&per_page=$featuredPerPage";

      Response response = await customDio.get(
        requestUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        /// Add new videos to [featured].
        setState(() {
          featured.addAll(
              response.data.map((value) => Video.fromJson(value)).toList());

          if (featured.length % featuredPerPage != 0)
            _continueLoadingPages = false;
        });

        if (page == 1) _checkForForceUpdate(featured[0].id);

        return featured;
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
          print(e.request);
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

    return featured;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _futureFeatured,
      builder: (context, snapshot) {
        /// If snapshot has values.
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) return Container();

          return Column(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 100.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    shrinkWrap: true,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      /// Get the item and assign a [heroId].
                      Video item = snapshot.data[index];
                      final heroId = item.id.toString() +
                          Random().nextInt(10000).toString();

                      return InkWell(
                        //onTap: ,
                        child: VideoCard(video: item, heroId: heroId),
                      );
                    },
                  ),
                ),
              ),
              _continueLoadingPages
                  ? Container(
                      alignment: Alignment.center,
                      height: 30,
                      child: Loading(
                          indicator: BallBeatIndicator(),
                          size: 60.0,
                          color: Theme.of(context).accentColor))
                  : Container()
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
                color: Theme.of(context).accentColor));
      },
    );
  }
}
