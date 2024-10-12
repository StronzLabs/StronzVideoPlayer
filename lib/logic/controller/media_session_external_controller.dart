import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';
import 'package:stronz_video_player/logic/controller/stronz_external_controller.dart';
import 'package:stronz_video_player/logic/media_session.dart';

class MediaSessionExternalController extends StronzExternalController {
    
    @override
    Future<void> initialize(Playable playable, void Function(StronzExternalControllerEvent event, {dynamic arg}) handler) async {
        await MediaSession.start(playable.title, playable.thumbnail, (event) => switch (event) {
            MediaSessionEvent.play => handler(StronzExternalControllerEvent.play),
            MediaSessionEvent.pause => handler(StronzExternalControllerEvent.pause),
        });
    }

    @override
    Future<void> dispose() async {
        await MediaSession.stop();
    }

    @override
    Future<void> informState(StronzControllerState state) async {
        if (state.playing == true)
            await MediaSession.informPlaying();
        else if (state.playing == false)
            await MediaSession.informPaused();
    }

    @override
    Future<void> switchTo(Playable playable) {
        return MediaSession.switchTo(playable.title, playable.thumbnail);
    }
    
}
