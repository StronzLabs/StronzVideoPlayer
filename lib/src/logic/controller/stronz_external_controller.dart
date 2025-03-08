import 'package:stronz_video_player/src/data/playable.dart';
import 'package:stronz_video_player/src/data/stronz_controller_state.dart';

enum StronzExternalControllerEvent {
    play,
    pause,
    seekTo
}

abstract class StronzExternalController {

    Future<void> initialize(Playable playable, Future<void> Function(StronzExternalControllerEvent event, {dynamic arg}) handler);
    Future<void> dispose();

    Future<void> informState(StronzControllerState state);
    Future<bool> onEvent(StronzExternalControllerEvent event, {dynamic arg}) async => true;
    Future<void> switchTo(Playable playable);
}
