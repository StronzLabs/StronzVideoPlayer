import 'package:flutter/material.dart';
import 'package:stronz_video_player/utils/fullscreen.dart';

class ExitButton extends StatelessWidget {
    final double iconSize;

    const ExitButton({
        super.key,
        this.iconSize = 28,
    });

    @override
    Widget build(BuildContext context) {
        return IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: this.iconSize,
            onPressed: () async {
                if(await FullScreen.isFullScreen())
                    await FullScreen.set(false);
                if (context.mounted)
                    Navigator.of(context).pop();
            },
        );
    }
}
