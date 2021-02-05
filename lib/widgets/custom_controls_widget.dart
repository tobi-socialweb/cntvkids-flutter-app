import 'package:better_player/better_player.dart';
import 'package:cntvkids_app/models/video_model.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/widgets/video_display_widget.dart';

/// Used to keep a reference of this context, for a later navigator pop.
class CustomPlayerControls extends StatefulWidget {
  final BetterPlayerController controller;
  final Video video;

  const CustomPlayerControls({Key key, this.controller, this.video})
      : super(key: key);

  @override
  _CustomPlayerControlsState createState() => _CustomPlayerControlsState();
}

class _CustomPlayerControlsState extends State<CustomPlayerControls> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: WillPopScope(child: GestureDetector(
      onTap: () {
        InheritedVideoDisplay.of(context).toggle();
        print("DEBUG: tapped");
      },
    ), onWillPop: () {
      print("DEBUG: popped");
      Navigator.pop(InheritedVideoDisplay.of(context).context);
      return Future<bool>.value(false);
    }));
  }
}
