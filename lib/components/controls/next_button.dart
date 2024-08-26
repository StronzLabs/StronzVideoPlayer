import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:stronz_video_player/data/playable.dart';

class NextButton extends StatefulWidget {
    final double iconSize;
    final void Function()? onFocus;
    final void Function()? onFocusLost;

    const NextButton({
        super.key,
        this.iconSize = 28,
        this.onFocus,
        this.onFocusLost,
    });

    @override
    State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> with StronzPlayerControl {

    final FocusNode _focusNode = FocusNode();
    late Playable? _next;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        this._next = super.controller(super.context).playable.next;
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
    Widget build(BuildContext context) {
        if (this._next == null)
            return const SizedBox.shrink();

        return IconButton(
            focusNode: this._focusNode,
            onPressed: () => super.controller(context, listen: false).switchTo(this._next!),
            iconSize: super.widget.iconSize,
            icon: const Icon(Icons.skip_next),
        );
    }
}
