import 'dart:async';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/pages/menu/search_detail_page.dart';
import 'package:cntvkids_app/widgets/config_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:better_player/better_player.dart';

import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/video_cast_widget.dart';
import 'package:cntvkids_app/widgets/custom_controls_widget.dart';

typedef bool BoolCallback();

/// Used to keep a reference of this context, for a later navigator pop.
class InheritedVideoDisplay extends InheritedWidget {
  final BuildContext context;
  final VoidCallback toggleDisplay;
  final bool isMinimized;

  InheritedVideoDisplay(
      {this.context, this.toggleDisplay, this.isMinimized, child})
      : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static InheritedVideoDisplay of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedVideoDisplay>();
}

/// Shows video fullscreen
class VideoDisplay extends StatefulWidget {
  final Video video;
  final String heroId;
  final BetterPlayerController betterPlayerController;
  final List<Video> suggested;

  const VideoDisplay(
      {Key key,
      @required this.video,
      @required this.heroId,
      this.betterPlayerController,
      this.suggested})
      : super(key: key);

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  BetterPlayer video;
  Completer completer = new Completer();

  /// Video player controller and data source.
  BetterPlayerController _betterPlayerController;
  BetterPlayerDataSource _betterPlayerDataSource;

  ColorFilter colorFilter;
  VisualFilter currentVisualFilter;

  bool hasSetFilter = false;

  @override
  void initState() {
    super.initState();

    if (widget.betterPlayerController != null) {
      _betterPlayerController = widget.betterPlayerController;
      return;
    }

    /// Set video source.
    _betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.video.videoUrl);

    /// Define values for the player controller.
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            customControlsBuilder: (controller) => CustomPlayerControls(
              controller: controller,
              video: widget.video,
            ),
            playerTheme: BetterPlayerTheme.custom,
          ),
          autoPlay: true,
          aspectRatio: 16 / 9,
          fullScreenByDefault: false,
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
          autoDispose: false,
          errorBuilder: (context, errorMessage) {
            print("DEBUG: Error: $errorMessage");
            return Center(child: Text(errorMessage));
          },
        ),
        betterPlayerDataSource: _betterPlayerDataSource);
  }

  Future<dynamic> _getFutureVideo() {
    video = BetterPlayer(controller: _betterPlayerController);

    video.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(video);
      }
    });

    return completer.future;
  }

  void updateVisualFilter(bool value, VisualFilter filter) {
    if (!this.mounted) return;

    switch (filter) {
      case VisualFilter.grayscale:
        setState(() {
          colorFilter = value ? GRAYSCALE_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.grayscale : VisualFilter.normal;
        });
        break;

      case VisualFilter.inverted:
        setState(() {
          colorFilter = value ? INVERTED_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.inverted : VisualFilter.normal;
        });
        break;

      /// normal
      default:
        setState(() {
          colorFilter = NORMAL_FILTER;
          currentVisualFilter = VisualFilter.normal;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasSetFilter) {
      hasSetFilter = true;

      currentVisualFilter = Config.of(context).configSettings.filter;

      switch (currentVisualFilter) {
        case VisualFilter.grayscale:
          colorFilter = GRAYSCALE_FILTER;
          break;

        case VisualFilter.inverted:
          colorFilter = INVERTED_FILTER;
          break;

        default:
          colorFilter = NORMAL_FILTER;
      }
    }

    return ColorFiltered(
      colorFilter: colorFilter,
      child: InheritedVideoDisplay(
        context: context,
        isMinimized: false,
        toggleDisplay: toggleDisplay,
        child: FutureBuilder(
            future: _getFutureVideo(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return WillPopScope(
                    child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Hero(
                          tag: widget.heroId,
                          child: snapshot.data,
                        )),

                    /// When using the 'back' button, toggle minimize.
                    onWillPop: () {
                      return Future<bool>.value(true);
                    });
              } else if (snapshot.hasError) {
                return Text(snapshot.error);
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }
            }),
      ),
    );
  }

  void toggleDisplay() {
    Navigator.push(
        context,
        ConfigPageRoute(
            configSettings: Config.of(context).configSettings,
            builder: (context) {
              return MinimizedVideoDisplay(
                video: widget.video,
                heroId: widget.heroId,
                betterPlayerController: _betterPlayerController,
              );
            }));
  }

  @override
  void dispose() {
    video.controller.dispose(forceDispose: true);
    super.dispose();
  }
}

