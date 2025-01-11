import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronz_video_player/components/controls/exit_button.dart';
import 'package:stronz_video_player/components/controls/media_title.dart';
import 'package:stronz_video_player/components/controls/next_button.dart';
import 'package:stronz_video_player/components/controls/playpause_button.dart';
import 'package:stronz_video_player/components/controls/position_indicator.dart';
import 'package:stronz_video_player/components/controls/seek_bar.dart';
import 'package:stronz_video_player/components/controls/settings_button.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:stronz_video_player/components/controls/volume_button.dart';
import 'package:stronz_video_player/components/video_player_controls.dart';
import 'package:sutils/utils.dart';


class MobileVideoPlayerControls extends VideoPlayerControls {

    const MobileVideoPlayerControls({
        super.key,
        super.additionalControlsBuilder
    });

    @override
    VideoPlayerControlsState<MobileVideoPlayerControls> createState() => _MobileVideoPlayerControlsState();
}

class _MobileVideoPlayerControlsState  extends VideoPlayerControlsState<MobileVideoPlayerControls> with StronzPlayerControl {

    late Offset _tapPosition;

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
                    ...super.buildAdditionalControls(context),
                ],
            ),
        );
    }

    @override
    Widget buildPrimaryBar(BuildContext context) {
        return const Center(
            child: PlayPauseButton(
                iconSize: 50,
            )
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
                    onDoubleTap: () => this._onDoubleTap(context),
                    onTapDown: (details) => this._tapPosition = details.localPosition,
                    onDoubleTapDown: (details) => this._tapPosition = details.localPosition,
                    child: super.buildControls(context),
                )
            )
        );
    }

    @override
    void initState() {
        super.initState();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);
        if(!EPlatform.isTablet)
            SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
            ]);
    }

    @override
    void dispose() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        if(!EPlatform.isTablet)
            SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp
            ]);
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

    void _onDoubleTap(BuildContext context) {
        double width = (context.findRenderObject() as RenderBox).paintBounds.width;
        double leftBound = 0.33, rightBound = 0.67;
        double tap = this._tapPosition.dx / width;

        Duration? delta;
        if(tap <= leftBound)
            delta = const Duration(seconds: -10);
        else if(tap >= rightBound)
            delta = const Duration(seconds: 10);
        if(delta != null) {
            controller(context, listen: false).seekTo(controller(context, listen: false).position + delta);
            super.restartTimer();
        }
    }
}
