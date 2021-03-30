import 'package:cntvkids_app/common/constants.dart';
import 'package:cntvkids_app/common/sound_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cntvkids_app/cards/abstract_clickable_card.dart';
import 'package:cntvkids_app/models/games_model.dart';
import 'package:cntvkids_app/pages/display/game_display_page.dart';

/// Card widget used to display a clickable game.
class GameCard extends StatefulWidget {
  final Game game;
  final double heightFactor;

  const GameCard({Key key, this.game, this.heightFactor = 0.75})
      : super(key: key);

  @override
  _GameCardState createState() => _GameCardState();
}

class _GameCardState extends ClickableCardState<GameCard> {
  @override
  AssetResource get badge => SvgAsset.games_badge;

  @override
  String get cardText => widget.game.title;

  @override
  String get heroId => widget.game.id;

  SoundEffect _soundEffect;

  void initState() {
    _soundEffect = SoundEffect();

    super.initState();
  }

  @override
  void onTap() {
    _soundEffect.play(MediaAsset.mp3.click);
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

  @override
  double get heightFactor => widget.heightFactor;
}