/// Shows video controls and other related videos.
class MinimizedVideoDisplay extends StatefulWidget {
  final Video video;
  final String heroId;
  final BetterPlayerController betterPlayerController;

  MinimizedVideoDisplay({this.video, this.heroId, this.betterPlayerController});

  @override
  _MinimizedVideoDisplayState createState() => _MinimizedVideoDisplayState();
}

class _MinimizedVideoDisplayState extends State<MinimizedVideoDisplay> {
  ColorFilter colorFilter;
  VisualFilter currentVisualFilter;

  bool hasSetFilter = false;

  @override
  void initState() {
    super.initState();
  }

  void updateVisualFilter(bool value, VisualFilter filter) {
    if (!this.mounted) return;

    switch (filter) {
      case VisualFilter.grayscale:
        setState(() {
          colorFilter = value ? GRAYSCALE_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.grayscale : VisualFilter.normal;
        });
        break;

      case VisualFilter.inverted:
        setState(() {
          colorFilter = value ? INVERTED_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.inverted : VisualFilter.normal;
        });
        break;

      /// normal
      default:
        setState(() {
          colorFilter = NORMAL_FILTER;
          currentVisualFilter = VisualFilter.normal;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    /// TODO: make centered video expand and the rest with fixed size.
    final double iconSize = 0.1 * size.height;
    final double miniVideoSize = 0.6 * size.height;

    final bool hasSeries =
        widget.video.series != null || widget.video.series != "";

    if (!hasSetFilter) {
      hasSetFilter = true;

      currentVisualFilter = Config.of(context).configSettings.filter;

      switch (currentVisualFilter) {
        case VisualFilter.grayscale:
          colorFilter = GRAYSCALE_FILTER;
          break;

        case VisualFilter.inverted:
          colorFilter = INVERTED_FILTER;
          break;

        default:
          colorFilter = NORMAL_FILTER;
      }
    }

    return ColorFiltered(
      colorFilter: colorFilter,
      child: WillPopScope(
          child: Material(
            color: Theme.of(context).accentColor,
            child: FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: LimitedBox(

                  /// TODO: fix
                  maxWidth: 0.85 * size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Left side icons.
                          Container(
                            height: miniVideoSize,
                            padding: EdgeInsets.symmetric(
                                vertical: 0.05 * size.height),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SvgButton(
                                  asset: SvgAsset.back_icon,
                                  size: iconSize,
                                  onPressed: () {
                                    widget.betterPlayerController.dispose();
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          ),

                          /// Centered video.
                          Container(
                            padding: EdgeInsets.fromLTRB(0.01 * size.width,
                                0.05 * size.height, 0.01 * size.width, 0.0),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(0.075 * size.height),
                              child: InheritedVideoDisplay(
                                  context: context,
                                  isMinimized: true,
                                  toggleDisplay: toggleDisplay,
                                  child: Container(
                                    height: miniVideoSize,
                                    child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: MediaQuery(
                                          data: MediaQueryData(
                                              size: Size(miniVideoSize * 16 / 9,
                                                  miniVideoSize)),
                                          child: Hero(
                                            tag: widget.heroId,
                                            child: BetterPlayer(
                                              controller:
                                                  widget.betterPlayerController,
                                            ),
                                          ),
                                        )),
                                  )),
                            ),
                          ),

                          /// Right side icons.
                          Container(
                            height: miniVideoSize,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ChromeCast(
                                  video: widget.video,
                                  iconSize: iconSize,
                                ),
                                SvgIcon(
                                    asset: SvgAsset.videos_icon, size: iconSize)
                              ],
                            ),
                          ),
                        ],
                      ),

                      /// FeaturedCardList(isMinimized: true),
                      Expanded(
                        child: Container(
                          /// 0.35 = hight factor of suggested video, 0.05 = padding of video center
                          padding: EdgeInsets.symmetric(
                              vertical: (size.height -
                                      0.25 * size.height -
                                      0.1 * size.height -
                                      miniVideoSize) /
                                  2),
                          child: SearchCardList(
                            search: hasSeries
                                ? widget.video.series
                                : widget.video.title,
                            video: widget.video,
                            isMinimized: true,
                          ),
                        ),
                      ),
                    ],
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          onWillPop: () {
            widget.betterPlayerController.dispose();
            Navigator.of(context).pop();
            return Future<bool>.value(true);
          }),
    );
  }

  void toggleDisplay() {
    Navigator.of(context).pop();
  }
}
