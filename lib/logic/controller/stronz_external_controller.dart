import 'package:flutter/material.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';
import 'package:stronz_video_player/logic/media_session.dart';

enum StronzExternalControllerEvent {
    play,
    pause
}

abstract class StronzExternalController {

    late void Function(StronzExternalControllerEvent) handler;

    @mustCallSuper
    Future<void> initialize(void Function(StronzExternalControllerEvent) handler) async {
        this.handler = handler;
    }

    @mustCallSuper
    Future<void> dispose() async {
        await this.stop();
    }

    Future<void> start(Playable playable);
    Future<void> stop();
    Future<void> informState(StronzControllerState state);
    Future<void> switchTo(Playable playable);
}

class MediaSessionExternalController extends StronzExternalController {
    
    @override
    Future<void> start(playable) async {
        await MediaSession.start(playable.title, playable.thumbnail, (event) => switch (event) {
            MediaSessionEvent.play => super.handler(StronzExternalControllerEvent.play),
            MediaSessionEvent.pause => super.handler(StronzExternalControllerEvent.pause),
        });
    }

    @override
    Future<void> stop() async {
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
