import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/constants.dart';

abstract class ClickableCardState<T extends StatefulWidget> extends State<T> {
  /// The available space
  Size get size => Size(MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * (1 - 3 * NAVBAR_HEIGHT_PROP / 2));

  /// The card's margins.
  EdgeInsets get margin => EdgeInsets.symmetric(horizontal: 0.025 * size.width);

  /// Getter for the thumbnail URL to be loaded.
  String get thumbnailUrl;

  /// Getter for the hero ID.
  String get heroId;

  /// The height percentage the image will take, considering 1.0 to be the space
  /// available between the nav bar and the bottom.
  double get heightFactor => 0.675;

  /// The void function to be called when tapping on the card.
  void onTap();

  /// The icon that will show on top of the thumbnail.
  String get badge;

  /// Used to fetch the thumbnail and wait for it to load.
  CachedNetworkImageProvider imgProvider;
  Completer completer = new Completer();

  /// How far to move the icon diagonally from the bottom right.
  final double diagonalIconDstFactor = 0.3;

  /// Shown after finishing loading the thumbnail image and it's placed
  /// below it.
  String get cardText;

  bool get hasTextDecoration => false;

  @override
  void initState() {
    /// Set the URL and add a listener to complete the future.
    imgProvider = new CachedNetworkImageProvider(thumbnailUrl);
    imgProvider.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double height = size.height * heightFactor;
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
                          tag: heroId,
                          child: Image(
                            image: imgProvider,
                            height: height,
                            width: width,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.medium,
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
                                  asset: badge,
                                  size: iconSize,
                                ),
                              ],
                            )),

                        /// Full screen video "on demand".
                        Positioned.fill(
                            child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap,
                          ),
                        )),
                      ],
                    ),
                  ),
                  if (cardText != null && cardText != "")
                    Container(
                        width: hasTextDecoration ? 0.95 * width : width,
                        decoration: hasTextDecoration
                            ? BoxDecoration(
                                color: Colors.purple[900],
                                borderRadius:
                                    BorderRadius.circular(0.1 * height),
                              )
                            : null,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: hasTextDecoration
                                  ? 0.05 * width
                                  : 0.025 * width,
                              vertical: 0.025 * height),
                          child: Text(
                            cardText,
                            textAlign: TextAlign.left,
                            softWrap: true,
                            textScaleFactor: 0.005 * size.height * heightFactor,
                            style: TextStyle(
                                color: hasTextDecoration
                                    ? Colors.white
                                    : Colors.black),
                          ),
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
