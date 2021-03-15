import 'package:flutter/material.dart';
import 'package:flutter_video_cast/flutter_video_cast.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/pages/cast_display_page.dart';

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
    setState(() => _controller = controller);
    _controller?.addSessionListener();
  }

  Future<void> _onSessionStarted() async {
    _controller.loadMedia(widget.video.videoUrl);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ChromeCastView(
          video: widget.video,
          iconSize: widget.iconSize,
          controlador: _controller);
    }));
  }
}
