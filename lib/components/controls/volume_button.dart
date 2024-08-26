import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_player_control.dart';
import 'package:stronz_video_player/components/linear_track_shape.dart';
import 'package:stronz_video_player/logic/stream_listener.dart';
import 'package:stronz_video_player/logic/controller/stronz_player_controller.dart';

class VolumeButton extends StatefulWidget {
    final double iconSize;

    const VolumeButton({
        super.key,
        this.iconSize = 28,
    });

    @override
    State<VolumeButton> createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<VolumeButton> with StreamListener, StronzPlayerControl, SingleTickerProviderStateMixin {

    late double _volume = super.controller(super.context).volume;

    bool _hover = false;
    bool _mute = false;
    bool _dragging = false;
    double _savedVolume = 0.0;

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();
        super.updateSubscriptions([
            super.controller(super.context).stream.volume.listen(
                (event) => this.setState(() => this._volume = event)
            )
        ]);
    }

    @override
    void dispose() {
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
        StronzPlayerController controller = super.controller(context);

        return MouseRegion(
            onEnter: (_) => this.setState(() => this._hover = true),
            onExit: (_) => this.setState(() => this._hover = false),
            child: Listener(
                onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                        if (event.scrollDelta.dy < 0)
                           controller.setVolume((this._volume + .05).clamp(0.0, 1.0));
                        if (event.scrollDelta.dy > 0)
                           controller.setVolume((this._volume - .05).clamp(0.0, 1.0));
                    }
                },
                child: Row(
                    children: [
                        const SizedBox(width: 4.0),
                        IconButton(
                            onPressed: () async {
                                if (this._mute) {
                                    this._mute = false;
                                    await controller.setVolume(this._savedVolume);
                                }
                                else if (this._volume == 0.0) {
                                    this._mute = false;
                                    await controller.setVolume(1.0);
                                } else {
                                    this._savedVolume = this._volume;
                                    this._mute = true;
                                    await controller.setVolume(0.0);
                                }
                                this.setState(() {});
                            },
                            iconSize: super.widget.iconSize,
                            icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                child: this._volume == 0.0
                                    ? const Icon(
                                        Icons.volume_off,
                                        key: ValueKey(Icons.volume_off),
                                    )
                                    : this._volume < 0.5
                                        ? const Icon(
                                            Icons.volume_down,
                                            key: ValueKey(Icons.volume_down),
                                        )
                                        : const Icon(
                                            Icons.volume_up,
                                            key: ValueKey(Icons.volume_up),
                                        )
                            )
                        ),
                        AnimatedOpacity(
                            opacity: this._hover || this._dragging ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 150),
                            child: AnimatedContainer(
                                width: this._hover || this._dragging ? (12.0 + (52.0) + 18.0) : 12.0,
                                duration: const Duration(milliseconds: 150),
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                        children: [
                                            const SizedBox(width: 12.0),
                                            SizedBox(
                                                width: 52.0,
                                                child: Theme(
                                                    data: Theme.of(context).copyWith(
                                                        sliderTheme: const SliderThemeData(
                                                            trackShape: LinearTrackShape(),
                                                            trackHeight: 1.2,
                                                            inactiveTrackColor: Color(0x3DFFFFFF),
                                                            activeTrackColor: Colors.white,
                                                            thumbColor: Colors.white,
                                                            thumbShape: RoundSliderThumbShape(
                                                                enabledThumbRadius: 12.0 / 2,
                                                                elevation: 0.0,
                                                                pressedElevation: 0.0
                                                            ),
                                                            overlayColor: Colors.transparent
                                                        )
                                                    ),
                                                    child: Slider(
                                                        onChangeStart: (_) => super.setState(() => this._dragging = true),
                                                        onChangeEnd: (_) => super.setState(() => this._dragging = false),
                                                        value: this._volume.clamp(0.0, 1.0),
                                                        min: 0.0,
                                                        max: 1.0,
                                                        onChanged: (value) async {
                                                            await controller.setVolume(value);
                                                            this.setState(() => this._mute = false);
                                                        }
                                                    )
                                                )
                                            ),
                                            const SizedBox(width: 18.0),
                                        ]
                                    )
                                )
                            )
                        )
                    ]
                )
            )
        );
    }
}
