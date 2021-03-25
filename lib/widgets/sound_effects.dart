import 'package:audioplayers/audio_cache.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'background_music.dart';

class SoundEffect {
  AudioCache _audioCache;
  double _vol;

  SoundEffect() {
    _audioCache = AudioCache(prefix: "");
  }

  /// play sound asset adquired.
  play(AssetResource asset) async {
    _vol = BackgroundMusicManager.getVolume();
    print("Debug from sound effect: volumen $_vol");
    print("Debug from sound effect: play sound ${asset.name}");
    var bytes = await (await _audioCache.load(asset.name)).readAsBytes();
    _audioCache.playBytes(bytes, volume: _vol);
  }
}
