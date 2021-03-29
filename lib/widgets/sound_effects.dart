import 'package:audioplayers/audio_cache.dart';
import 'package:cntvkids_app/common/constants.dart';

import 'background_music.dart';

class SoundEffect {
  AudioCache _audioCache;
  double _vol;

  SoundEffect() {
    _audioCache = AudioCache(prefix: "");
  }

  /// Play the sound asset.
  play(AssetResource asset) async {
    _vol = BackgroundMusicManager.getVolume();
    var bytes = await (await _audioCache.load(asset.name)).readAsBytes();
    _audioCache.playBytes(bytes, volume: _vol);
  }
}
