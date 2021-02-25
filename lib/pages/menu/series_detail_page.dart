import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/pages/menu/home_page.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';
import 'package:flutter/material.dart';

class SeriesCardDetail extends StatefulWidget {
  final Series series;
  final String heroId;
  final ImageProvider imgProvider;

  const SeriesCardDetail({Key key, this.imgProvider, this.series, this.heroId})
      : super(key: key);

  _SeriesCardDetailState createState() => _SeriesCardDetailState();
}

class _SeriesCardDetailState extends State<SeriesCardDetail> {
  ScrollController _controller;
  bool beginScrolling = false;

  @override
  void initState() {
    super.initState();

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

  /// Listener for scroll changes.
  ///
  /// Loads the next page (per page) for series videos if the scroll is
  /// finished.
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

  /// Remove HTML tags from string [text].
  String clean(String text) {
    text = text.replaceAll(
        new RegExp(r"&hellip;", multiLine: true, caseSensitive: true), "...");
    RegExp re = RegExp(
      r"<[^>]*>",
      multiLine: true,
      caseSensitive: true,
    );

    return text.replaceAll(re, '');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double topBarHeight = NAVBAR_HEIGHT_PROP * size.height;

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// The colored curved blob in the background (white, yellow, etc.).
            CustomPaint(
              painter: BottomColoredBlobPainter(color: Colors.cyan, size: size),
            ),

            /// Top Bar.
            Container(
                constraints: BoxConstraints(
                    maxHeight: topBarHeight, maxWidth: size.width),
                height: topBarHeight,
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /// Back button.
                    SvgButton(
                      asset: SvgAsset.back_icon,
                      size: 0.5 * topBarHeight,
                      padding: EdgeInsets.fromLTRB(
                          0.125 * topBarHeight, 0.0, 0.0, 0.25 * topBarHeight),
                      onTap: () => Navigator.of(context).pop(),
                    ),

                    /// Series thumbnail avatar.
                    Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 0.025 * size.width),
                      child: Hero(
                          tag: widget.heroId,
                          child: CircleAvatar(
                            /// diameter: 0.75 * topBarHeight
                            radius: 0.375 * topBarHeight,
                            backgroundImage: widget.imgProvider,
                          )),
                    ),

                    /// Series title & description.
                    Container(
                        margin: EdgeInsets.only(top: 0.1 * topBarHeight),
                        width: 0.9 * size.width - 1.375 * topBarHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title
                            Text(
                              widget.series.title,
                              style: TextStyle(
                                  fontSize: 0.15 * topBarHeight,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: "FredokaOne"),
                            ),

                            /// Description
                            Expanded(
                              child: ListView(
                                primary: false,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                children: [
                                  Container(
                                    height: 0.05 * topBarHeight,
                                  ),
                                  Text(
                                    clean(widget.series.shortDescription),
                                    style: TextStyle(
                                      fontSize: 0.125 * topBarHeight,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  ],
                )),

            /// Video Cards' List.
            Expanded(
              child: Center(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: size.height * (1 - NAVBAR_HEIGHT_PROP)),
                      child: ListView.builder(
                        /// TODO: Fix max scroll indicator being cut.
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.series.videos.length,
                        shrinkWrap: false,
                        controller: _controller,
                        itemBuilder: (context, index) {
                          return VideoCard(
                            video: widget.series.videos[index],
                            heroId: widget.series.videos[index].id.toString() +
                                new Random().nextInt(10000).toString(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              )),
            ),

            /// Space filler to keep things kinda centered.
            Container(
              width: size.width,
              height: topBarHeight / 2,
            ),
          ],
        ));
  }
}