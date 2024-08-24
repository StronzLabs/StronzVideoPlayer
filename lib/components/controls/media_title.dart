import 'package:flutter/material.dart';
import 'package:stronz_video_player/components/controls/stronz_control.dart';

class MediaTitle extends StatelessWidget with StronzControl {
    const MediaTitle({super.key});

    @override
    Widget build(BuildContext context) {
        return Expanded(
            child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                    super.controller(context).title,
                    style: const TextStyle(
                        fontSize: 21.0
                    ),
                ),
            ),
        );
    }
}
