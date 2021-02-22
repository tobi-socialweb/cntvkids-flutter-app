import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/pages/game_display_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/common/helpers.dart';

/// Card widget used to display a clickable game.
class GameCard extends StatefulWidget {
  final Game juego;

  GameCard({@required this.juego});

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  /// Game thumbnail and completer for the future builder.
  Image thumbnail;
  Completer completer = new Completer();

  // variables for game view controller

  @override
  void initState() {
    super.initState();

    /// Get thumbnail and add listener for completion.
    thumbnail = Image.network(widget.juego.mediaUrl);
    thumbnail.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool _) => {completer.complete(info.image)}));
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Card(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        borderOnForeground: false,
        margin: EdgeInsets.symmetric(horizontal: 0.025 * size.width),
        child: FutureBuilder(
            future: completer.future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                /// the Game card's size
                final double height = 0.5 * size.height;
                final double width = 0.45 * size.width;
                final double iconSize = 0.3 * height;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0.15 * height),
                      child: Stack(
                        children: [
                          /// Game card thumbnail.
                          CachedNetworkImage(
                            imageUrl: widget.juego.mediaUrl,
                            filterQuality: FilterQuality.high,
                            height: height,
                            width: width,
                            fit: BoxFit.fill,
                          ),

                          /// Game badge icon on top of the thumbnail.
                          Positioned(
                              right: 0.01 * width,
                              bottom: height * 0.3,
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  SvgIcon(
                                    asset: R.svg.games_badge,
                                    size: iconSize,
                                  ),
                                ],
                              )),

                          /// Name label
                          Positioned(
                            bottom: 0,
                            width: 0.8 * width,
                            height: 0.2 * height,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                decoration: new BoxDecoration(
                                  color: Colors.purple[900],
                                  borderRadius:
                                      BorderRadius.circular(0.15 * height),
                                ),
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0.01 * size.width, 0.0, 0.0, 0.0),
                                  child: Text(
                                    "${widget.juego.title}",
                                    softWrap: true,
                                    textScaleFactor: 0.006 * height,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                          ),

                          /// Game
                          Positioned.fill(
                              child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                /// When tapped, open game.
                                print("iniciar web view");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WebViewPage(
                                            url: widget.juego.gameUrl)));
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return new Container();
              }
            }));
  }
}
