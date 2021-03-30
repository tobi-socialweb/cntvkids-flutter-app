import 'dart:async';
import 'package:cntvkids_app/common/constants.dart';

import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:cntvkids_app/pages/search/search_card_list.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_video_cast/flutter_video_cast.dart';

import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/video_model.dart';

class ChromeCastView extends StatefulWidget {
  final double iconSize;
  final Video video;
  final ChromeCastController controlador;
  ChromeCastView({@required this.video, this.iconSize, this.controlador});
  @override
  _ChromeCastViewState createState() => _ChromeCastViewState();
}

class _ChromeCastViewState extends State<ChromeCastView> {
  bool _playing = false;

  CachedNetworkImageProvider imgProvider;
  Completer completer = new Completer();

  SoundEffect _soundEffect;

  @override
  void initState() {
    /// Set the URL and add a listener to complete the future.
    imgProvider = new CachedNetworkImageProvider(widget.video.thumbnailUrl);
    imgProvider.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));
    _soundEffect = SoundEffect();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final double iconSize = 0.15 * size.height;
    final double miniVideoSize = 0.6 * size.height;
    final double width = miniVideoSize * 16 / 9;

    final bool hasSeries =
        widget.video.series != null || widget.video.series != "";

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
                                _soundEffect.play(MediaAsset.mp3.go_back);
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
                            child: Stack(
                              children: [
                                Image(
                                  image: imgProvider,
                                  width: width,
                                  height: miniVideoSize,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.medium,
                                ),
                                Positioned(
                                  top: 0.25 * miniVideoSize,
                                  left: 0.25 * miniVideoSize,
                                  child: _mediaControls(),
                                ),
                              ],
                            )),
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
                                //// TODO: fix ulr sended to chrome cast
                                ChromeCastButton(
                                    size: iconSize, color: Colors.white),
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
                      child: SearchCardList(
                        search: hasSeries
                            ? widget.video.series
                            : widget.video.title,
                        video: widget.video,
                        isMinimized: true,
                      ),
                    ),
                  )
                ],
              ),
            ),
            onPressed: () {
              _soundEffect.play(MediaAsset.mp3.click);
              Navigator.of(context).pop();
            },
          ),
        ),
        onWillPop: () {
          _soundEffect.play(MediaAsset.mp3.go_back);
          Navigator.of(context).pop();
          return Future<bool>.value(true);
        });
  }

  Widget _mediaControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _RoundIconButton(
            icon: Icons.replay_10,
            onPressed: () {
              widget.controlador.seek(relative: true, interval: -10.0);
            }),
        _RoundIconButton(
            icon: _playing ? Icons.pause : Icons.play_arrow,
            onPressed: () {
              _playPause();
            }),
        _RoundIconButton(
            icon: Icons.forward_10,
            onPressed: () {
              widget.controlador.seek(relative: true, interval: 10.0);
            })
      ],
    );
  }

  Future<void> _playPause() async {
    final playing = await widget.controlador.isPlaying();
    if (playing) {
      await widget.controlador.pause();
    } else {
      await widget.controlador.play();
    }
    setState(() => _playing = !playing);
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  _RoundIconButton({@required this.icon, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return RaisedButton(
        child: Icon(icon, color: Colors.white),
        padding: EdgeInsets.all(16.0),
        color: Colors.black,
        shape: CircleBorder(),
        onPressed: onPressed);
  }
}
