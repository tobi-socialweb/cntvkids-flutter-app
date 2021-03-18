import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cntvkids_app/common/constants.dart';

/// General plugins
import 'package:flutter/material.dart';

/// Audio plugins

import 'package:focus_detector/focus_detector.dart';

class Music {
  static AudioPlayer player = new AudioPlayer();
  static AudioCache cache = new AudioCache();
}

class MusicEffect {
  static AudioPlayer player = new AudioPlayer();
  static AudioCache cache = new AudioCache();

  /// Play effect sound.
  static Future<void> play(AssetResource asset) async {
    /// This assumes the asset's path falls under the `assets/` directory.
    /// Therefore, because `cache.play()` adds it manually, it should be
    /// removed first.
    String fileName = asset.name.replaceFirst(RegExp(r'assets/'), "");

    player =
        await cache.play(fileName, volume: BackgroundMusicManager.getVolume());
  }
}

/// Singleton.
class BackgroundMusicManager {
  final BackgroundMusic music = BackgroundMusic();

  BackgroundMusicManager._privateConstructor();
  static final BackgroundMusicManager instance =
      BackgroundMusicManager._privateConstructor();

  double volume = 0.5;

  static void setVolume(double volume) {
    BackgroundMusicManager.instance.volume = volume;
    BackgroundMusicManager.instance.music.changeVolume(volume);
  }

  static double getVolume() {
    return BackgroundMusicManager.instance.volume;
  }
}

class BackgroundMusic extends StatefulWidget {
  final Widget child;
  final double volume;

  const BackgroundMusic({Key key, this.child, this.volume}) : super(key: key);

  BackgroundMusicState createState() => BackgroundMusicState();

  /// Stop/play background music in agreement with de application state
  Future<void> loopMusic() async {
    Music.player = await Music.cache.loop('sounds/background/background_1.mp3',
        volume: BackgroundMusicManager.getVolume());
    print("DEBUG: loop music from home_page");
  }

  Future<void> stopMusic() async {
    Music.player?.stop();
    print("DEBUG: stop music from home_page");
  }

  Future<void> resumeMusic() async {
    Music.player?.resume();
    print("DEBUG: resume music from home_page");
  }

  Future<void> pauseMusic() async {
    Music.player?.pause();
    print("DEBUG: pause music from home_page");
  }

  Future<void> changeVolume(double value) async {
    Music.player?.setVolume(value);
    print("DEBUG: set volumen to $value");
  }
}

class BackgroundMusicState extends State<BackgroundMusic>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    BackgroundMusicManager.setVolume(widget.volume);

    super.initState();
  }

  // Change background sound in agreement of app state
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!this.mounted) return;

    /// When "closing" app, stop music.
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.detached ||
            state == AppLifecycleState.inactive) &&
        Music.player.state == AudioPlayerState.PLAYING) {
      BackgroundMusicManager.instance.music.pauseMusic();

      /// When reopening app.
    } else if (state == AppLifecycleState.resumed &&
        Music.player.state == AudioPlayerState.PAUSED) {
      BackgroundMusicManager.instance.music.resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onVisibilityGained: () {
        if (Music.player.state != AudioPlayerState.PLAYING) {
          Music.cache.clearCache();
          BackgroundMusicManager.instance.music.loopMusic();
        }
      },
      child: widget.child,
    );
  }

  // Dispose funtions
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
