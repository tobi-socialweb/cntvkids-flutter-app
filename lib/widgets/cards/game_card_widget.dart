import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/common/helpers.dart';
import 'package:cntvkids_app/common/cards/clickable_card.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/pages/game_display_page.dart';
import 'package:cntvkids_app/widgets/background_music.dart';

/// Card widget used to display a clickable game.
class GameCard extends StatefulWidget {
  final Game game;
  final String heroId;

  const GameCard({Key key, this.game, this.heroId}) : super(key: key);

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends ClickableCardState<GameCard> {
  @override
  String get badge => SvgAsset.games_badge;

  @override
  String get cardText => widget.game.title;

  @override
  String get heroId => widget.heroId;

  @override
  void onTap() {
    BackgroundMusicManager.instance.music.stopMusic();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewPage(url: widget.game.gameUrl)));
  }

  @override
  String get thumbnailUrl => widget.game.thumbnailUrl;

  @override
  bool get hasTextDecoration => true;
}
