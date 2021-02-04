import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'custom_controls_widget.dart';

/// Shows video fullscreen
class VideoDisplay extends StatefulWidget {
  final Video video;
  final String heroId;

  VideoDisplay({this.video, this.heroId});

  @override
  _VideoDisplayState createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  /// Video player controller and data source.
  BetterPlayerController _betterPlayerController;
  BetterPlayerDataSource betterPlayerDataSource;
  bool _playingVideo = true;

  @override
  void initState() {
    super.initState();

    _playingVideo = true;

    /// Set video source.
    betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network, widget.video.videoUrl);

    /// Define values for the player controller.
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            customControlsBuilder: (controller) =>
                CustomPlayerControls(controller: controller),
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
    if (!_playingVideo) {
      this.dispose();
      Navigator.pop(context);
    }

    return WillPopScope(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(
            controller: _betterPlayerController,
          ),
        ),

        /// When using the 'back' button, close the video.
        onWillPop: () {
          _betterPlayerController.pause();
          setState(() {
            _playingVideo = false;
          });
          return Future<bool>.value(true);
        });
  }

  @override
  void dispose() {
    //_betterPlayerController.videoPlayerController.dispose();
    _betterPlayerController.dispose();
    super.dispose();
  }
}
