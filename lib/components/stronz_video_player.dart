import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/components/adaptive_stronz_video_player_controls.dart';
import 'package:stronz_video_player/components/video_player_view.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/logic/stronz_player_controller.dart';
import 'package:window_manager/window_manager.dart';

class StronzVideoPlayer extends StatefulWidget {
    final Playable playable;
    final AdditionalStronzControlsBuilder? additionalControlsBuilder;
    final Widget Function(BuildContext)? controlsBuilder;

    final void Function(StronzPlayerController)? onBeforeExit;
    
    const StronzVideoPlayer({
        super.key,
        required this.playable,
        this.additionalControlsBuilder,
        this.controlsBuilder,
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
            onPopInvokedWithResult: (_, __) => super.widget.onBeforeExit?.call(this._playerController),
            child: Provider<StronzPlayerController>(
                create: (context) => this._playerController,
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                        const VideoPlayerView(),

                        super.widget.controlsBuilder?.call(context)
                        ?? AdaptiveStronzVideoPlayerControls(
                            additionalControlsBuilder: super.widget.additionalControlsBuilder,
                        )
                    ]
                )
            )
        );
    }
}
