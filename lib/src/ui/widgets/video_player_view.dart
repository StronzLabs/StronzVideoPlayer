import 'package:flutter/material.dart';
import 'package:stronz_video_player/src/ui/controls/stronz_player_control.dart';
import 'package:stronz_video_player/src/logic/controller/native_player_controller.dart';
import 'package:sutils/utils.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
    const VideoPlayerView({super.key});

    @override
    State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> with StreamListener, StronzPlayerControl<NativePlayerController> {
    
    late double _aspectRatio = super.controller(super.context).aspectRatio;
    late VideoPlayerController? _videoPlayerController = super.controller(super.context).videoPlayerControllerOrNull;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(super.context).stream.aspectRatio.listen((aspectRatio) {
                this.setState(() => this._aspectRatio = aspectRatio);
            }),
            super.controller(super.context).videoPlayerControllerStream.listen((videoPlayerController) {
                this.setState(() => this._videoPlayerController = videoPlayerController);
            })
        ]);
    }

    @override
    void setState(VoidCallback fn) {
        if(super.mounted)
            super.setState(fn);
    }

    @override
    Widget build(BuildContext context) {
        if(this._videoPlayerController == null)
            return const SizedBox.shrink();

        return AspectRatio(
            aspectRatio: this._aspectRatio,
            child: VideoPlayer(this._videoPlayerController!)
        );
    }
}
