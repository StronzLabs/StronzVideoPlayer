import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/components/adaptive_stronz_video_player_controls.dart';
import 'package:stronz_video_player/components/video_player_view.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/logic/controller/native_player_controller.dart';
import 'package:stronz_video_player/logic/controller/stronz_player_controller.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:window_manager/window_manager.dart';

class StronzVideoPlayer extends StatefulWidget {
    final Playable playable;
    final StronzPlayerController controller;
    final AdditionalStronzControlsBuilder? additionalControlsBuilder;
    final Widget Function(BuildContext)? controlsBuilder;
    final Widget Function(BuildContext)? videoBuilder;

    final void Function(StronzPlayerController)? onBeforeExit;
    
    StronzVideoPlayer({
        super.key,
        required this.playable,
        StronzPlayerController? controller,
        this.additionalControlsBuilder,
        this.controlsBuilder,
        this.videoBuilder,
        this.onBeforeExit
    }) : this.controller = controller ?? NativePlayerController();

    @override
    State<StronzVideoPlayer> createState() => _StronzVideoPlayerState();

    static Future<void> initialize() async {
        VideoPlayerMediaKit.ensureInitialized(
            android: true,
            iOS: true,
            macOS: true,
            windows: true,
            linux: true,
        );
        if(Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            await windowManager.ensureInitialized();
    }
}

class _StronzVideoPlayerState extends State<StronzVideoPlayer> {

    late StronzPlayerController _playerController = super.widget.controller;
    AsyncMemoizer _controllerMemoizer = AsyncMemoizer();

    Widget _buildVideoPlayer(BuildContext context) {
        return FutureBuilder(
            future: this._controllerMemoizer.runOnce(() => this._playerController.initialize(super.widget.playable)),
            builder: (context, snapshot) {
                if(snapshot.hasError)
                    Future.microtask(() => this._errorPlaying());
                
                if (snapshot.connectionState != ConnectionState.done)
                    return const SizedBox.shrink();
                
                return super.widget.videoBuilder?.call(context) ?? const VideoPlayerView();
            }
        );
    }

    @override
    void dispose() {
        this._playerController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        if(this._playerController.runtimeType != super.widget.controller.runtimeType) {
            this._playerController.dispose();
            this._playerController = super.widget.controller;
            this._playerController.initialize(super.widget.playable).onError((e, s) => this._errorPlaying());
            this._controllerMemoizer = AsyncMemoizer();
        }

        return PopScope(
            onPopInvokedWithResult: (_, __) => super.widget.onBeforeExit?.call(this._playerController),
            child: Provider<StronzPlayerController>.value(
                value: this._playerController,
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                        this._buildVideoPlayer(context),
                        super.widget.controlsBuilder?.call(context)
                        ?? AdaptiveStronzVideoPlayerControls(
                            additionalControlsBuilder: super.widget.additionalControlsBuilder,
                        )
                    ]
                )
            )
        );
    }

    Future<void> _errorPlaying() async {
        await showDialog(
            context: super.context,
            builder: (context) => AlertDialog(
                title: const Text('Errore imprevisto'),
                content: const Text('Si è verificato un errore durante la riproduzione, riprova più tardi.'),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.of(super.context).pop(),
                        child: const Text('Torna indietro')
                    )
                ],
            )
        );
        if(super.mounted)
            Navigator.of(super.context).pop();
    }
}
