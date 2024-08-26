import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/player_stream.dart';
import 'package:stronz_video_player/data/tracks.dart';
import 'package:video_player/video_player.dart';

abstract class StronzPlayerController {
    late Playable _playable;
    Playable get playable => this._playable;
    String get title => this.playable.title;

    StronzPlayerStream get stream;

    Tracks get tracks;
    bool get buffering;
    double get aspectRatio;
    bool get playing;
    Duration get position;
    double get volume;
    Duration get duration;
    bool get completed;
    VideoTrack? get videoTrack;
    AudioTrack? get audioTrack;
    CaptionTrack? get captionTrack;
    List<DurationRange> get buffered;

    @mustCallSuper
    Future<void> initialize(Playable playable, {bool autoPlay = true}) async {
        this._playable = playable;
    }
    Future<void> dispose();

    Future<void> play();
    Future<void> pause();
    Future<void> setVolume(double volume);
    Future<void> seekTo(Duration position);
    Future<void> setVideoTrack(VideoTrack? track);
    Future<void> setAudioTrack(AudioTrack? track);
    Future<void> setCaptionTrack(CaptionTrack? track);

    Future<void> playOrPause() {
        if(this.playing)
            return this.pause();
        else
            return this.play();
    }

    @mustCallSuper
    Future<void> switchTo(Playable playable) async {
        this._playable = playable;
    }
}
