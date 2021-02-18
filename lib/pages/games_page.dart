import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/widgets/game_card_widget.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows video widgets that have 'Games' category.
class Games extends StatefulWidget {
  @override
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> {
  List<dynamic> games = [];
  Future<List<dynamic>> _futureGames;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _futureGames = fetchGames();
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    //_controller.addListener(_scrollControllerListener);
  }

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
        var i = 0;
        while (i < games.length) {
          if (i < 5) {
            games[i].mediaUrl = await games[i].fetchMedia(games[i].mediaUrl);
            i++;
          } else {
            games.removeAt(i);
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

    /// Get size of the current context widget.
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0.05 * size.height, 0, 0),
      child: FutureBuilder(
        future: _futureGames,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print(snapshot.data);
          if (snapshot.data == null) {
            return Container(child: Center(child: Text("Loading...")));
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              controller: _controller,
              itemBuilder: (BuildContext context, int index) {
                return GameCard(
                  juego: snapshot.data[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}
