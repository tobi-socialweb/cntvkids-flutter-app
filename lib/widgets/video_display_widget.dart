import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/featured_page.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'custom_controls_widget.dart';

/// Used to keep a reference of this context, for a later navigator pop.
class InheritedVideoDisplay extends InheritedWidget {
  final BuildContext context;
  final VoidCallback toggle;

  InheritedVideoDisplay({this.context, this.toggle, Widget child})
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

  VideoDisplay({@required this.video, @required this.heroId});

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  bool isMinimized;

  /// Video player controller and data source.
  BetterPlayerController _betterPlayerController;
  BetterPlayerDataSource betterPlayerDataSource;

  @override
  void initState() {
    super.initState();

    isMinimized = false;

    /// Set video source.
    betterPlayerDataSource = BetterPlayerDataSource(
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
        betterPlayerDataSource: betterPlayerDataSource);
  }

  @override
  Widget build(BuildContext context) {
    return isMinimized
        ? Container(
            decoration: BoxDecoration(color: Colors.cyan),
            child: InheritedVideoDisplay(
              context: context,
              toggle: toggleMinimized,
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
                              toggle: toggleMinimized,
                              child: Container(
                                width: 200.0,
                                height: 200.0,
                                child:
                                    FutureBuilder(builder: (context, snapshot) {
                                  return WillPopScope(
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: BetterPlayer(
                                          controller: _betterPlayerController,
                                        ),
                                      ),

                                      /// When using the 'back' button, close the video.
                                      onWillPop: () {
                                        setState(() {
                                          _betterPlayerController.dispose();
                                        });
                                        return Future<bool>.value(true);
                                      });
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
            ))
        : InheritedVideoDisplay(
            context: context,
            toggle: toggleMinimized,
            child: FutureBuilder(builder: (context, snapshot) {
              return WillPopScope(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer(
                      controller: _betterPlayerController,
                    ),
                  ),

                  /// When using the 'back' button, close the video.
                  onWillPop: () {
                    setState(() {
                      _betterPlayerController.dispose();
                    });
                    return Future<bool>.value(true);
                  });
            }),
          );
  }

  void toggleMinimized() {
    setState(() {
      isMinimized = !isMinimized;
    });
  }
}
