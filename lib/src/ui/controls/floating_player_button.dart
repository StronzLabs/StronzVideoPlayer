import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/video_player.dart';
import 'package:sutils/utils.dart';

class FloatingPlayerButton extends StatelessWidget with StronzPlayerControl {
    final double iconSize;
    
    const FloatingPlayerButton({
        super.key,
        this.iconSize = 28
    });

    void _showFloatingPlayer(BuildContext context) {
        if(FullScreen.checkSync())
            FullScreen.set(false);

        StronzPlayerController controller = super.controller(context, listen: false);
        StronzFloatingPlayerContext.of(context)!.show(
            (_) => Provider<StronzPlayerController>.value(
                value: controller,
                child: const Center(
                    child: VideoPlayerView()
                )
            ),
            onClose: StronzFloatingPlayerContext.of(context)!.onFloatingPlayerClose,
            onExpand: StronzFloatingPlayerContext.of(context)!.onFloatingPlayerExpand
        );
        
        StronzFloatingPlayerContext.of(context)!.onFloatingPlayerShow?.call();
        Navigator.of(context).pop();
    }

    @override
    Widget build(BuildContext context) {
        if(EPlatform.isTV || StronzFloatingPlayerContext.of(context) == null)
            return const SizedBox.shrink();

        return IconButton(
            icon: const Icon(Icons.picture_in_picture_alt_rounded),
            iconSize: this.iconSize,
            onPressed: () => this._showFloatingPlayer(context),
        );
    }
}
