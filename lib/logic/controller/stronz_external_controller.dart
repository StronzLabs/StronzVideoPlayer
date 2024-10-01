import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';

enum StronzExternalControllerEvent {
    play,
    pause,
    seekTo
}

abstract class StronzExternalController {

    Future<void> initialize(Playable playable, Future<void> Function(StronzExternalControllerEvent event, {dynamic arg}) handler);
    Future<void> dispose();

    Future<void> informState(StronzControllerState state);
    Future<void> onEvent(StronzExternalControllerEvent event, {dynamic arg});
    Future<void> switchTo(Playable playable);
}
