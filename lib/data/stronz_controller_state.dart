import 'package:stronz_video_player/data/player_preferences.dart';

class StronzControllerState {
    final bool? playing;
    final Duration? position;
    final double? volume;
    final int? videoTrack;
    final String? audioTrack;
    final String? captionTrack;

    StronzControllerState({
        this.playing,
        this.position,
        double? volume,
        int? videoTrack,
        String? audioTrack,
        String? captionTrack
    }) : this.volume = volume ?? PlayerPreferences.volume,
        this.videoTrack = videoTrack ?? PlayerPreferences.videoTrack,
        this.audioTrack = audioTrack ?? PlayerPreferences.audioTrack,
        this.captionTrack = captionTrack ?? PlayerPreferences.captionTrack;

    StronzControllerState.autoPlay({
        Duration? position,
        double? volume,
        int? videoTrack,
        String? audioTrack,
        String? captionTrack
    }) : this(
        playing: true,
        position: position,
        volume: volume,
        videoTrack: videoTrack,
        audioTrack: audioTrack,
        captionTrack: captionTrack
    );

    StronzControllerState copyWith({
        bool? playing,
        Duration? position,
        double? volume,
        int? videoTrack,
        String? audioTrack,
        String? captionTrack
    }) {
        return StronzControllerState(
            playing: playing ?? this.playing,
            position: position ?? this.position,
            volume: volume ?? this.volume,
            videoTrack: videoTrack ?? this.videoTrack,
            audioTrack: audioTrack ?? this.audioTrack,
            captionTrack: captionTrack ?? this.captionTrack
        );
    }
}
