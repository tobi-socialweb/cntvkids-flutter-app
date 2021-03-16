import 'dart:async';

import 'package:cntvkids_app/pages/menu/search_detail_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';
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

  const VideoDisplay(
      {Key key,
      @required this.video,
      @required this.heroId,
      this.betterPlayerController})
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

  bool showOneAlert = true;

  @override
  void initState() {
    super.initState();
    print("serie:" + widget.video.series);
    print("titulo: " + widget.video.title);
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

  likeAlert(BuildContext context) {
    double sizeAlertHeight = 0.1 * MediaQuery.of(context).size.height;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Te gusto el video: ${widget.video.title}?"),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: Container(
                      height: sizeAlertHeight,
                      alignment: Alignment.centerLeft,
                      child: Text("No")),
                  onPressed: () => print("No me gustó"),
                ),
                ElevatedButton(
                  child: Container(
                      height: sizeAlertHeight,
                      alignment: Alignment.centerRight,
                      child: Text("si")),
                  onPressed: () => print("si me gustó"),
                ),
              ],
            ),
          );
        });
  }

  Future<dynamic> _getFutureVideo() {
    video = BetterPlayer(controller: _betterPlayerController);

    video.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(video);
      }
      if (showOneAlert &&
          event.betterPlayerEventType == BetterPlayerEventType.finished &&
          context != null) {
        print("hola");
        likeAlert(context);
        showOneAlert = false;
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
              return WillPopScope(
                  child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Hero(
                        tag: widget.heroId,
                        child: snapshot.data,
                      )),

                  /// When using the 'back' button, toggle minimize.
                  onWillPop: () {
                    MusicEffect.play("sounds/go_back/go_back.mp3");
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
    );
  }

  void toggleDisplay() {
    MusicEffect.play("sounds/go_back/go_back.mp3");
    Navigator.push(context, MaterialPageRoute(builder: (context) {
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
  SearchCardList suggested;

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

    /// TODO: make centered video expand and the rest with fixed size.
    final double iconSize = 0.1 * size.height;
    final double miniVideoSize = 0.6 * size.height;

    return WillPopScope(
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
                        padding:
                            EdgeInsets.symmetric(vertical: 0.05 * size.height),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SvgButton(
                              asset: SvgAsset.back_icon,
                              size: iconSize,
                              onPressed: () {
                                MusicEffect.play("sounds/go_back/go_back.mp3");
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
                        padding:
                            EdgeInsets.symmetric(vertical: 0.05 * size.height),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Stack(
                              children: [
                                SvgIcon(
                                  asset: SvgAsset.chromecast_icon,
                                  size: iconSize,
                                ),
                                ChromeCast(
                                  video: widget.video,
                                  iconSize: iconSize,
                                ),
                              ],
                            )
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
                      child: suggested,
                    ),
                  )
                ],
              ),
            ),
            onPressed: () {
              MusicEffect.play("sounds/click/click.mp3");
              Navigator.of(context).pop();
            },
          ),
        ),
        onWillPop: () {
          widget.betterPlayerController.dispose();
          MusicEffect.play("sounds/go_back/go_back.mp3");
          Navigator.of(context).pop();
          return Future<bool>.value(true);
        });
  }

  void toggleDisplay() {
    MusicEffect.play("sounds/go_back/go_back.mp3");
    Navigator.of(context).pop();
  }
}
