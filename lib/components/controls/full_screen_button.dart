import 'package:flutter/material.dart';
import 'package:stronz_video_player/utils/fullscreen.dart';

class FullScreenButton extends StatelessWidget {
    final double iconSize;
    
    const FullScreenButton({
        super.key,
        this.iconSize = 28,
    });

    @override
    Widget build(BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: FullScreen.isFullScreenSync(),
            builder: (context, isFullScreen, child) => IconButton(
                iconSize: this.iconSize,
                icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                onPressed: () {
                    FullScreen.toggle();
                }
            )
        );
    }
}
