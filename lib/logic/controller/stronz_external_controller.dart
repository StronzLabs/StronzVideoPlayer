import 'package:flutter/material.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';

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
