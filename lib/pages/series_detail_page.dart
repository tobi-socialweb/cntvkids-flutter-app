import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/main.dart';
import 'package:cntvkids_app/models/series_model.dart';
import 'package:cntvkids_app/r.g.dart';
import 'package:flutter/material.dart';

class SeriesDetail extends StatefulWidget {
  final Series series;
  final String heroId;
  final ImageProvider imgProvider;

  const SeriesDetail({Key key, this.imgProvider, this.series, this.heroId})
      : super(key: key);

  _SeriesDetailState createState() => _SeriesDetailState();
}

class _SeriesDetailState extends State<SeriesDetail> {
  @override
  void initState() {
    super.initState();
  }

  String clean(String text) {
    RegExp re = RegExp(
      r"<[^>]*>",
      multiLine: true,
      caseSensitive: true,
    );

    return text.replaceAll(re, '');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final double topBarHeight = NAV_BAR_PERCENTAGE * size.height;

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// The colored curved blob in the background (white, yellow, etc.).

            /// Top Navigation Bar.
            Container(
                constraints: BoxConstraints(
                    maxHeight: topBarHeight, maxWidth: size.width),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      child: SvgIcon(
                        asset: R.svg.back_icon,
                        size: 0.5 * topBarHeight,
                      ),
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Hero(
                        tag: widget.heroId,
                        child: CircleAvatar(
                          /// diameter: 0.75 * topBarHeight
                          radius: 0.375 * topBarHeight,
                          backgroundImage: widget.imgProvider,
                        )),
                    Column(
                      children: [
                        Text(widget.series.title),
                        Text(
                          clean(widget.series.description),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        )
                      ],
                    )
                  ],
                )),

            /// Video & Game Cards' List.
            Expanded(
              child: Center(
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.cyan)),
                ),
              ),
            ),

            /// Space filler to keep things kinda centered.
            Container(
              width: size.width,
              height: topBarHeight,
            ),
          ],
        ));
  }
}
