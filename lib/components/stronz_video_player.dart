import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/components/platform/adaptive_stronz_video_player_controls.dart';
import 'package:stronz_video_player/components/video_player_view.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';
import 'package:stronz_video_player/logic/controller/native_player_controller.dart';
import 'package:stronz_video_player/logic/controller/stronz_player_controller.dart';
import 'package:sutils/sutils.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

class StronzVideoPlayer extends StatefulWidget {
    final Playable playable;
    final StronzPlayerController controller;
    final StronzControllerState controllerState;
    final AdditionalStronzControlsBuilder? additionalControlsBuilder;
    final Widget Function(BuildContext)? controlsBuilder;
    final Widget Function(BuildContext)? videoBuilder;

    final void Function(StronzPlayerController)? onBeforeExit;
    
    StronzVideoPlayer({
        super.key,
        required this.playable,
        StronzPlayerController? controller,
        this.controllerState = const StronzControllerState.autoPlay(),
        this.additionalControlsBuilder,
        this.controlsBuilder,
        this.videoBuilder,
        this.onBeforeExit
    }) : this.controller = controller ?? NativePlayerController();

    @override
    State<StronzVideoPlayer> createState() => _StronzVideoPlayerState();

    static Future<void> initialize() async {
        await SUtils.ensureInitialized();
        VideoPlayerMediaKit.ensureInitialized(
            windows: true,
            linux: true,
            android: EPlatform.isAndroidTV
        );
    }
}

class _StronzVideoPlayerState extends State<StronzVideoPlayer> with WidgetsBindingObserver {

    late Playable _currentPlayable = super.widget.playable;
    late StronzPlayerController _playerController = super.widget.controller;
    AsyncMemoizer _controllerMemoizer = AsyncMemoizer();
    StreamSubscription? _titleSubscription;
    late StronzControllerState _controllerState = super.widget.controllerState;

    Future<void> _initController() async {
        await this._playerController.initialize(this._currentPlayable, initialState: this._controllerState);
        await this._titleSubscription?.cancel();
        this._titleSubscription = this._playerController.stream.title.listen(
            (title) => this._currentPlayable = this._playerController.playable
        );
    }

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addObserver(this);
    }

    @override
    void dispose() {
        this._playerController.dispose();
        this._titleSubscription?.cancel();
        WidgetsBinding.instance.removeObserver(this);
        super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
        if(state == AppLifecycleState.resumed)
            return;
        super.widget.onBeforeExit?.call(this._playerController);
    }

    @override
    Widget build(BuildContext context) {
        if(this._playerController.runtimeType != super.widget.controller.runtimeType) {
            this._controllerState = this._playerController.state;
            this._playerController.dispose();
            this._playerController = super.widget.controller;
            this._controllerMemoizer = AsyncMemoizer();
        }

        return PopScope(
            onPopInvokedWithResult: (_, __) => super.widget.onBeforeExit?.call(this._playerController),
            child: FutureBuilder(
                future: this._controllerMemoizer.runOnce(this._initController),
                builder: (context, snapshot) {
                    if(snapshot.hasError)
                        Future.microtask(() => this._errorPlaying());
                    
                    if (snapshot.connectionState != ConnectionState.done)
                        return const Center(child: CircularProgressIndicator());

                    return Provider<StronzPlayerController>.value(
                        value: this._playerController,
                        child: Stack(
                            alignment: Alignment.center,
                            children: [
                                super.widget.videoBuilder?.call(context)
                                ?? const VideoPlayerView(),
                                
                                super.widget.controlsBuilder?.call(context)
                                ?? AdaptiveVideoPlayerControls(
                                    additionalControlsBuilder: super.widget.additionalControlsBuilder,
                                )
                            ]
                        )
                    );
                }
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
