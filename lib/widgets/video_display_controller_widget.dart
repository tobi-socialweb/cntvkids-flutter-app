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

  /// TODO:
  bool displayedAlert = false;

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
      if (!displayedAlert &&
          event.betterPlayerEventType == BetterPlayerEventType.finished &&
          context != null) {
        /// Only call the following once after finishing the video.
        displayedAlert = true;

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
                    widget.video.originInfo = null;
                    // saveFavorites(widget.video.toString());
                    print("DEBUG: detalles de video a guardar ....");
                    print("DEBUG: " + widget.video.title);
                    print("DEBUG: " + itemId);
                    int userId = await getUserId(context);
                    print("DEBUG: user id$userId");
                    String userIp =
                        Provider.of<AppStateConfig>(context, listen: false).ip;
                    print("DEBUG: user " + userIp);

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
