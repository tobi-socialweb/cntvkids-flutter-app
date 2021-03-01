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
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final double iconSize = 0.15 * size.height;
    final double miniVideoSize = 0.6 * size.height;

    return WillPopScope(
        child: Material(
          color: Theme.of(context).accentColor,
          child: LimitedBox(
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
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        ),
                      ),

                      /// Centered video.
                      Container(
                          padding: EdgeInsets.fromLTRB(25, 50, 25, 0),
                          child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(0.075 * size.height),
                              child: MediaQuery(
                                  data: MediaQueryData(
                                      size: Size(miniVideoSize * 16 / 9,
                                          miniVideoSize)),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: widget.video.thumbnailUrl,
                                        filterQuality: FilterQuality.high,
                                        fit: BoxFit.fitHeight,
                                        height: miniVideoSize,
                                      ),
                                      Positioned(
                                          top: 0.25 * miniVideoSize,
                                          left: 0.25 * miniVideoSize,
                                          child: _mediaControls())
                                    ],
                                  )))),

                      /// Right side icons.
                      Container(
                        height: miniVideoSize,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ChromeCastButton(
                                size: widget.iconSize, color: Colors.white)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),

        /// TODO: fix pop
        onWillPop: () {
          Navigator.of(context).pop();
          print("intento devolverse");
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
    return RaisedButton(
        child: Icon(icon, color: Colors.white),
        padding: EdgeInsets.all(16.0),
        color: Colors.black,
        shape: CircleBorder(),
        onPressed: onPressed);
  }
}
