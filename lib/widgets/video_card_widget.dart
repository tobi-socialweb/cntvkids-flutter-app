import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/video_display_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Card widget used to display a clickable video.
class VideoCard extends StatefulWidget {
  final Video video;
  final String heroId;

  VideoCard({this.video, this.heroId});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  /// Video thumbnail and completer for the future builder.
  Image thumbnail;
  Completer completer = new Completer();

  @override
  void initState() {
    super.initState();

    /// Get thumbnail and add listener for completion.
    thumbnail = Image.network(widget.video.thumbnailUrl);
    thumbnail.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool _) => {completer.complete(info.image)}));
  }

  @override
  Widget build(BuildContext context) {
    final double iconHeight = 25.0;
    final double strokeWidth = 4.0;

    return Card(
        shadowColor: Colors.transparent,
        borderOnForeground: false,
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
                              /// Video card thumbnail.
                              CachedNetworkImage(
                                imageUrl: widget.video.thumbnailUrl,
                                filterQuality: FilterQuality.high,
                              ),

                              /// Play icon on top of the thumbnail.
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

                              /// Full screen video "on demand".
                              Positioned.fill(
                                  child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    /// When tapped, open video.
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return VideoDisplay(
                                          video: widget.video,
                                          heroId: widget.heroId);
                                    }));
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

/// Temporal play icon being painted.
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
