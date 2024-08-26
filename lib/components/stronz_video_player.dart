import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/components/adaptive_stronz_video_player_controls.dart';
import 'package:stronz_video_player/components/video_player_view.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/logic/controller/native_player_controller.dart';
import 'package:stronz_video_player/logic/controller/stronz_player_controller.dart';
import 'package:window_manager/window_manager.dart';

class StronzVideoPlayer extends StatefulWidget {
    final Playable playable;
    final StronzPlayerController? controller;
    final AdditionalStronzControlsBuilder? additionalControlsBuilder;
    final Widget Function(BuildContext)? controlsBuilder;
    final Widget Function(BuildContext)? videoBuilder;

    final void Function(StronzPlayerController)? onBeforeExit;
    
    const StronzVideoPlayer({
        super.key,
        required this.playable,
        this.controller,
        this.additionalControlsBuilder,
        this.controlsBuilder,
        this.videoBuilder,
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

    late final StronzPlayerController _playerController;

    final AsyncMemoizer _controllerMemoizer = AsyncMemoizer();

    @override
    void initState() {
        super.initState();
        this._playerController = super.widget.controller ?? NativePlayerController();
    }

    @override
    void dispose() {
        this._playerController.dispose();
        super.dispose();
    }

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
    Widget build(BuildContext context) {
        return PopScope(
            onPopInvokedWithResult: (_, __) => super.widget.onBeforeExit?.call(this._playerController),
            child: Provider<StronzPlayerController>(
                create: (context) => this._playerController,
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
