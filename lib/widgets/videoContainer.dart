import 'package:cntvkids_app/models/video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final String heroId;

  VideoCard({this.video, this.heroId});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Card(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.cyan, width: 2.0)),
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(video.thumbnailUrl),
                Positioned(
                    right: 0.05 * size.width,
                    left: 0,
                    height: 0.5 * size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        new Icon(
                          Icons.play_arrow_rounded,
                          size: 75,
                        )
                      ],
                    ))
              ],
            ),
            Text(video.title),
          ],
        ));
  }
}
