import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/desktop_video_player_controls.dart';
import 'package:stronz_video_player/components/mobile_video_player_controls.dart';

typedef AdditionalStronzControlsBuilder = List<Widget> Function(BuildContext context, void Function() onMenuOpened, void Function() onMenuClosed);

class AdaptiveVideoPlayerControls extends StatelessWidget {

    final AdditionalStronzControlsBuilder? additionalControlsBuilder;

    const AdaptiveVideoPlayerControls({
        super.key,
        this.additionalControlsBuilder
    });

    @override
    Widget build(BuildContext context) {
        return Platform.isAndroid || Platform.isIOS
            ? MobileVideoControls(
                additionalControlsBuilder: this.additionalControlsBuilder,
            )
            : DesktopVideoPlayerControls(
                additionalControlsBuilder: this.additionalControlsBuilder,
            );
    }
}