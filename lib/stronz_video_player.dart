import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stronz_video_player/src/data/player_preferences.dart';
import 'package:sutils/utils.dart';
import 'package:fvp/fvp.dart' as fvp;

final class StronzVideoPlayer {
    static late Future<void> Function() _initializer;
    static bool _initialized = false;

    static Future<void> ensureInitialized() async {
        if(StronzVideoPlayer._initialized)
            return;
        StronzVideoPlayer._initialized = true;
        await StronzVideoPlayer._initializer();
    }

    static void register() => StronzVideoPlayer.registerWith();

    static void registerWith() {
        StronzVideoPlayer._initializer = () async {
            WidgetsFlutterBinding.ensureInitialized();
            await PlayerPreferences.instance.unserialize();
            fvp.registerWith(options: {'platforms': [
                // Tizen shit
                if(Platform.isLinux)
                    'linux',
                // Floating pixels
                if(EPlatform.isAndroidTV)
                    'android'
            ]});
        };
    }
}
