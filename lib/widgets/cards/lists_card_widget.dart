import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/models/lists_model.dart';
import 'package:cntvkids_app/pages/menu/lists_detail_page.dart';
import 'package:flutter/material.dart';

class ListsCard extends StatefulWidget {
  final Lists lists;
  final String heroId;

  const ListsCard({Key key, this.lists, this.heroId}) : super(key: key);

  @override
  _ListsCardState createState() => _ListsCardState();
}

class _ListsCardState extends State<ListsCard> {
  /// Used to fetch the thumbnail and wait for it to load.
  CachedNetworkImageProvider imgProvider;
  Completer completer = new Completer();

  Image thumbnail;

  /// How far to move the icon diagonally from the bottom right.
  final double diagonalIconDstFactor = 0.3;

  @override
  void initState() {
    /// Set the URL and add a listener to complete the future.
    imgProvider = new CachedNetworkImageProvider(widget.lists.thumbnailUrl);
    imgProvider.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final double height =
        0.7 * (size.height * (1 - 3 * NAVBAR_HEIGHT_PROP / 2));
    final double width = height * 16 / 9;
    final double iconSize = 0.45 * height;

    return Card(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        borderOnForeground: false,
        margin: EdgeInsets.symmetric(horizontal: 0.025 * size.width),
        child: FutureBuilder(
          future: completer.future,
          builder: (context, snapshot) {
            /// If image was loaded.
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(0.15 * height),
                    child: Stack(
                      children: [
                        /// Series card thumbnail.
                        Hero(
                          tag: widget.heroId,
                          child: Image(
                            image: imgProvider,
                            height: height,
                            width: width,
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// Play icon on top of the thumbnail.
                        Positioned(
                            right:
                                height * diagonalIconDstFactor - iconSize / 2,
                            bottom:
                                height * diagonalIconDstFactor - iconSize / 2,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                SvgIcon(
                                  asset: SvgAsset.lists_badge,
                                  size: iconSize,
                                ),
                              ],
                            )),

                        /// Full screen video "on demand".
                        Positioned.fill(
                            child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ListsCardDetail(
                                    lists: widget.lists,
                                    heroId: widget.heroId,
                                    imgProvider: imgProvider);
                              }));
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                  Container(
                      width: width,
                      child: Text(
                        widget.lists.title,
                        textAlign: TextAlign.left,
                        softWrap: true,
                        textScaleFactor: 0.006 * height,
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              );

              /// If there is an error while loading the image.
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "No se pudo cargar la imagen.",
                  style: TextStyle(
                      backgroundColor: Colors.black54, color: Colors.white),
                ),
              );
            } else {
              return Container();
            }
          },
        ));
  }
}
