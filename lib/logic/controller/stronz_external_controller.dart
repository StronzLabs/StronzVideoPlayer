import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';

enum StronzExternalControllerEvent {
    play,
    pause
}

abstract class StronzExternalController {

    Future<void> initialize(Playable playable, void Function(StronzExternalControllerEvent) handler);
    Future<void> dispose();

    Future<void> informState(StronzControllerState state);
    Future<void> switchTo(Playable playable);
}
