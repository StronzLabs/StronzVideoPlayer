import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/src/logic/controller/stronz_player_controller.dart';

mixin StronzPlayerControl<T extends StronzPlayerController> {
    T controller(BuildContext context, {bool listen = true}) {
        return Provider.of<StronzPlayerController>(context, listen: listen) as T;
    }
}
