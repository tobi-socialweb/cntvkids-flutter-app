import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/models/video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class VideoContainer extends StatelessWidget {
  final Video video;
  final String heroId;

  VideoContainer({this.video, this.heroId});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Image thumbnail = Image.network(video.thumbnailUrl);
    Completer<ui.Image> completer = new Completer<ui.Image>();

    thumbnail.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener(
            (ImageInfo info, bool _) => {completer.complete(info.image)}));

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
                return new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Positioned(
                            right: 0.05 * snapshot.data.width,
                            top: 0.3 * snapshot.data.height,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                CustomPaint(
                                  painter: PlayIconCustomPainter(
                                      context: context,
                                      sideSize: 35,
                                      x: -70,
                                      y: 0.0,
                                      strokeWidth: 7),
                                ),
                                new Icon(
                                  Icons.play_arrow_rounded,
                                  size: 75,
                                  color: Theme.of(context).accentColor,
                                ),
                              ],
                            )),
                      ],
                    ),
                    Text(video.title),
                  ],
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
