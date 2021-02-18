import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:r_dart_library/asset_svg.dart';

import 'package:cntvkids_app/common/helpers.dart';

abstract class ClickableCardState<T extends StatefulWidget> extends State<T> {
  /// The available space
  Size get size;

  /// The card's margins.
  EdgeInsets get margin;

  /// Getter for the thumbnail URL to be loaded.
  String get thumbnailUrl;

  /// The height percentage the image will take, considering 1.0 to be the space
  /// available between the nav bar and the bottom.
  double get heightFactor;

  /// The void function to be called when tapping on the card.
  void onTap();

  /// The icon that will show on top of the thumbnail.
  AssetSvg Function({double width, double height}) get badge;

  /// Used to fetch the thumbnail and wait for it to load.
  CachedNetworkImageProvider imgProvider;
  Completer completer = new Completer();

  /// How far to move the icon diagonally from the bottom right.
  final double diagonalIconDstFactor = 0.3;

  /*/// The video card's height.
  double height;

  /// The video card's width.
  double width;

  /// The video card icon/badge's size.
  double iconSize;*/

  /// Gets called after finishing loading the thumbnail image and it's placed
  /// below it.
  Widget afterThumbnailWidget();

  @override
  void initState() {
    /// Set the URL and add a listener to complete the future.
    imgProvider = new CachedNetworkImageProvider(thumbnailUrl);
    imgProvider.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));

    /*height = size.height * heightFactor;
    width = height * 16 / 9;
    iconSize = 0.45 * height;*/

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
        margin: margin,
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
                        /// Video card thumbnail.
                        Image(
                          image: imgProvider,
                          height: height,
                          width: width,
                          fit: BoxFit.cover,
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
                  afterThumbnailWidget(),
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
