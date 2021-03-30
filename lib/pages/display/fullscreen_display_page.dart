import 'dart:async';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:cntvkids_app/widgets/video_display_controller_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'package:cntvkids_app/models/video_model.dart';
import 'package:provider/provider.dart';

/// Shows video fullscreen
class FullScreenVideoDisplay extends StatefulWidget {
  final Video video;
  final Future<dynamic> player;
  FullScreenVideoDisplay({this.video, this.player});

  @override
  _FullScreenVideoDisplayState createState() => _FullScreenVideoDisplayState();
}

class _FullScreenVideoDisplayState extends State<FullScreenVideoDisplay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DisplayNotifier>().toggleDisplay();
      },
      child: WillPopScope(
        onWillPop: () {
          SoundEffect().play(MediaAsset.mp3.go_back);
          return Future<bool>.value(false);
        },
        child: FutureBuilder(
            future: widget.player,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Hero(
                      tag: widget.video.id,
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
      ),
    );
  }
}
