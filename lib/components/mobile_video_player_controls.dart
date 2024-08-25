import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronz_video_player/components/controls/exit_button.dart';
import 'package:stronz_video_player/components/controls/media_title.dart';
import 'package:stronz_video_player/components/controls/next_button.dart';
import 'package:stronz_video_player/components/controls/playpause_button.dart';
import 'package:stronz_video_player/components/controls/position_indicator.dart';
import 'package:stronz_video_player/components/controls/seek_bar.dart';
import 'package:stronz_video_player/components/controls/settings_button.dart';
import 'package:stronz_video_player/components/controls/stronz_control.dart';
import 'package:stronz_video_player/components/controls/volume_button.dart';
import 'package:stronz_video_player/components/video_player_controls.dart';


class MobileVideoControls extends VideoPlayerControls {

    const MobileVideoControls({
        super.key,
        super.additionalControlsBuilder
    });

    @override
    VideoPlayerControlsState<MobileVideoControls> createState() => _MobileVideoControlsState();
}

class _MobileVideoControlsState  extends VideoPlayerControlsState<MobileVideoControls> with StronzControl {

    @override
    Widget buildTopBar(BuildContext context) {
        return Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
                children: [
                    const ExitButton(),
                    const SizedBox(width: 8.0),
                    const MediaTitle(),
                    const SizedBox(width: 8.0),
                    if(super.widget.additionalControlsBuilder != null) ...[
                        const SizedBox(width: 8.0),
                        ...super.widget.additionalControlsBuilder!(context)
                    ]
                ],
            ),
        );
    }

    @override
    Widget buildPrimaryBar(BuildContext context) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                // TODO: double tap the screen to seek 10 seconds back
                if(super.mount)
                    const PlayPauseButton(
                        iconSize: 50,
                    ),
                // TODO: double tap the screen to seek 10 seconds forward
            ]
        );
    }

    @override
    Widget buildBottomBar(BuildContext context) {
        return Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
                children: [
                    const PlayPauseButton(),
                    const NextButton(),
                    const VolumeButton(),
                    const PositionIndicator(),
                    const Spacer(),
                    SettingsButton(
                        onOpened: super.onMenuOpened,
                        onClosed: super.onMenuClosed,
                    )
                ]
            )
        );
    }

    @override
    Widget buildSeekBar(BuildContext context) {
        return Transform.translate(
            offset: const Offset(0.0, 16.0),
            child: SeekBar(
                onSeekStart: super.cancelTimer,
                onSeekEnd: super.restartTimer
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return CallbackShortcuts(
            bindings: {
                const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
                    super.controller(context).play(),
                const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
                    super.controller(context).pause(),
                const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
                    super.controller(context).playOrPause(),
            },
            child: Focus(
                autofocus: true,
                child: GestureDetector(
                    onTap: this._onTap,
                    child: super.buildControls(context),
                )
            )
        );
    }

    @override
    void initState() {
        super.initState();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
    }

    @override
    void dispose() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        super.dispose();
    }

    void _onTap() {
        if (super.visible) {
            super.cancelTimer();
            super.setState(() => super.visible = false);
        } else {
            super.restartTimer();
            super.setState(() {
                super.mount = true;
                super.visible = true;
            });
        }
    }
}
