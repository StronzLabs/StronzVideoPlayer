import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stronz_video_player/logic/stronz_player_controller.dart';

mixin StronzControl {
    StronzPlayerController controller(BuildContext context, {bool listen = true}) => Provider.of<StronzPlayerController>(context, listen: listen);
}
