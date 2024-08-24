import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class FullScreen {
    static final ValueNotifier<bool> _isFullScreen = ValueNotifier(false);

    static Future<void> set(bool fullscreen) async {
        await windowManager.setFullScreen(fullscreen);
        FullScreen._isFullScreen.value = fullscreen;
    }

    static Future<bool> isFullScreen() async {
        FullScreen._isFullScreen.value = await windowManager.isFullScreen();
        return FullScreen._isFullScreen.value;
    }

    static ValueNotifier<bool> isFullScreenSync() => FullScreen._isFullScreen;

    static Future<void> toggle() async {
        return FullScreen.set(!await FullScreen.isFullScreen());
    }
}
