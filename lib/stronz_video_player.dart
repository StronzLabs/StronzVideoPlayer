library stronz_video_player;

import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/components/desktop_video_player_controls.dart';
import 'package:stronz_video_player/components/video_player_view.dart';
import 'package:stronz_video_player/logic/stronz_player_controller.dart';
import 'package:window_manager/window_manager.dart';

abstract class Watchable {
    String get title;
    Future<Uri> get source;
    Watchable? get next;

    const Watchable();
}

class SimpleWatchable extends Watchable {
    @override
    final String title;
    @override
    Future<Uri> get source => Future.value(Uri.parse(this.url));
    @override
    Watchable? get next => this;
    final String url;

    const SimpleWatchable({
        required this.title,
        required this.url
    });
}

class StronzVideoPlayer extends StatefulWidget {
    final Watchable watchable;
    final List<Widget> Function(BuildContext)? additionalControlsBuilder;
    
    const StronzVideoPlayer({
        super.key,
        required this.watchable,
        this.additionalControlsBuilder
    });

    @override
    State<StronzVideoPlayer> createState() => _StronzVideoPlayerState();

    static Future<void> initialize() async {
        registerWith(options: {'platforms': ['windows', 'linux']});
        await windowManager.ensureInitialized();
    }
}

class _StronzVideoPlayerState extends State<StronzVideoPlayer> {

    late final StronzPlayerController _playerController = StronzPlayerController(
        watchable: super.widget.watchable
    );

    @override
    void dispose() {
        this._playerController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Provider<StronzPlayerController>(
            create: (context) => this._playerController,
            child: Stack(
                alignment: Alignment.center,
                children: [
                    const VideoPlayerView(),
                    DesktopVideoPlayerControls(
                        additionalControlsBuilder: super.widget.additionalControlsBuilder,
                    )
                ]
            )
        );
    }
}
