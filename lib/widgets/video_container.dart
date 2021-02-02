import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/models/video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoContainer extends StatelessWidget {
  final Video video;
  final String heroId;

  VideoContainer({this.video, this.heroId});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double iconHeight = 25.0;
    final double strokeWidth = 4.0;

    Image thumbnail = Image.network(video.thumbnailUrl);
    Completer completer = new Completer();

    thumbnail.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool _) => {completer.complete(info.image)}));

    ChewieVideoPlayer player = ChewieVideoPlayer(
      videoPlayerController: VideoPlayerController.network(video.videoUrl),
    );

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
                        child: InkWell(
                          onTap: () {
                            player.videoPlayerController.play();
                          },
                          child: LimitedBox(
                            maxHeight: snapshot.data.height * 1.0,
                            child: Stack(
                              children: [
                                player,
                                CachedNetworkImage(
                                  imageUrl: video.thumbnailUrl,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(video.title),
                    ],
                  ),
                );
              } else {
                return new Container();
              }
            }));
  }
}

class ChewieVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  final Image image;

  ChewieVideoPlayer({
    @required this.videoPlayerController,
    this.looping,
    this.image,
    Key key,
  }) : super(key: key);

  @override
  _ChewieVideoPlayerState createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      looping: widget.looping,
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ],
      fullScreenByDefault: true,
      showControlsOnInitialize: false,
      overlay: widget.image,
      systemOverlaysAfterFullScreen: [SystemUiOverlay.bottom],
      systemOverlaysOnEnterFullScreen: [SystemUiOverlay.bottom],
      errorBuilder: (context, errorMessage) {
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Text(errorMessage),
          ),
        );
      },
    );

    _chewieController.addListener(() {
      if (_chewieController.isPlaying) {
        _chewieController.enterFullScreen();
      }

      if (!_chewieController.isFullScreen) {
        _chewieController.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }

  @override
  void dispose() {
    super.dispose();

    widget.videoPlayerController.dispose();
    _chewieController.dispose();
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
