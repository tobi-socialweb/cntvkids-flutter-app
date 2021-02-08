import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/featured_page.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_controls_widget.dart';

typedef bool BoolCallback();

/// Used to keep a reference of this context, for a later navigator pop.
class InheritedVideoDisplay extends InheritedWidget {
  final BuildContext context;
  final VoidCallback toggleDisplay;
  final bool isMinimized;
  final VoidCallback popDisplay;

  InheritedVideoDisplay(
      {this.context,
      this.toggleDisplay,
      this.isMinimized,
      this.popDisplay,
      child})
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

  VideoDisplay(
      {@required this.video,
      @required this.heroId,
      this.betterPlayerController});

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  /// Video player controller and data source.
  BetterPlayerController _betterPlayerController;
  BetterPlayerDataSource _betterPlayerDataSource;

  @override
  void initState() {
    super.initState();

    /// If
    if (widget.betterPlayerController != null) {
      print(
          "DEBUG: when calling VideoDisplay (full screen), betterPlayerController was not null!");
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

  @override
  Widget build(BuildContext context) {
    return InheritedVideoDisplay(
      context: context,
      isMinimized: false,
      toggleDisplay: toggleDisplay,
      popDisplay: popDisplay,
      child: FutureBuilder(builder: (context, snapshot) {
        return WillPopScope(
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: widget.heroId,
                  child: BetterPlayer(
                    controller: _betterPlayerController,
                  ),
                )),

            /// When using the 'back' button, toggle minimize.
            onWillPop: () {
              return Future<bool>.value(true);
            });
      }),
    );
  }

  void toggleDisplay() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MinimizedVideoDisplay(
        video: widget.video,
        heroId: widget.heroId,
        betterPlayerController: _betterPlayerController,
      );
    }));
  }

  void popDisplay() {
    _betterPlayerController.dispose();
    Navigator.of(context).pop();
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Material(
          color: Colors.red,
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                            R.svg.back_icon(width: 0.0, height: 0.0).asset,
                            width: 20.0,
                            height: 20.0),
                        InheritedVideoDisplay(
                            context: context,
                            isMinimized: true,
                            child: Container(
                              width: 200.0,
                              height: 200.0,
                              child:
                                  FutureBuilder(builder: (context, snapshot) {
                                return AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Hero(
                                      tag: widget.heroId,
                                      child: BetterPlayer(
                                        controller:
                                            widget.betterPlayerController,
                                      ),
                                    ));
                              }),
                            )),
                        SvgPicture.asset(
                            R.svg.record_icon(width: 0.0, height: 0.0).asset,
                            width: 20.0,
                            height: 20.0),
                      ],
                    ),
                  ],
                ),
                Featured(isMinimized: true),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        onWillPop: () {
          print("DEBUG: popping screen when minimized");
          widget.betterPlayerController.dispose();
          Navigator.of(context).pop();
          return Future<bool>.value(true);
        });
  }
}
