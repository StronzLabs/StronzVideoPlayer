library stronz_video_player;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/components/desktop_video_player_controls.dart';
import 'package:stronz_video_player/components/mobile_video_player_controls.dart';
import 'package:stronz_video_player/components/video_player_view.dart';
import 'package:stronz_video_player/logic/stronz_player_controller.dart';
import 'package:window_manager/window_manager.dart';

abstract class Playable {
    String get title;
    Future<Uri> get source;
    Playable? get next;

    const Playable();
}

class SimplePlayable extends Playable {
    @override
    final String title;
    @override
    Future<Uri> get source => Future.value(Uri.parse(this.url));
    @override
    Playable? get next => this;
    final String url;

    const SimplePlayable({
        required this.title,
        required this.url
    });
}

class StronzVideoPlayer extends StatefulWidget {
    final Playable playable;
    final List<Widget> Function(BuildContext)? additionalControlsBuilder;

    final void Function(StronzPlayerController)? onBeforeExit;
    
    const StronzVideoPlayer({
        super.key,
        required this.playable,
        this.additionalControlsBuilder,
        this.onBeforeExit
    });

    @override
    State<StronzVideoPlayer> createState() => _StronzVideoPlayerState();

    static Future<void> initialize() async {
        registerWith(options: {'platforms': ['windows', 'linux']});
        if(Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            await windowManager.ensureInitialized();
    }
}

class _StronzVideoPlayerState extends State<StronzVideoPlayer> {

    late final StronzPlayerController _playerController = StronzPlayerController(
        playable: super.widget.playable
    );

    @override
    void dispose() {
        this._playerController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return PopScope(
            onPopInvoked: (_) => super.widget.onBeforeExit?.call(this._playerController),
            child: Provider<StronzPlayerController>(
                create: (context) => this._playerController,
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                        const VideoPlayerView(),
                        Platform.isAndroid || Platform.isIOS
                            ? MobileVideoControls(
                                additionalControlsBuilder: super.widget.additionalControlsBuilder,
                            )
                            : DesktopVideoPlayerControls(
                                additionalControlsBuilder: super.widget.additionalControlsBuilder,
                            )
                    ]
                )
            )
        );
    }
}
