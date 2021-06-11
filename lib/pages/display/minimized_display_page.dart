import 'dart:async';
import 'dart:math';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:cntvkids_app/widgets/video_display_controller_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/search/search_card_list.dart';

import 'package:cntvkids_app/widgets/video_cast_widget.dart';
import 'package:provider/provider.dart';

/// Shows video controls and other related videos.
class MinimizedVideoDisplay extends StatefulWidget {
  final Video video;
  final Future<dynamic> player;
  MinimizedVideoDisplay({this.video, this.player});

  @override
  _MinimizedVideoDisplayState createState() => _MinimizedVideoDisplayState();
}

class _MinimizedVideoDisplayState extends State<MinimizedVideoDisplay> {
  SearchCardList suggested;
  @override
  void initState() {
    
    suggested = SearchCardList(
      search:
          widget.video.series != "" ? widget.video.series : widget.video.title,
      video: widget.video,
      isMinimized: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    /// The border size (thickness) between all of the elements.
    final double border = 0.025 * size.width;

    /// Height percentage of the video.
    final double videoHeight = 0.6 * size.height;

    /// The result of the icon sizes after setting previous variables.
    final double _preferredIconSize =
        (size.width - (videoHeight * 16 / 9)) / 2 - 2 * border;
    final double _iconSize = min(_preferredIconSize, 0.1 * size.width);
    final bool shouldCenterButtons = _preferredIconSize != _iconSize;

    return Material(
      color: Theme.of(context).accentColor,
      child: WillPopScope(
        onWillPop: () {
          Audio.play(MediaAsset.mp3.go_back);
          return Future<bool>.value(false);
        },
        child: Container(
          padding: EdgeInsets.all(border),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: shouldCenterButtons
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Left side buttons.
                  _ButtonColumn(
                    width: _iconSize,
                    height: videoHeight,
                    children: [
                      /// Back button.
                      SvgButton(
                        asset: SvgAsset.back_icon,
                        size: _iconSize,
                        onPressed: () {
                          Audio.play(MediaAsset.mp3.go_back);

                          //widget.player.dispose(forceDispose: true);
                          Navigator.of(context).pop();
                        },
                      ),

                      /// Prev video button.
                      SvgButton(
                        asset: widget.video.prev != null
                            ? SvgAsset.player_previous_icon
                            : SvgAsset.player_previous_unavailable_icon,
                        size: _iconSize,
                        onPressed: () {
                          if (widget.video.prev == null) return;
                          Audio.play(MediaAsset.mp3.click);

                          /// When tapped, open video.
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return VideoDisplayController(
                              video: widget.video.prev,
                            );
                          }));
                        },
                      )
                    ],
                  ),

                  /// Centered video.
                  ClipRRect(
                      borderRadius: BorderRadius.circular(0.075 * size.height),
                      child: GestureDetector(
                        onTap: () {
                          context.read<DisplayNotifier>().toggleDisplay();
                        },
                        child: FutureBuilder(
                          future: widget.player,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                height: videoHeight,
                                child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: MediaQuery(
                                      data: MediaQueryData(
                                          size: Size(videoHeight * 16 / 9,
                                              videoHeight)),
                                      child: Hero(
                                        tag: widget.video.id,
                                        child: snapshot.data,
                                      ),
                                    )),
                              );
                            } else if (snapshot.hasError) {
                              return Text(snapshot.error);
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              );
                            }
                          },
                        ),
                      )),

                  /// Right side buttons.
                  _ButtonColumn(
                    width: _iconSize,
                    height: videoHeight,
                    children: [
                      /// ChromeCast button.
                      _ChromeCastButton(
                        video: widget.video,
                        iconSize: _iconSize,
                        innerIconScaleFactor: 0.5,
                      ),

                      /// Next video button.
                      SvgButton(
                        asset: widget.video.next != null
                            ? SvgAsset.player_next_icon
                            : SvgAsset.player_next_unavailable_icon,
                        size: _iconSize,
                        onPressed: () {
                          if (widget.video.next == null) return;

                          Audio.play(MediaAsset.mp3.click);

                          /// When tapped, open video.
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return VideoDisplayController(
                              video: widget.video.next,
                            );
                          }));
                        },
                      )
                    ],
                  ),
                ],
              ),

              /// FeaturedCardList(isMinimized: true),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: border),
                  child: MediaQuery(
                    data: MediaQueryData(
                      size: new Size(size.width - 2 * border,
                          size.height - videoHeight - 3 * border),
                    ),
                    child: suggested,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ChromeCastButton extends StatelessWidget {
  final Video video;
  final double iconSize;
  final double innerIconScaleFactor;

  const _ChromeCastButton(
      {Key key, this.video, this.iconSize, this.innerIconScaleFactor = 0.95})
      : assert(innerIconScaleFactor <= 1.0 && innerIconScaleFactor >= 0.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgIcon(
          asset: SvgAsset.chromecast_icon,
          size: iconSize,
        ),
        Padding(
            padding:
                EdgeInsets.all(((1 - innerIconScaleFactor) * iconSize) / 2),
            child: ChromeCast(
              video: video,
              iconSize: innerIconScaleFactor * iconSize,
            )),
      ],
    );
  }
}

class _ButtonColumn extends StatelessWidget {
  final double width;
  final double height;
  final List<Widget> children;

  const _ButtonColumn({Key key, this.children, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(vertical: 0.05 * height),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: children,
      ),
    );
  }
}
