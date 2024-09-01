import 'package:sutils/sutils.dart';

class PlayerPreferences extends LocalStorage {
    static final PlayerPreferences instance = PlayerPreferences._();
    PlayerPreferences._() : super("StronzVideoPlayer", {
        "volume": 100.0,
        "videoTrack": 0,
        "audioTrack": "Italian",
        "captionTrack": "Nessuno",
    });

    static double get volume => PlayerPreferences.instance["volume"];
    static set volume(double value) => PlayerPreferences.instance["volume"] = value;
    static int get videoTrack => PlayerPreferences.instance["videoTrack"];
    static set videoTrack(int value) => PlayerPreferences.instance["videoTrack"] = value;
    static String get audioTrack => PlayerPreferences.instance["audioTrack"];
    static set audioTrack(String value) => PlayerPreferences.instance["audioTrack"] = value;
    static String get captionTrack => PlayerPreferences.instance["captionTrack"];
    static set captionTrack(String value) => PlayerPreferences.instance["captionTrack"] = value;
}
