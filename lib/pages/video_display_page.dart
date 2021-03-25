import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/widgets/app_state_config.dart';
import 'package:cntvkids_app/widgets/sound_effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:focus_detector/focus_detector.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/menu/search_detail_page.dart';
import 'package:cntvkids_app/widgets/custom_controls_widget.dart';

import 'package:cntvkids_app/widgets/video_cast_widget.dart';
import 'package:provider/provider.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  SoundEffect _soundEffect;

  @override
  void initState() {
    super.initState();
    _soundEffect = SoundEffect();
    print("serie:" + widget.video.series);
    print("titulo: " + widget.video.title);
    if (widget.betterPlayerController != null) {
      _betterPlayerController = widget.betterPlayerController;
      return;
    }
    print("Debug: useSignLang= ${widget.video.useSignLang}");

    /// Set video source.
    if (widget.video.useSignLang) {
      print("Debug: useSignLang= ${widget.video.signLangVideoUrl}");
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
            print("DEBUG: Error: $errorMessage");
            return Center(child: Text(errorMessage));
          },
        ),
        betterPlayerDataSource: _betterPlayerDataSource);
  }

  void saveFavorites(String itemId, String title, String thumbnailurl,
      String url, String signurl) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listId = prefs.getStringList(FAVORITE_ID_KEY);
    List<String> listTitles = prefs.getStringList(FAVORITE_TITLES_KEY);
    List<String> listThumbnails = prefs.getStringList(FAVORITE_THUMBNAILS_KEY);
    List<String> listUrls = prefs.getStringList(FAVORITE_URLS_KEY);
    List<String> listSignUrls = prefs.getStringList(FAVORITE_SIGNURLS_KEY);
    (listId != null) ? listId.insert(0, itemId) : listId = [itemId];
    print(listId);
    (listTitles != null) ? listTitles.insert(0, title) : listTitles = [title];
    print(listTitles);
    (listThumbnails != null)
        ? listThumbnails.insert(0, thumbnailurl)
        : listThumbnails = [thumbnailurl];
    print(listThumbnails);
    (listUrls != null) ? listUrls.insert(0, url) : listUrls = [url];
    print(listUrls);
    (listSignUrls != null)
        ? listSignUrls.insert(0, signurl)
        : listSignUrls = [signurl];
    print(listSignUrls);
    await prefs.setStringList(FAVORITE_ID_KEY, listId);
    await prefs.setStringList(FAVORITE_TITLES_KEY, listTitles);
    await prefs.setStringList(FAVORITE_THUMBNAILS_KEY, listThumbnails);
    await prefs.setStringList(FAVORITE_URLS_KEY, listUrls);
    await prefs.setStringList(FAVORITE_SIGNURLS_KEY, listSignUrls);
  }

  likeAlert(BuildContext context) async {
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
                    String itemId = widget.video.id.toString();
                    saveFavorites(
                        itemId,
                        widget.video.title,
                        widget.video.thumbnailUrl,
                        widget.video.videoUrl,
                        widget.video.signLangVideoUrl);
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

  Future<dynamic> _getFutureVideo() {
    video = BetterPlayer(controller: _betterPlayerController);

    video.controller.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        completer.complete(video);
      }
      if (showOneAlert &&
          event.betterPlayerEventType == BetterPlayerEventType.finished &&
          context != null) {
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
              return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Hero(
                    tag: widget.heroId,
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

  void toggleDisplay() {
    _soundEffect.play(MediaAsset.mp3.go_back);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MinimizedVideoDisplay(
        video: widget.video,
        heroId: widget.heroId,
        betterPlayerController: _betterPlayerController,
      );
    }));
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
  bool shouldDispose = true;
  SoundEffect _soundEffect;

  @override
  void initState() {
    _soundEffect = SoundEffect();
    bool hasSeries = widget.video.series != null || widget.video.series != "";
    suggested = SearchCardList(
      search: hasSeries ? widget.video.series : widget.video.title,
      video: widget.video,
      isMinimized: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    /// TODO: make centered video expand and the rest with fixed size.
    final double iconSize = 0.1 * size.height;
    final double miniVideoSize = 0.6 * size.height;

    return FocusDetector(
      onVisibilityLost: () {
        print("Debug: vista minimizada Perdio visibilidad");
        if (shouldDispose) {
          print("Debug: dipose al entrar a otro video");
          widget.betterPlayerController.dispose(forceDispose: true);
        }
      },
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
                              _soundEffect.play(MediaAsset.mp3.go_back);
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
            toggleDisplay();
          },
        ),
      ),
    );
  }

  void toggleDisplay() {
    if (!mounted) return;
    setState(() {
      shouldDispose = false;
    });
    _soundEffect.play(MediaAsset.mp3.click);
    Navigator.of(context).pop();
  }
}
