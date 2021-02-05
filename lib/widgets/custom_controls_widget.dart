import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:cntvkids_app/widgets/video_display_widget.dart';

class CustomPlayerControls extends StatefulWidget {
  final BetterPlayerController controller;

  const CustomPlayerControls({
    Key key,
    this.controller,
  }) : super(key: key);

  @override
  _CustomPlayerControlsState createState() => _CustomPlayerControlsState();
}

class _CustomPlayerControlsState extends State<CustomPlayerControls> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: WillPopScope(child: GestureDetector(
      onTap: () {
        print("DEBUG: tapped");
      },
    ), onWillPop: () {
      print("DEBUG: popped");
      Navigator.pop(InheritedVideoDisplay.of(context).context);
      return Future<bool>.value(false);
    }));
  }
}
