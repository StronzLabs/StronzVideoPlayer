import 'package:sutils/sutils.dart';

class PlayerPreferences extends LocalStorage {
    static final PlayerPreferences instance = PlayerPreferences._();
    PlayerPreferences._() : super("StronzVideoPlayer", {
        "volume": 100.0,
    });

    static double get volume => PlayerPreferences.instance["volume"];
    static set volume(double value) => PlayerPreferences.instance["volume"] = value;
}
