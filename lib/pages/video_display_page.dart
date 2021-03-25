import 'dart:async';
import 'dart:math';

import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/widgets/app_state_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:focus_detector/focus_detector.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/menu/search_detail_page.dart';

import 'package:cntvkids_app/widgets/background_music.dart';
import 'package:cntvkids_app/widgets/custom_controls_widget.dart';

import 'package:cntvkids_app/widgets/video_cast_widget.dart';
import 'package:provider/provider.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

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
  final BetterPlayerController betterPlayerController;

  const VideoDisplay(
      {Key key, @required this.video, this.betterPlayerController})
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

  bool displayedAlert = false;

  @override
  void initState() {
    super.initState();

    /// If controller was already defined, then save to variable.
    if (widget.betterPlayerController != null) {
      _betterPlayerController = widget.betterPlayerController;
      return;
    }

    /// Set video source.
    if (widget.video.useSignLang) {
      _betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, widget.video.signLangVideoUrl);
    } else {
      _betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, widget.video.videoUrl);
    }

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
            return Center(child: Text(errorMessage));
          },
        ),
        betterPlayerDataSource: _betterPlayerDataSource);
  }

  /// Display alert for liking the video.
  likeVideoAlert(BuildContext context) async {
    double sizeAlertHeight = 0.1 * MediaQuery.of(context).size.height;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Te gusto el video: \"${widget.video.title}\" ?"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: Container(
                      height: sizeAlertHeight,
                      alignment: Alignment.centerLeft,
                      child: Text("No")),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Container(
                      height: sizeAlertHeight,
                      alignment: Alignment.centerRight,
                      child: Text("Si")),
                  onPressed: () async {
                    String itemId = widget.video.id;
                    int userId = await getUserId(context);
                    String userIp =
                        Provider.of<AppStateConfig>(context, listen: false).ip;

                    try {
                      String requestUrl =
                          "https://cntvinfantil.cl/wp-json/wp-ulike-pro/v1/vote/?item_id=$itemId&user_id=$userId&type=post&status=like&user_ip=$userIp";

                      Response response = await customDio.post(requestUrl,
                          options: buildCacheOptions(Duration(days: 3),
                              maxStale: Duration(days: 7)));

                      /// If request has succeeded.
                      if (response.statusCode == 200) {
                        print("DEBUG: response succeded: ${response.data}");
                      }
                    } on DioError catch (e) {
                      if (DioErrorType.RECEIVE_TIMEOUT == e.type ||
                          DioErrorType.CONNECT_TIMEOUT == e.type) {
                        /// Couldn't reach the server.
                        throw (ERROR_MESSAGE[ErrorTypes.UNREACHABLE]);
                      } else if (DioErrorType.RESPONSE == e.type) {
                        /// If request was badly formed.
                        if (e.response.statusCode == 400) {
                          print("reponse 400");

                          /// Otherwise.
                        } else {
                          print(e.message);
                          print(e.request.toString());
                        }
                      } else if (DioErrorType.DEFAULT == e.type) {
                        if (e.message.contains('SocketException')) {
                          /// No connection to internet.
                          throw (ERROR_MESSAGE[ErrorTypes.NO_CONNECTION]);
                        }
                      } else {
                        /// Unknown problem connecting to server.
                        throw (ERROR_MESSAGE[ErrorTypes.UNKNOWN]);
                      }
                    }

                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  /// A future completer for initializing the video.
  Future<dynamic> _getFutureVideo() {
    video = BetterPlayer(controller: _betterPlayerController);

    video.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(video);
      }
      if (!displayedAlert &&
          event.betterPlayerEventType == BetterPlayerEventType.finished &&
          context != null) {
        likeVideoAlert(context);
        displayedAlert = true;
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedVideoDisplay(
      context: context,
      isMinimized: false,
      toggleDisplay: toggleDisplay,
      child: FutureBuilder(
          future: _getFutureVideo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Hero(
                    tag: widget.video.id,
                    child: snapshot.data,
                  ));
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
    );
  }

  /// Change to minimized display when popping or using the back button.
  void toggleDisplay() {
    MusicEffect.play(MediaAsset.mp3.go_back);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MinimizedVideoDisplay(
        video: widget.video,
        betterPlayerController: _betterPlayerController,
      );
    }));
  }
}

/// Shows video controls and other related videos.
class MinimizedVideoDisplay extends StatefulWidget {
  final Video video;
  final BetterPlayerController betterPlayerController;
  MinimizedVideoDisplay({this.video, this.betterPlayerController});

  @override
  _MinimizedVideoDisplayState createState() => _MinimizedVideoDisplayState();
}

class _MinimizedVideoDisplayState extends State<MinimizedVideoDisplay> {
  SearchCardList suggested;
  bool shouldDispose = true;

  @override
  void initState() {
    super.initState();

    bool hasSeries = widget.video.series != null || widget.video.series != "";

    suggested = SearchCardList(
      search: hasSeries ? widget.video.series : widget.video.title,
      video: widget.video,
      isMinimized: true,
    );
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

    return FocusDetector(
      /// TODO: Fix focus lost when sending app to background and video getting disposed.
      onFocusLost: () {
        if (shouldDispose) {
          widget.betterPlayerController.dispose(forceDispose: true);
        }
      },
      child: Material(
        color: Theme.of(context).accentColor,
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
                          MusicEffect.play(MediaAsset.mp3.go_back);
                          widget.betterPlayerController.dispose();
                          Navigator.of(context).pop();
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

                          MusicEffect.play(MediaAsset.mp3.click);
                          Navigator.pop(context);

                          /// When tapped, open video.
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return VideoDisplay(
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
                    child: InheritedVideoDisplay(
                        context: context,
                        isMinimized: true,
                        toggleDisplay: toggleDisplay,
                        child: Container(
                          height: videoHeight,
                          child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: MediaQuery(
                                data: MediaQueryData(
                                    size: Size(
                                        videoHeight * 16 / 9, videoHeight)),
                                child: Hero(
                                  tag: widget.video.id,
                                  child: BetterPlayer(
                                    controller: widget.betterPlayerController,
                                  ),
                                ),
                              )),
                        )),
                  ),

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

                          MusicEffect.play(MediaAsset.mp3.click);
                          Navigator.pop(context);

                          /// When tapped, open video.
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return VideoDisplay(
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

  void toggleDisplay() {
    if (!mounted) return;
    setState(() {
      shouldDispose = false;
    });
    MusicEffect.play(MediaAsset.mp3.click);
    Navigator.of(context).pop();
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
