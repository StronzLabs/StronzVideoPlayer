import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stronz_video_player/components/controls/media_title.dart';
import 'package:stronz_video_player/components/controls/next_button.dart';
import 'package:stronz_video_player/components/controls/playpause_button.dart';
import 'package:stronz_video_player/components/controls/position_indicator.dart';
import 'package:stronz_video_player/components/controls/seek_bar.dart';
import 'package:stronz_video_player/components/controls/settings_button.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:stronz_video_player/components/video_player_controls.dart';


class TvVideoPlayerControls extends VideoPlayerControls {

    const TvVideoPlayerControls({
        super.key,
        super.additionalControlsBuilder
    });

    @override
    VideoPlayerControlsState<TvVideoPlayerControls> createState() => _TvVideoPlayerControlsState();
}

class _TvVideoPlayerControlsState  extends VideoPlayerControlsState<TvVideoPlayerControls> with StronzPlayerControl {

    final FocusNode _focusNode = FocusNode();
    final FocusNode _seekBarNode = FocusNode();

    @override
    Widget buildTopBar(BuildContext context) {
        return Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Row(
                children: [
                    MediaTitle()
                ]
            )
        );
    }

    @override
    Widget buildPrimaryBar(BuildContext context) {
        return const SizedBox.shrink();
    }

    @override
    Widget buildBottomBar(BuildContext context) {
        return Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
                children: [
                    PlayPauseButton(
                        onFocus: super.cancelTimer,
                        onFocusLost: super.restartTimer,
                    ),
                    NextButton(
                        onFocus: super.cancelTimer,
                        onFocusLost: super.restartTimer,
                    ),
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
            child: KeyboardListener(
                focusNode: this._seekBarNode,
                child: const SeekBar(),
                onKeyEvent: (key) {
                    if (key is KeyDownEvent && key.logicalKey == LogicalKeyboardKey.select)
                        controller(context).playOrPause();
                    if (key is KeyDownEvent && key.logicalKey == LogicalKeyboardKey.arrowRight) {
                        final rate = controller(context).position + const Duration(seconds: 5);
                        controller(context).seekTo(rate);
                        super.restartTimer();
                    }
                    if (key is KeyDownEvent && key.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        final rate = controller(context).position - const Duration(seconds: 5);
                        controller(context).seekTo(rate);
                        super.restartTimer();
                    }
                },
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return PopScope(
            canPop: !super.visible,
            onPopInvokedWithResult: (_, __) {
                if (super.visible)
                    super.setState(() {
                        super.mount = false;
                        super.visible = false;
                    });
            },
            child: CallbackShortcuts(
                bindings: {
                    const SingleActivator(LogicalKeyboardKey.mediaPlay): () =>
                        controller(context).play(),
                    const SingleActivator(LogicalKeyboardKey.mediaPause): () =>
                        controller(context).pause(),
                    const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () =>
                        controller(context).playOrPause(),
                },
                child: KeyboardListener(
                    autofocus: true,
                    focusNode: this._focusNode,
                    child: super.buildControls(context),
                    onKeyEvent: (key) {
                        if (key is KeyDownEvent && key.logicalKey == LogicalKeyboardKey.select)
                            this._onFocus();
                    },
                )
            )
        );
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        this._focusNode.requestFocus();
    }

    @override
    void dispose() {
        super.dispose();
        this._focusNode.dispose();
    }

    void _onFocus() {
        super.restartTimer();
        super.setState(() {
            super.mount = true;
            super.visible = true;
        });
        this._seekBarNode.requestFocus();
    }
}
