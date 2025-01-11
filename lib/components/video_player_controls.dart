import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/platform/adaptive_stronz_video_player_controls.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:sutils/utils.dart';

abstract class VideoPlayerControls extends StatefulWidget {
    final AdditionalStronzControlsBuilder? additionalControlsBuilder;

    const VideoPlayerControls({
        super.key,
        this.additionalControlsBuilder
    });

    @override
    VideoPlayerControlsState<VideoPlayerControls> createState();
}

abstract class VideoPlayerControlsState<T extends VideoPlayerControls> extends State<T> with StreamListener, StronzPlayerControl {
    late bool _buffering = super.controller(super.context).buffering;
    bool visible = true;
    bool mount = true;
    bool menuOpened = false;
    Timer? _timer;

    Widget _buildBuffering(BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: FullScreen.notifier,
            builder: (context, isFullScreen, child) => IgnorePointer(
                child: Padding(
                    padding:isFullScreen
                        ? MediaQuery.of(context).padding
                        : EdgeInsets.zero,
                    child: Column(
                        children: [
                            Container(
                                height: 56,
                                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            Expanded(
                                child: Center(
                                    child: TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                            begin: 0.0,
                                            end: this._buffering ? 1.0 : 0.0,
                                        ),
                                        duration: const Duration(milliseconds: 150),
                                        builder: (context, value, child) {
                                            if (value > 0.0)
                                                return Opacity(
                                                    opacity: value,
                                                    child: child!,
                                                );
                                            return const SizedBox.shrink();
                                        },
                                        child: const CircularProgressIndicator(),
                                    ),
                                ),
                            ),
                            Container(
                                height: 56,
                                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                            )
                        ]
                    )
                )
            )
        );
    }

    Widget _buildTopGradient(BuildContext context) {
        return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                        0.0,
                        0.2,
                    ],
                    colors: [
                        Color(0x61000000),
                        Color(0x00000000),
                    ],
                )
            )
        );
    }

    Widget _buildBottomGradient(BuildContext context) {
        return Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                        0.5,
                        1.0,
                    ],
                    colors: [
                        Color(0x00000000),
                        Color(0x61000000),
                    ],
                )
            )
        );
    }

    Widget buildTopBar(BuildContext context);
    Widget buildPrimaryBar(BuildContext context);
    Widget buildBottomBar(BuildContext context);
    Widget buildSeekBar(BuildContext context);

    List<Widget> buildAdditionalControls(BuildContext context) {
        return super.widget.additionalControlsBuilder?.call(context, this.onMenuOpened, this.onMenuClosed) ?? [];
    }

    Widget buildControls(BuildContext context) {
        return Stack(
            children: [
                AnimatedOpacity(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 150),
                    opacity: this.visible ? 1.0 : 0.0,
                    onEnd: () {
                        if (!this.visible)
                            this.setState(() => this.mount = false);
                    },
                    child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                            this._buildTopGradient(context),
                            this._buildBottomGradient(context),
                            ValueListenableBuilder(
                                valueListenable: FullScreen.notifier,
                                builder: (context, isFullScreen, child) => Padding(
                                    padding: isFullScreen
                                        ? MediaQuery.of(context).padding
                                        : EdgeInsets.zero,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                            if(this.mount)
                                                this.buildTopBar(context),
                                            Expanded(
                                                child: this.buildPrimaryBar(context)
                                            ),
                                            if(this.mount)
                                                ...[
                                                    this.buildSeekBar(context),
                                                    this.buildBottomBar(context)
                                                ]
                                        ]
                                    )
                                )
                            )
                        ]
                    ),
                ),
                this._buildBuffering(context)
            ]
        );
    }

    @override
    void setState(VoidCallback fn) {
        if (super.mounted)
            super.setState(fn);
    }

    @override
    void initState() {
        super.initState();
        this.restartTimer();
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(super.context).stream.buffering.listen(
                (event) => this.setState(() => this._buffering = event)
            )
        ]);
    }

    @override
    void dispose() {
        super.disposeSubscriptions();
        super.dispose();
    }

    void cancelTimer() {
        this._timer?.cancel();
    }

    void restartTimer() {
        this.cancelTimer();
        this._timer = Timer(const Duration(seconds: 2), () =>
            this.setState(() => this.visible = false)
        );
    }

    void onMenuOpened() {
        this.setState(() {
        this.cancelTimer();
            this.menuOpened = true;
        });
    }

    void onMenuClosed() {
        this.setState(() {
            this.menuOpened = false;
            this.restartTimer();
        });
    }
}