import 'package:flutter/material.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:cntvkids_app/models/video_model.dart';

class ChromeCast extends StatefulWidget {
  static const _iconSize = 50.0;
  final Video video;

  ChromeCast({@required this.video});
  @override
  _ChromeCastState createState() => _ChromeCastState();
}

class _ChromeCastState extends State<ChromeCast> {
  ChromeCastController _controller;
  AppState _state = AppState.idle;
  bool _playing = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        ChromeCastButton(
            size: ChromeCast._iconSize,
            color: Colors.black,
            onButtonCreated: _onButtonCreated,
            onSessionStarted: _onSessionStarted,
            onSessionEnded: () => setState(() => _state = AppState.idle),
            onRequestCompleted: _onRequestCompleted,
            onRequestFailed: _onRequestFailed),
        _handleState(),
      ],
    ));
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _RoundIconButton(
          icon: Icons.replay_10,
          onPressed: () => _controller.seek(relative: true, interval: -10.0),
        ),
        _RoundIconButton(
            icon: _playing ? Icons.pause : Icons.play_arrow,
            onPressed: _playPause),
        _RoundIconButton(
          icon: Icons.forward_10,
          onPressed: () => _controller.seek(relative: true, interval: 10.0),
        )
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

  Future<void> _onButtonCreated(ChromeCastController controller) async {
    _controller = controller;
    await _controller.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    setState(() => _state = AppState.connected);
    await _controller.loadMedia(widget.video.videoUrl);
  }

  Future<void> _onRequestCompleted() async {
    final playing = await _controller.isPlaying();
    setState(() {
      _state = AppState.mediaLoaded;
      _playing = playing;
    });
  }

  Future<void> _onRequestFailed(String error) async {
    setState(() => _state = AppState.error);
    print(error);
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

enum AppState { idle, connected, mediaLoaded, error }
