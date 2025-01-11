import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:sutils/utils.dart';

class PlayPauseButton extends StatefulWidget {
    final double iconSize;
    final void Function()? onFocus;
    final void Function()? onFocusLost;

    const PlayPauseButton({
        super.key,
        this.iconSize = 28,
        this.onFocus,
        this.onFocusLost
    });

    @override
    State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> with StreamListener, StronzPlayerControl, SingleTickerProviderStateMixin {
    
    final FocusNode _focusNode = FocusNode();
    late final AnimationController _animation = AnimationController(
        vsync: this,
        value: super.controller(super.context).playing ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
    );

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(super.context).stream.playing.listen((event) {
                if(super.mounted)
                    if (event)
                        this._animation.forward();
                    else
                        this._animation.reverse();
            })
        ]);
    }

    @override
    void initState() {
        super.initState();
        this._focusNode.addListener(() {
            if (this._focusNode.hasFocus)
                super.widget.onFocus?.call();
            else
                super.widget.onFocusLost?.call();
        });
    }

    @override
    void dispose() {
        this._animation.dispose();
        super.disposeSubscriptions();
        super.dispose();
    }

    @override
    void setState(VoidCallback fn) {
        if (super.mounted)
            super.setState(fn);
    }

    @override
    Widget build(BuildContext context) {
        return IconButton(
            onPressed: super.controller(context).playOrPause,
            focusNode: this._focusNode,
            iconSize: super.widget.iconSize, 
            icon: AnimatedIcon(
                progress: this._animation,
                icon: AnimatedIcons.play_pause,
                size: super.widget.iconSize,
            )
        );
    }
}
