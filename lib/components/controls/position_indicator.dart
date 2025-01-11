import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:sutils/utils.dart';

class PositionIndicator extends StatefulWidget {
    const PositionIndicator({
        super.key
    });

    @override
    State<PositionIndicator> createState() => _PositionIndicatorState();
}

class _PositionIndicatorState extends State<PositionIndicator> with StreamListener, StronzPlayerControl {
    late Duration _position = super.controller(super.context).position;
    late Duration _duration = super.controller(super.context).duration;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(super.context).stream.position.listen(
                (event) => this.setState(() => this._position = event)
            ),
            super.controller(super.context).stream.duration.listen(
                (event) => this.setState(() => this._duration = event)
            ),
        ]);
    }

    @override
    void dispose() {
        super.disposeSubscriptions();
        super.dispose();
    }

    @override
    void setState(VoidCallback fn) {
        if (this.mounted)
            super.setState(fn);
    }

    @override
    Widget build(BuildContext context) {
        return Text(
            '${this._position.label(reference: this._duration)} / ${this._duration.label(reference: this._duration)}',
            style: const TextStyle(
                fontSize: 17.0
            ),
        );
    }
}

extension _DurationExtension on Duration {
    String label({Duration? reference}) {
        reference ??= this;
        if (reference > const Duration(days: 1)) {
            final days = inDays.toString().padLeft(3, '0');
            final hours = (inHours - (inDays * 24)).toString().padLeft(2, '0');
            final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
            final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
            return '$days:$hours:$minutes:$seconds';
        } else if (reference > const Duration(hours: 1)) {
            final hours = inHours.toString().padLeft(2, '0');
            final minutes = (inMinutes - (inHours * 60)).toString().padLeft(2, '0');
            final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
            return '$hours:$minutes:$seconds';
        } else {
            final minutes = inMinutes.toString().padLeft(2, '0');
            final seconds = (inSeconds - (inMinutes * 60)).toString().padLeft(2, '0');
            return '$minutes:$seconds';
        }
    }
}
