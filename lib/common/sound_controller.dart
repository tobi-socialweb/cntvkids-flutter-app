import 'package:async/async.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cntvkids_app/common/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';

import 'constants.dart';

/// Internal class used to wrap over both `AudioCache`
/// and `AudioPlayer` from `audioplayers` plugin.
class _Player {
  AudioCache cache;
  AudioPlayer player;
  double _volume;

  /// Constructor
  _Player() {
    player = AudioPlayer();
    cache = AudioCache(prefix: "", fixedPlayer: player, duckAudio: true);
    _volume = 1.0;
  }

  double get volume {
    return _volume;
  }

  set volume(double value) {
    _volume = value;
    player.setVolume(value);
  }

  /// Get the current state from the player
  AudioPlayerState get state {
    return player.state;
  }

  void dispose() {
    player.dispose();
  }
}

/// The main wrapper class (singleton) that manages the `AudioCache`
/// class from the `audioplayers` plugin. Position (index) 0 is reserved
/// for the background music.
///
/// The plugin allows only one audio source to be played per
/// instance, so this class will create instances as needed.
class Audio {
  static const reserved = 1;
  static const numPlayers = MAX_AUDIO_INSTANCES + reserved;

  /// List of audio cache players initialized as null first
  final List<_Player> players = List<_Player>.filled(numPlayers, null);

  /// Singleton instance
  static final Audio _instance = Audio._internal();

  /// Factory method ensuring to return the instance
  factory Audio() {
    return _instance;
  }

  /// Private class constructor, initializes each player
  Audio._internal() {
    for (int i = 0; i < numPlayers; i++) {
      players[i] = _Player();
    }
  }

  /// Use `play` method from `AudioCache` at `index` (overriding
  /// the current state of said player). If no `index`
  /// is given, then the index assigned is returned.
  ///
  /// The index assigned is returned, and if the value is `-1`,
  /// it means that there was no available player (all players were
  /// either in the state of `PLAYING` or `PAUSED`).
  static int play(AssetResource asset, {double volume = 1.0, int index = -1}) {
    Audio instance = Audio();

    if (index >= 0) {
      instance.players[index].cache.play(asset.name);
      instance.players[index].volume = volume;

      return index;
    } else {
      for (int i = reserved; i < numPlayers; i++) {
        if (instance.players[i].state != AudioPlayerState.PLAYING &&
            instance.players[i].state != AudioPlayerState.PAUSED) {
          instance.players[i].cache.play(asset.name);
          instance.players[i].volume = volume;

          return i;
        }
      }
    }

    print(
        "DEBUG: Could not use 'play' in Audio, because all spaces were used (all states: ${Audio.state().toString()}).");
    return -1;
  }

  /// Stop the player at `index` if given, else stop all players
  /// at once.
  static void stop({int index = -1}) {
    if (index >= 0) {
      Audio().players[index].player.stop();
    } else {
      Audio instance = Audio();

      for (int i = reserved; i < numPlayers; i++) {
        instance.players[i].player.stop();
      }
    }
  }

  /// Use `loop` method from `AudioCache` at `index` (overriding
  /// the current state of said player). If no `index`
  /// is given, then the index assigned is returned.
  ///
  /// The index assigned is returned, and if the value is `-1`,
  /// it means that there was no available player (all players were
  /// either in the state of `PLAYING` or `PAUSED`).
  static int loop(AssetResource asset, {double volume = 1.0, int index = -1}) {
    Audio instance = Audio();

    if (index >= 0) {
      instance.players[index].cache.loop(asset.name);
      instance.players[index].volume = volume;

      return index;
    } else {
      for (int i = reserved; i < numPlayers; i++) {
        if (instance.players[i].state != AudioPlayerState.PLAYING &&
            instance.players[i].state != AudioPlayerState.PAUSED) {
          instance.players[i].cache.loop(asset.name);
          instance.players[i].volume = volume;

          return i;
        }
      }
    }

    print(
        "DEBUG: Could not use 'loop' in Audio, because all spaces were used (all states: ${Audio.state().toString()})");
    return -1;
  }

