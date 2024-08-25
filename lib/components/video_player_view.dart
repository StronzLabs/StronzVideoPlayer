import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_control.dart';
import 'package:stronz_video_player/logic/stream_listener.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
    const VideoPlayerView({super.key});

    @override
    State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> with StreamListener, StronzControl {

    final AsyncMemoizer _controllerMemoizer = AsyncMemoizer();
    
    late double _aspectRatio = super.controller(super.context).aspectRatio;
    late VideoPlayerController? _videoPlayerController = super.controller(super.context).videoPlayerController;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(super.context).stream.aspectRatio.listen((aspectRatio) {
                this.setState(() => this._aspectRatio = aspectRatio);
            }),
            super.controller(super.context).stream.videoPlayerController.listen((videoPlayerController) {
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
        return FutureBuilder(
            future: this._controllerMemoizer.runOnce(super.controller(context).initialize),
            builder: (context, snapshot) {
                if(snapshot.hasError) {
                    Future.microtask(() => this._errorPlaying());
                    return const SizedBox.shrink();
                }
                if (snapshot.connectionState == ConnectionState.done && this._videoPlayerController != null)
                    return AspectRatio(
                        aspectRatio: this._aspectRatio,
                        child: VideoPlayer(this._videoPlayerController!)
                    );
                return const SizedBox.shrink();
            }
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