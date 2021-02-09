import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/widgets/video_display_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Card widget used to display a clickable video.
class VideoCard extends StatefulWidget {
  final Video video;
  final String heroId;
  final double sizeFactor;

  VideoCard(
      {@required this.video, @required this.heroId, this.sizeFactor = 1.0});

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
                /// the video card's height
                final double height = 0.4 * size.height;
                final double iconSize = 0.45 * height * widget.sizeFactor;

                /// How far to move the icon diagonally from the bottom right.
                final double diagonalDstFactor = 0.3;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0.15 * height),
                      child: Stack(
                        children: [
                          /// Video card thumbnail.
                          CachedNetworkImage(
                            imageUrl: widget.video.thumbnailUrl,
                            filterQuality: FilterQuality.high,
                            height: height,
                            fit: BoxFit.fitHeight,
                          ),

                          /// Play icon on top of the thumbnail.
                          Positioned(
                              right: height *
                                      widget.sizeFactor *
                                      diagonalDstFactor -
                                  iconSize / 2,
                              bottom: height *
                                      widget.sizeFactor *
                                      diagonalDstFactor -
                                  iconSize / 2,
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  SvgIcon(
                                    asset: R.svg.videos_badge,
                                    width: iconSize,
                                    height: iconSize,
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
                                    heroId: widget.heroId,
                                  );
                                }));
                              },
                            ),
                          )),
                        ],
                      ),
                    ),
                    Container(
                      width:
                          height / snapshot.data.height * snapshot.data.width,
                      child: Text(
                        "${widget.video.extra} - ${widget.video.title}\n\n${widget.video.series}",
                        textAlign: TextAlign.left,
                        softWrap: true,
                        textScaleFactor: 0.006 * height,
                      ),
                    )
                  ],
                );
              } else {
                return new Container();
              }
            }));
  }
}
