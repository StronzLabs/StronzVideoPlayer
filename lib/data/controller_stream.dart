import 'package:stronz_video_player/data/tracks.dart';
import 'package:video_player/video_player.dart';

class ControllerStream {
    final Stream<bool> buffering;
    final Stream<double> aspectRatio;
    final Stream<bool> playing;
    final Stream<Duration> position;
    final Stream<double> volume;
    final Stream<Duration> duration;
    final Stream<bool> completed;
    final Stream<VideoTrack?> videoTrack;
    final Stream<AudioTrack?> audioTrack;
    final Stream<CaptionTrack?> captionTrack;
    final Stream<List<DurationRange>> buffered;
    final Stream<String> title;

    const ControllerStream({
        required this.buffering,
        required this.aspectRatio,
        required this.playing,
        required this.position,
        required this.volume,
        required this.duration,
        required this.completed,
        required this.videoTrack,
        required this.audioTrack,
        required this.captionTrack,
        required this.buffered,
        required this.title
    });
}
