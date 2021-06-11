import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/cards/video_card_widget.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryCardList extends StatefulWidget {
  final double leftMargin;
  const HistoryCardList({Key key, this.leftMargin = 0.0}) : super(key: key);

  @override
  _HistoryCardListState createState() => _HistoryCardListState();
}

class _HistoryCardListState extends State<HistoryCardList>
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

  initVideoCards() {
    List<String> videoList = StorageManager.videoHistory;

    if (videoList != null) {
      for (int i = 0; i < videoList.length; i++) {
        videos.add(Video.fromJson(videoList[i]));
      }
    }

    if (videos != null) {
      /*/// If the current card is the first in the list.
      if (i == 0 && cards.length > 0) {
        /// Assign first card in [newCards] as the `next` for the last one
        /// in [cards].
        cards[cards.length - 1].next = newCards[i];

        /// Otherwise any other card.
      } else if (i > 0) {
        newCards[i].prev = newCards[i - 1];
        newCards[i - 1].next = newCards[i];
      }
    }*/

      print("Debug: videos guardados");
      print(videos.length);

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
    if (cards.length == 0) initVideoCards();

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
