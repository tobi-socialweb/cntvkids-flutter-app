import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'package:http/http.dart' as http;

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart'
    show BallSpinFadeLoaderIndicator;

import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/cards/card_list.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/widgets/cards/game_card_widget.dart';

/// Shows video widgets that have 'Games' category.
class GamesCardList extends StatefulWidget {
  @override
  _GamesCardListState createState() => _GamesCardListState();
}

class _GamesCardListState extends CardListState<GamesCardList> {
  @override
  Widget cardWidget(object, heroId) {
    return GameCard(
      game: object,
      heroId: heroId,
    );
  }

  @override
  String get modelUrl => GAMES_URL;

  @override
  int get categoryId => null;

  @override
  List dataToCardList(data) {
    return data.map((value) => Game.fromJson(value)).toList();
  }

  /// Remove GameCards that cannot be played by Android or iOS accordingly.
  @override
  Future<void> optionalCardManagement() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    int id = Platform.isAndroid ? ANDROID_GAMES_ID : IOS_GAMES_ID;

    for (int i = 0; i < cards.length; i++) {
      if (cards[i].categories.contains(id)) {
        cards[i].thumbnailUrl = await Game.fetchThumbnail(cards[i].mediaUrl);
      } else {
        cards.removeAt(i);
      }
    }
  }
}
