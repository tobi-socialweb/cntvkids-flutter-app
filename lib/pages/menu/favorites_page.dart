import 'package:cntvkids_app/models/video_model.dart';
import 'package:cntvkids_app/widgets/app_state_config.dart';
import 'package:cntvkids_app/widgets/cards/video_card_widget.dart';
import 'package:cntvkids_app/widgets/sound_effects.dart';
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

  SoundEffect _soundEffect;

  @override
  void initState() {
    super.initState();
    startedScrolling = false;
    controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    controller.addListener(_scrollControllerListener);
    _soundEffect = SoundEffect();
  }

  initFavoriteVideos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listIds = prefs.getStringList(FAVORITE_ID_KEY);
    List<String> listTitles = prefs.getStringList(FAVORITE_TITLES_KEY);
    List<String> listThumbnails = prefs.getStringList(FAVORITE_THUMBNAILS_KEY);
    List<String> listUrls = prefs.getStringList(FAVORITE_URLS_KEY);
    List<String> listSignUrls = prefs.getStringList(FAVORITE_SIGNURLS_KEY);

    print("Debug: titulos guardados");
    print(listTitles);
    if (listTitles != null) {
      for (int i = 0; i < listTitles.length; i++) {
        Video temp = Video(
          id: int.parse(listIds[i]),
          title: listTitles[i],
          thumbnailUrl: listThumbnails[i],
          videoUrl: listUrls[i],
          signLangVideoUrl: listSignUrls[i],
        );
        videos.add(temp);
      }
    }
    if (videos != null) {
      print("Debug: videos guardados");
      print(videos.length);
      for (int i = 0; i < videos.length; i++) {
        if (videos[i].signLangVideoUrl != "") {
          videos[i].useSignLang =
              Provider.of<AppStateConfig>(context, listen: false)
                  .isUsingSignLang;
        }
        setState(() {
          cards.add(
              VideoCard(video: videos[i], heroId: videos[i].id.toString()));
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
        _soundEffect.play(MediaAsset.mp3.beam);
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
