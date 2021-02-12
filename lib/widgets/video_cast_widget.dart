import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:cntvkids_app/pages/featured_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChromeCast extends StatefulWidget {
  final double iconSize;
  final Video video;
  ChromeCast({@required this.video, this.iconSize = 50.0});
  @override
  _ChromeCastState createState() => _ChromeCastState();
}

enum AppState { idle, connected, mediaLoaded, error }

class _ChromeCastState extends State<ChromeCast> {
  ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool _playing = false;
  ChromeCastButton boton;
  int contador = 0;
  @override
  Widget build(BuildContext context) {
    return boton = ChromeCastButton(
        size: widget.iconSize,
        color: Colors.black,
        onButtonCreated: _onButtonCreated,
        onSessionStarted: _onSessionStarted,
        onSessionEnded: _onSessionEnded,
        onRequestCompleted: _onRequestCompleted,
        onRequestFailed: _onRequestFailed);
  }

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    setState(() => _state = AppState.connected);
    await _controller.loadMedia(widget.video.videoUrl);
  }

  Future<void> _onSessionEnded() async {
    setState(() => _state = AppState.idle);
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      print(contador);
      return ChromeCastView(
          castController: _handleState(),
          castingButton: boton,
          contador: contador,
          video: widget.video);
    }));
  }

  Future<void> _onRequestFailed(String error) async {
    setState(() => _state = AppState.error);
    print(error);
  }

  Widget _handleState() {
    switch (_state) {
      case AppState.idle:
        return Text('ChromeCast no conectada');
      case AppState.connected:
        return Text('Video no cargado');
      case AppState.mediaLoaded:
        return _mediaControls();
      case AppState.error:
        return Text('Ha ocurrido un error');
      default:
        return Container();
    }
  }

  Widget _mediaControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _RoundIconButton(
            icon: Icons.replay_10,
            onPressed: () {
              _controller.seek(relative: true, interval: -10.0);
              print("DEBUG: se adelanto");
              contador++;
            }),
        _RoundIconButton(
            icon: _playing ? Icons.pause : Icons.play_arrow,
            onPressed: () {
              _playPause();
              contador++;
              print("DEBUG: play/stop");
            }),
        _RoundIconButton(
            icon: Icons.forward_10,
            onPressed: () {
              _controller.seek(relative: true, interval: 10.0);
              contador++;
              print("DEBUG: se retrocedio");
            })
      ],
    );
  }

  Future<void> _playPause() async {
    final playing = await _controller.isPlaying();
    if (playing) {
      await _controller.pause();
    } else {
      await _controller.play();
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
        color: Colors.blue,
        shape: CircleBorder(),
        onPressed: onPressed);
  }
}

class ChromeCastView extends StatelessWidget {
  final Widget castController;
  final ChromeCastButton castingButton;
  final int contador;
  final Video video;
  ChromeCastView(
      {@required this.castController,
      @required this.castingButton,
      this.contador,
      this.video});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        child: Material(
          color: Theme.of(context).accentColor,
          child: LimitedBox(

              /// TODO: fix
              maxWidth: 0.85 * size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.blue)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.yellow)),
                          height: 0.65 * size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SvgPicture.asset(
                                R.svg.back_icon(width: 0.0, height: 0.0).asset,
                                width: 60.0,
                                height: 60.0,
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            CachedNetworkImage(
                                imageUrl: video.thumbnailUrl,
                                filterQuality: FilterQuality.high,
                                height: 0.4 * size.height,
                                fit: BoxFit.fitHeight),
                            castController,
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.yellow)),
                          height: 0.65 * size.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              castingButton,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.green)),
                    child: Featured(isMinimized: true),
                  ),
                ],
              )),
        ),
        onWillPop: () {
          var i = 0;
          while (i < contador + 1) {
            Navigator.of(context).pop();
            i++;
          }
          return Future<bool>.value(true);
        });
  }
}
