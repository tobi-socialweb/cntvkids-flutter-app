import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/constants.dart';

abstract class ClickableCardState<T extends StatefulWidget> extends State<T> {
  /// The available space for the card.
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
  double get heightFactor;

  /// The void function to be called when tapping on the card.
  void onTap();

  /// The icon that will show on top of the thumbnail.
  String get badge;

  /// Used to fetch the thumbnail and wait for it to load.
  late CachedNetworkImageProvider imgProvider;
  Completer completer = new Completer();

  /// How far to move the icon diagonally from the bottom right.
  final double diagonalIconDstFactor = 0.3;

  /// Shown after finishing loading the thumbnail image and it's placed
  /// below it.
  String? get cardText;

  bool get hasTextDecoration => false;

  @override
  void initState() {
    /// Set the URL and add a listener to complete the future.
    imgProvider = new CachedNetworkImageProvider(thumbnailUrl);
    imgProvider.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((info, _) => completer.complete(info.image)));

    super.initState();
  }

  /// Play sounds efects.
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    /// The height of the card, considering the height factor.
    final double height = size.height * heightFactor;

    /// The width as poproportion of the height.
    final double width = height * 16 / 9;

    final double iconSize = 0.45 * height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            height: height,
            width: width,
            margin: margin,
            child: FittedBox(
              fit: BoxFit.contain,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.15 * height),
                  child: _CardElements(
                      width: width,
                      height: height,
                      heroId: heroId,
                      imgProvider: imgProvider,
                      diagonalPos:
                          height * diagonalIconDstFactor - iconSize / 2,
                      asset: badge,
                      iconSize: iconSize,
                      onTap: onTap)),
            )),

        /// If the card has text added, determine whether to show it with
        /// decoration or not
        if (cardText != null && cardText != '')
          if (hasTextDecoration)
            _CardTextWithDecoration(
                width: width, height: height, text: cardText!)
          else
            _CardText(width: width, height: height, text: cardText!)
      ],
    );
  }
}

/// The thumbnail, the badge, and other parts of the card.
class _CardElements extends StatelessWidget {
  final double width;
  final double height;
  final String heroId;
  final ImageProvider imgProvider;
  final double diagonalPos;
  final String asset;
  final double iconSize;
  final void Function() onTap;

  const _CardElements(
      {Key? key,
      required this.width,
      required this.height,
      required this.heroId,
      required this.imgProvider,
      required this.diagonalPos,
      required this.asset,
      required this.iconSize,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          color: Colors.white54,
        ),
        Hero(
          tag: heroId,
          child: Image(
            image: imgProvider,
            width: width,
            height: height,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
        Positioned(
          right: diagonalPos,
          bottom: diagonalPos,
          child: SvgIcon(
            asset: asset,
            size: iconSize,
          ),
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
          ),
        ))
      ],
    );
  }
}

/// Card text with decoration adds a rounded background behind the text.
class _CardTextWithDecoration extends StatelessWidget {
  final double width;
  final double height;
  final String text;

  const _CardTextWithDecoration(
      {Key? key, required this.width, required this.height, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.95 * width,
      decoration: BoxDecoration(
        color: Colors.purple[900],
        borderRadius: BorderRadius.circular(0.1 * height),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: 0.05 * width, vertical: 0.025 * height),
        child: Text(
          text,
          textAlign: TextAlign.left,
          softWrap: true,
          textScaleFactor: 0.006 * height,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Card text without decoration just shows text.
class _CardText extends StatelessWidget {
  final double width;
  final double height;
  final String text;

  const _CardText(
      {Key? key, required this.width, required this.height, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: 0.025 * width, vertical: 0.025 * height),
        child: Text(
          text,
          textAlign: TextAlign.left,
          softWrap: true,
          textScaleFactor: 0.006 * height,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
