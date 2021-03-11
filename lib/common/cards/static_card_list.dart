import 'package:cntvkids_app/widgets/config_widget.dart';
import 'package:flutter/material.dart';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/pages/menu/home_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';

abstract class StaticCardListState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  /// Controller for the `ListView` scrolling.
  ScrollController controller;

  /// If user began scrolling.
  bool startedScrolling;

  /// All cards to show.
  List<dynamic> get cards;

  List<Widget> videos = [];

  /// Returns the specific card widget corresponding to each model (with object).
  Widget cardWidget(dynamic object, String heroId);

  /// The color in which to paint the background blob.
  Color get blobColor;

  /// The card list's avatar image provider.
  ImageProvider get avatarImgProvider;

  /// The card list's avatar heroId.
  String get avatarHeroId;

  /// The card list's title.
  String get title;

  /// The card list's description.
  String get description;

  /// Determined on initState of card list has description.
  bool hasDescription;

  ColorFilter colorFilter;
  VisualFilter currentVisualFilter;

  bool hasSetFilter = false;

  void setPlayerEffects();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < cards.length; i++) {
      videos.add(cardWidget(cards[i], cards[i].id.toString()));
    }
    controller = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
    controller.addListener(_scrollControllerListener);

    hasDescription = description != null && description != "";

    WidgetsBinding.instance.addObserver(this);

    setPlayerEffects();
    startedScrolling = false;
  }

  /// Play sounds.
  Future<AudioPlayer> playSound(String soundName) async {
    AudioCache cache = new AudioCache();
    var bytes = await (await cache.load(soundName)).readAsBytes();
    return cache.playBytes(bytes,
        volume: BackgroundMusicManager.instance.volume);
  }

  /// Listener for scroll changes.
  ///
  /// Loads the next page (per page) for cards videos if the scroll is
  /// finished.
  _scrollControllerListener() {
    if (!this.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // ignore: invalid_use_of_protected_member
      if (controller.positions.length > 0 &&
          controller.position.isScrollingNotifier.value &&
          !startedScrolling) {
        playSound("sounds/beam/beam.mp3");
        startedScrolling = true;
      }
    });
  }

  /// Remove badly formatted HTML tags from string [text].
  String clean(String text) {
    text = text.replaceAll(
        new RegExp(r"&hellip;", multiLine: true, caseSensitive: true), "...");

    return text.replaceAll(
        new RegExp(
          r"<[^>]*>",
          multiLine: true,
          caseSensitive: true,
        ),
        '');
  }

  void updateVisualFilter(bool value, VisualFilter filter) {
    if (!this.mounted) return;

    switch (filter) {
      case VisualFilter.grayscale:
        setState(() {
          colorFilter = value ? GRAYSCALE_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.grayscale : VisualFilter.normal;
        });
        break;

      case VisualFilter.inverted:
        setState(() {
          colorFilter = value ? INVERTED_FILTER : NORMAL_FILTER;
          currentVisualFilter =
              value ? VisualFilter.inverted : VisualFilter.normal;
        });
        break;

      /// normal
      default:
        setState(() {
          colorFilter = NORMAL_FILTER;
          currentVisualFilter = VisualFilter.normal;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double topBarHeight = NAVBAR_HEIGHT_PROP * size.height;

    if (!hasSetFilter) {
      hasSetFilter = true;

      currentVisualFilter = Config.of(context).configSettings.filter;

      switch (currentVisualFilter) {
        case VisualFilter.grayscale:
          colorFilter = GRAYSCALE_FILTER;
          break;

        case VisualFilter.inverted:
          colorFilter = INVERTED_FILTER;
          break;

        default:
          colorFilter = NORMAL_FILTER;
      }
    }

    return BackgroundMusic(
        child: ColorFiltered(
      colorFilter: colorFilter,
      child: WillPopScope(
        child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// The colored curved blob in the background (white, yellow, etc.).
                CustomPaint(
                  painter:
                      BottomColoredBlobPainter(color: Colors.cyan, size: size),
                ),

                /// Top Bar.
                Container(
                    constraints: BoxConstraints(
                        maxHeight: topBarHeight, maxWidth: size.width),
                    height: topBarHeight,
                    width: size.width,
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        /// Back button.
                        SvgButton(
                          asset: SvgAsset.back_icon,
                          size: 0.5 * topBarHeight,
                          onPressed: () {
                            playSound("sounds/go_back/go_back.mp3");
                            Navigator.of(context).pop();
                          },
                        ),

                        /// Series thumbnail avatar.
                        Container(
                          margin: EdgeInsets.only(right: 0.15 * topBarHeight),
                          child: Hero(
                              tag: avatarHeroId,
                              child: CircleAvatar(
                                /// diameter: 0.75 * topBarHeight
                                radius: 0.375 * topBarHeight,
                                backgroundImage: avatarImgProvider,
                              )),
                        ),

                        /// Series title & description.
                        Container(
                            margin: EdgeInsets.only(top: 0.05 * topBarHeight),
                            width: 0.8 * size.width - 1.375 * topBarHeight,
                            child: Column(
                              mainAxisAlignment: hasDescription
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              crossAxisAlignment: hasDescription
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                              children: [
                                /// Title
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: hasDescription
                                        ? 0.15 * topBarHeight
                                        : 0.2 * topBarHeight,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: "FredokaOne",
                                    height: 1.0,
                                  ),
                                ),

                                /// Description
                                if (hasDescription)
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 0.05 * topBarHeight),
                                    height: 0.6 * topBarHeight,
                                    child: ListView(
                                      primary: false,
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      children: [
                                        Text(
                                          clean(description),
                                          style: TextStyle(
                                            fontSize: 0.125 * topBarHeight,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            )),
                      ],
                    )),

                /// The card list.
                Expanded(
                  child: NotificationListener(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      controller: controller,
                      children: videos,
                    ),
                    // ignore: missing_return
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification) {
                        setState(() {
                          startedScrolling = false;
                        });
                      }
                    },
                  ),
                ),

                /// Space filler to keep things kinda centered.
                Container(
                  width: size.width,
                  height: topBarHeight / 2,
                ),
              ],
            )),
        onWillPop: () {
          playSound("sounds/go_back/go_back.mp3");
          return Future<bool>.value(true);
        },
      ),
    ));
  }
}