  /// Pause the player at `index` if given, else pause all players
  /// at once.
  static void pause({int index = -1}) {
    if (index >= 0) {
      Audio().players[index].player.pause();
    } else {
      Audio instance = Audio();

      for (int i = reserved; i < numPlayers; i++) {
        instance.players[i].player.pause();
      }
    }
  }

  /// Resume the player at `index` if given, else resume all players
  /// at once.
  static void resume({int index = -1}) {
    if (index >= 0) {
      Audio().players[index].player.resume();
    } else {
      Audio instance = Audio();

      for (int i = reserved; i < numPlayers; i++) {
        instance.players[i].player.resume();
      }
    }
  }

  /// Use `setVolume` method from `AudioPlayer`, to player at
  /// `index`. If no `index` is given, then set to all players.
  static void setVolume({@required double volume, int index = -1}) {
    if (index >= 0) {
      Audio().players[index].volume = volume;
    } else {
      Audio instance = Audio();

      for (int i = reserved; i < numPlayers; i++) {
        instance.players[i].volume = volume;
      }
    }
  }

  /// Return the current volume of player ar `index`
  static double getVolume({@required int index}) {
    return Audio().players[index].volume;
  }

  /// Return the current state of player at `index`, or a list
  /// of all of the available players if no `index` is given.
  static dynamic state({int index = -1}) {
    if (index >= 0) {
      return Audio().players[index].state;
    } else {
      List<AudioPlayerState> allPlayerStates =
          List<AudioPlayerState>.filled(numPlayers, null);
      Audio instance = Audio();

      for (int i = 0; i < numPlayers; i++) {
        if (instance.players[i] != null)
          allPlayerStates[i] = instance.players[i].state;
      }

      return allPlayerStates;
    }
  }

  /// Clear the saved cache of `asset` (nothing happens if
  /// the asset was not previously cached). If not asset is given,
  /// then clear cache of all assets.
  static void clear({AssetResource asset}) {
    if (asset == null)
      Audio().players[0].cache.clear(asset.name);
    else
      Audio().players[0].cache.clearCache();
  }
}

/// Manager for the background music in cache with index 0
class BackgroundMusicManager extends StatefulWidget {
  final Widget child;
  final double volume;

  const BackgroundMusicManager({Key key, this.child, this.volume})
      : assert(volume <= 1.0 && volume >= 0.0),
        super(key: key);

  _BackgroundMusicManagerState createState() => _BackgroundMusicManagerState();

  static double getVolume() {
    return Audio.getVolume(index: 0);
  }

  static void setVolume(double value) {
    Audio.setVolume(volume: value, index: 0);
  }

  /// Uses `loop` instead of `play` for the background music.
  static void play() {
    Audio.loop(MediaAsset.mp3.background_1, volume: getVolume());
  }

  static void stop() {
    Audio.stop(index: 0);
  }

  static void pause() {
    Audio.pause(index: 0);
  }

  static void resume() {
    Audio.resume(index: 0);
  }
}

class _BackgroundMusicManagerState extends State<BackgroundMusicManager>
    with WidgetsBindingObserver {
  AudioPlayerState state;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    state = Audio.state(index: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onVisibilityGained: () {
        state = Audio.state(index: 0);
        print(
            "DEBUG: Background music gained visibility, player state is $state");

        if (state == AudioPlayerState.STOPPED || state == null) {
          Audio.clear(asset: MediaAsset.mp3.background_1);
          Audio.loop(MediaAsset.mp3.background_1);
        }
      },
      child: widget.child,
    );
  }

  /// Make sure to change the state of the background music when
  /// phone loses focus.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this.mounted) return;

    AudioPlayerState bgMusicState = Audio.state(index: 0);

    /// When the app is "closed", then stop or pause the music
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached ||
            state == AppLifecycleState.inactive) &&
        bgMusicState == AudioPlayerState.PLAYING) {
      Audio.pause(index: 0);

      ///When reopening app, resume the background music
    } else if (state == AppLifecycleState.resumed &&
        bgMusicState == AudioPlayerState.PAUSED) {
      Audio.resume(index: 0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
}
