import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/platform/desktop_video_player_controls.dart';
import 'package:stronz_video_player/components/platform/mobile_video_player_controls.dart';
import 'package:stronz_video_player/components/platform/tv_video_player_controls.dart';
import 'package:sutils/utils.dart';

typedef AdditionalStronzControlsBuilder = List<Widget> Function(BuildContext context, void Function() onMenuOpened, void Function() onMenuClosed);

class AdaptiveVideoPlayerControls extends StatelessWidget {

    final AdditionalStronzControlsBuilder? additionalControlsBuilder;

    const AdaptiveVideoPlayerControls({
        super.key,
        this.additionalControlsBuilder
    });

    @override
    Widget build(BuildContext context) {
        if(EPlatform.isMobile)
            return MobileVideoPlayerControls(
                additionalControlsBuilder: this.additionalControlsBuilder,
            );
        
        if(EPlatform.isTV)
            return TvVideoPlayerControls(
                additionalControlsBuilder: this.additionalControlsBuilder,
            );
        
        return DesktopVideoPlayerControls(
            additionalControlsBuilder: this.additionalControlsBuilder,
        );
    }
}