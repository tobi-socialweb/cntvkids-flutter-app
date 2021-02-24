import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/widgets/cards/game_card_widget.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

/// Shows video widgets that have 'Games' category.
class GamesCardList extends StatefulWidget {
  @override
  _GamesCardListState createState() => _GamesCardListState();
}

class _GamesCardListState extends State<GamesCardList> {
  List<dynamic> games = [];
  Future<List<dynamic>> _futureGames;
  ScrollController _controller;

  bool beginScrolling = false;

  @override
  void initState() {
    super.initState();
    _futureGames = fetchGames();
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollControllerListener);
  }

  /// play sounds
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes);
  }

  /// controlador de scroll
  _scrollControllerListener() {
    if (!this.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller.position.isScrollingNotifier.value) {
        if (!beginScrolling) {
          playSound("sounds/beam/beam.mp3");
          beginScrolling = true;
        }
      } else {
        beginScrolling = false;
      }
    });
  }

  /// adquirir juegos
  Future<List<dynamic>> fetchGames() async {
    if (!this.mounted) return games;

    /// Try get the requested data and wait.
    try {
      String requestUrl = "$GAMES_URL";

      Response response = await customDio.get(
        requestUrl,
        options:
            buildCacheOptions(Duration(days: 3), maxStale: Duration(days: 7)),
      );

      /// If request has succeeded.
      if (response.statusCode == 200) {
        setState(() {
          games.addAll(
              response.data.map((value) => Game.fromJson(value)).toList());
        });
        if (Platform.isAndroid) {
          var i = 0;
          while (i < games.length) {
            if (games[i].categories.contains(ANDROID_GAMES_ID)) {
              games[i].mediaUrl = await games[i].fetchMedia(games[i].mediaUrl);
              i++;
            } else {
              games.removeAt(i);
            }
          }
        } else if (Platform.isIOS) {
          var i = 0;
          while (i < games.length) {
            if (games[i].categories.contains(IOS_GAMES_ID)) {
              games[i].mediaUrl = await games[i].fetchMedia(games[i].mediaUrl);
              i++;
            } else {
              games.removeAt(i);
            }
          }
        }
        return games;
      }
    } on DioError catch (e) {
      if (DioErrorType.RECEIVE_TIMEOUT == e.type ||
          DioErrorType.CONNECT_TIMEOUT == e.type) {
        /// Couldn't reach the server.
        throw (ERROR_MESSAGE[ErrorTypes.UNREACHABLE]);
      } else if (DioErrorType.RESPONSE == e.type) {
        /// If request was badly formed.
        if (e.response.statusCode == 400) {
          print("error status 400");

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
    return games;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return FutureBuilder<List<dynamic>>(
      future: _futureGames,
      builder: (context, snapshot) {
        /// If snapshot has values.
        if (snapshot.hasData) {
          if (snapshot.data.length == 0)
            return Container(child: Center(child: Text("Loading...")));

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.6 * size.height),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    shrinkWrap: true,
                    controller: _controller,
                    itemBuilder: (context, index) {
                      return GameCard(
                        juego: snapshot.data[index],
                      );
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
