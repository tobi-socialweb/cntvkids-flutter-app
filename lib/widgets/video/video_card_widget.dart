import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/widgets/video/video_display_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Card widget used to display a clickable video.
class VideoCard extends StatefulWidget {
  final Video video;
  final String heroId;
  final bool isMinimized;

  VideoCard(
      {@required this.video, @required this.heroId, this.isMinimized = false});

  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  /// The size factor shrinks the video card by this amount.
  double sizeFactor;

  /// Used to fetch the thumbnail and wait for it to load.
  CachedNetworkImageProvider imgProvider;
  Completer completer = new Completer();

  @override
  void initState() {
    super.initState();

    /// Get thumbnail and add listener for completion.
    /// Set the URL and add a listener to complete the future.
    imgProvider = new CachedNetworkImageProvider(widget.video.thumbnailUrl);
    imgProvider.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));

    sizeFactor = widget.isMinimized ? 0.9 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Card(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        borderOnForeground: false,
        margin: widget.isMinimized
            ? EdgeInsets.symmetric(
                horizontal: 0.005 * size.width, vertical: 0.005 * size.width)
            : EdgeInsets.symmetric(horizontal: 0.025 * size.width),
        child: FutureBuilder(
            future: completer.future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                /// the video card's height
                final double height = 0.4 * size.height * sizeFactor;
                final double iconSize = 0.45 * height;

                /// How far to move the icon diagonally from the bottom right.
                final double diagonalDstFactor = 0.3;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0.15 * height),
                      child: Stack(
                        children: [
                          /// Video card thumbnail.
                          Image(
                            image: imgProvider,
                            filterQuality: FilterQuality.high,
                            height: height,
                            fit: BoxFit.fitHeight,
                          ),

                          /// Play icon on top of the thumbnail.
                          Positioned(
                              right: height * diagonalDstFactor - iconSize / 2,
                              bottom: height * diagonalDstFactor - iconSize / 2,
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  SvgIcon(
                                    asset: R.svg.videos_badge,
                                    size: iconSize,
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
                    if (!widget.isMinimized)
                      Container(
                        width:
                            height / snapshot.data.height * snapshot.data.width,
                        child: Text(
                          "${widget.video.series}\n${widget.video.extra} - ${widget.video.title}",
                          textAlign: TextAlign.left,
                          softWrap: true,
                          textScaleFactor: 0.006 * height,
                          style: TextStyle(color: Colors.black),
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
