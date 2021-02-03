import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/models/video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';

class VideoContainer extends StatefulWidget {
  final Video video;

  VideoContainer({this.video});

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  BetterPlayerController _betterPlayerController;
  Image thumbnail;
  Completer completer = new Completer();
  BetterPlayerDataSource betterPlayerDataSource;

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();

    _isFullScreen = false;

    thumbnail = Image.network(widget.video.thumbnailUrl);
    thumbnail.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool _) => {completer.complete(info.image)}));

    _getBetterPlayerController();
  }

  void _getBetterPlayerController() {
    betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.video.videoUrl);

    /// TODO: Fix BetterPlayer's bad [controlsHideTime] process.
    ///
    /// Giving it a longer time, makes the transition slow, and not the time
    /// that the controls are visible. Hack into the package or customize?
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          aspectRatio: 16 / 9,
          fullScreenByDefault: true,
          allowedScreenSleep: false,
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          systemOverlaysAfterFullScreen: [SystemUiOverlay.bottom],
          autoDetectFullscreenDeviceOrientation: true,
          autoDispose: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: false,
            controlsHideTime: const Duration(milliseconds: 1000),
            enableSubtitles: false,
            enablePlaybackSpeed: false,
            enableQualities: false,
            enableOverflowMenu: false,
            enableFullscreen: false,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource);

    _betterPlayerController.addEventsListener(_betterPlayerEventListener);
  }

  void _betterPlayerEventListener(BetterPlayerEvent event) async {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.openFullscreen:
        if (_isFullScreen) {
          print("DEBUG: Opened full screen AGAIN");

          /// TODO: Fix when user taps fast too many times on the video.
          return;
        }

        print("DEBUG: Opened full screen");
        return;
        setState(() {
          _isFullScreen = true;
          SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
        });
        break;
      case BetterPlayerEventType.hideFullscreen:
        print("DEBUG: Closed full screen");
        setState(() {
          _isFullScreen = false;
          _betterPlayerController.seekTo(Duration(seconds: 0));
          _betterPlayerController.pause();
          _getBetterPlayerController();
        });

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconHeight = 25.0;
    final double strokeWidth = 4.0;

    return Card(
        shadowColor: Colors.transparent,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.cyan, width: 2.0)),
        margin: EdgeInsets.fromLTRB(35, 0, 35, 0),
        child: FutureBuilder(
            future: completer.future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: snapshot.data.width * 1.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: LimitedBox(
                          maxHeight: snapshot.data.height.toDouble(),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: widget.video.thumbnailUrl,
                                filterQuality: FilterQuality.high,
                              ),
                              Positioned(
                                  right: 0.1 * snapshot.data.width,
                                  top: 0.9 * snapshot.data.height -
                                      iconHeight * 2 -
                                      strokeWidth,
                                  child: Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      CustomPaint(
                                        painter: PlayIconCustomPainter(
                                            context: context,
                                            sideSize: iconHeight,
                                            x: -iconHeight * 1.85,
                                            y: 0.0,
                                            strokeWidth: strokeWidth),
                                      ),
                                      new Icon(
                                        Icons.play_arrow_rounded,
                                        size: iconHeight * 1.75,
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ],
                                  )),
                              Positioned.fill(
                                  child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      _isFullScreen = true;
                                      return WillPopScope(
                                          child: AspectRatio(
                                            aspectRatio: 16 / 9,
                                            child: BetterPlayer(
                                              controller:
                                                  _betterPlayerController,
                                            ),
                                          ),
                                          onWillPop: () {
                                            print("DEBUG: Popped screen");
                                            _betterPlayerEventListener(
                                                new BetterPlayerEvent(
                                                    BetterPlayerEventType
                                                        .hideFullscreen));
                                            return Future<bool>.value(true);
                                          });
                                    }));

                                    _betterPlayerController.play();

                                    if (!_isFullScreen) {
                                      _betterPlayerController.enterFullScreen();
                                    }
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      Text(widget.video.title),
                    ],
                  ),
                );
              } else {
                return new Container();
              }
            }));
  }
}

class PlayIconCustomPainter extends CustomPainter {
  final BuildContext context;
  final double sideSize;
  final double x;
  final double y;
  final double strokeWidth;

  PlayIconCustomPainter(
      {this.context, this.sideSize, this.x, this.y, this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint whitePaint = Paint()
      ..color = Theme.of(context).primaryColorLight
      ..style = PaintingStyle.fill;
    Paint purplePaint = Paint()
      ..color = Theme.of(context).accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Path path = Path()..moveTo(x, y);

    path.relativeQuadraticBezierTo(0, -sideSize, sideSize, -sideSize);
    path.relativeQuadraticBezierTo(sideSize, 0, sideSize, sideSize);
    path.relativeQuadraticBezierTo(0, sideSize, -sideSize, sideSize);
    path.relativeQuadraticBezierTo(-sideSize, 0, -sideSize, -sideSize);

    path.close();

    canvas.drawPath(path, whitePaint);
    canvas.drawPath(path, purplePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
