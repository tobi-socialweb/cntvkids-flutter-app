import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/pages/display/fullscreen_display_page.dart';
import 'package:cntvkids_app/pages/display/minimized_display_page.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cntvkids_app/common/constants.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/video_controls_bar_widget.dart';

import 'package:provider/provider.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoDisplayController extends StatefulWidget {
  final Video video;
  final bool startFullScreen;

  VideoDisplayController({this.video, this.startFullScreen = false});

  @override
  _VideoDisplayControllerState createState() => _VideoDisplayControllerState();
}

class _VideoDisplayControllerState extends State<VideoDisplayController> {
  BetterPlayer videoPlayer;
  Completer completer = new Completer();

  /// Video player controller and data source.
  BetterPlayerController videoController;
  BetterPlayerDataSource videoDataSource;

  @override
  void initState() {
    super.initState();

    /// Set video source.
    videoDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.video.useSignLang
            ? widget.video.signLangVideoUrl
            : widget.video.videoUrl);

    /// Define values for the player controller.
    videoController = BetterPlayerController(
        BetterPlayerConfiguration(
          controlsConfiguration: BetterPlayerControlsConfiguration(
            customControlsBuilder: (controller) => VideoControlsBar(
              video: widget.video,
              controller: controller,
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
        betterPlayerDataSource: videoDataSource);
  }

  /// A future completer for initializing the video.
  Future<dynamic> _getFutureVideo() {
    videoPlayer = BetterPlayer(controller: videoController);

    videoPlayer.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(videoPlayer);
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.finished &&
          context != null) {
        /// Only call the following once after finishing the video.
        Audio.play(MediaAsset.mp3.click);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return VideoDisplayController(
            video: widget.video.next,
          );
        }));
      }
    });

    return completer.future;
  }

  void saveHistory(String videoJson) {
    List<String> videoList = StorageManager.videoHistory;

    if (videoList == null) videoList = [];
    videoList.add(videoJson);

    StorageManager.saveData(HISTORY_VIDEOS_KEY, videoList);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DisplayNotifier>(
      create: (_) => DisplayNotifier(!widget.startFullScreen),
      child: Consumer<DisplayNotifier>(
        builder: (context, value, child) {
          if (value.isMinimized) {
            return MinimizedVideoDisplay(
              video: widget.video,
              player: _getFutureVideo(),
            );
          } else {
            return FullScreenVideoDisplay(
              video: widget.video,
              player: _getFutureVideo(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    saveHistory(widget.video.toString());

    super.dispose();
  }
}

class DisplayNotifier extends ChangeNotifier {
  bool isMinimized;

  DisplayNotifier(this.isMinimized);

  void toggleDisplay() {
    Audio.play(MediaAsset.mp3.click);

    isMinimized = !isMinimized;

    notifyListeners();
  }
}
