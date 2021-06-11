import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/cards/video_card_widget.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCardList extends StatefulWidget {
  final double leftMargin;
  const FavoriteCardList({Key key, this.leftMargin = 0.0}) : super(key: key);

  @override
  _FavoriteCardListState createState() => _FavoriteCardListState();
}

class _FavoriteCardListState extends State<FavoriteCardList>
    with WidgetsBindingObserver {
  /// Currently shown cards.
  List<Widget> cards = [];

  List<Video> videos = [];

  /// Controller for the `ListView` scrolling.
  ScrollController controller;

  /// If user began scrolling.
  bool startedScrolling;
  @override
  void initState() {
    super.initState();
    startedScrolling = false;
    controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    controller.addListener(_scrollControllerListener);
  }

  initFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> videoList = prefs.getStringList(HISTORY_VIDEOS_KEY);

    if (videoList != null) {
      for (int i = 0; i < videoList.length; i++) {
        videos.add(Video.fromJson(videoList[i]));
      }
    }

    if (videos != null) {
      print("DEBUG: videos guardados ${videos.length}");

      /// Check if accessibility option for sign language is on.
      final bool isUsingSignLang =
          Provider.of<AppStateConfig>(context, listen: false).isUsingSignLang;

      /// Itererate through all new cards.
      for (int i = videos.length - 1; i >= 0; i--) {
        if (isUsingSignLang) {
          /// Set value as true by default.
          videos[i].useSignLang = true;

          /// Remove if video does not have sign language available.
          if (videos[i].signLangVideoUrl == "") videos.removeAt(i++);

          if (i > 0) {
            videos[i].prev = videos[i - 1];
            videos[i - 1].next = videos[i];
          }
        }

        setState(() {
          cards.add(VideoCard(video: videos[i]));
        });
      }
    }
  }

  /// Listener for scroll changes.
  _scrollControllerListener() {
    if (!this.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // ignore: invalid_use_of_protected_member
      if (controller.positions.length > 0 &&
          controller.position.isScrollingNotifier.value &&
          !startedScrolling) {
        Audio.play(MediaAsset.mp3.beam);
        startedScrolling = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cards.length == 0) {
      initFavoriteVideos();
    }
    print("Debug: cartas guardadas");
    print(cards.length);
    return NotificationListener(
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          /// If scroll controller cant get dimensions, it means
          /// that the loading element is visible and should load
          /// more pages.
          if (index == 0) {
            return Padding(
                padding: EdgeInsets.only(left: widget.leftMargin),
                child: cards[0]);
          } else {
            return cards[index];
          }
        },
      ),
      // ignore: missing_return
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          setState(() {
            startedScrolling = false;
          });
        }
      },
    );
  }
}
