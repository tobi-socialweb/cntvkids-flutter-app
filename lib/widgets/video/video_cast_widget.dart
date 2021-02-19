import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/common/helpers.dart';

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

class ChromeCast extends StatefulWidget {
  final double iconSize;
  final Video video;
  ChromeCast({@required this.video, this.iconSize});
  @override
  _ChromeCastState createState() => _ChromeCastState();
}

class _ChromeCastState extends State<ChromeCast> {
  ChromeCastController _controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AirPlayButton(
          size: widget.iconSize,
          color: Colors.white,
          activeColor: Colors.amber,
          onRoutesOpening: () => print('opening'),
          onRoutesClosed: () => print('closed'),
        ),
        ChromeCastButton(
          size: widget.iconSize,
          color: Colors.white,
          onButtonCreated: _onButtonCreated,
          onSessionStarted: _onSessionStarted,
        ),
      ],
    );
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChromeCastView(
          video: widget.video,
          iconSize: widget.iconSize,
          controlador: _controller);
    }));
  }
}

class ChromeCastView extends StatefulWidget {
  final double iconSize;
  final Video video;
  final ChromeCastController controlador;
  ChromeCastView({@required this.video, this.iconSize, this.controlador});
  @override
  _ChromeCastViewState createState() => _ChromeCastViewState();
}

class _ChromeCastViewState extends State<ChromeCastView> {
  void initState() {
    super.initState();
    cargarMedia();
  }

  void cargarMedia() async {
    if (await widget.controlador.isConnected()) {
      widget.controlador.loadMedia(widget.video.videoUrl);
    } else {
      print("no esta conectado al chromecast");
    }
  }

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
                            InkWell(
                              child: SvgIcon(
                                asset: R.svg.back_icon,
                                size: iconSize,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
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
                                          top: 75,
                                          left: 50,
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
                                size: widget.iconSize, color: Colors.black)
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
