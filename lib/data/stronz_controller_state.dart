import 'package:stronz_video_player/data/player_preferences.dart';

class StronzControllerState {
    final bool? playing;
    final Duration? position;
    final double? volume;

    StronzControllerState({
        this.playing,
        this.position,
        double? volume
    }) : this.volume = volume ?? PlayerPreferences.volume;

    StronzControllerState.autoPlay({
        Duration? position,
        double? volume
    }) : this(
        playing: true,
        position: position,
        volume: volume
    );
}
