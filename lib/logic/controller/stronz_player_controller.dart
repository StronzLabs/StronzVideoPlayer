import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/player_stream.dart';
import 'package:stronz_video_player/data/tracks.dart';
import 'package:video_player/video_player.dart';

abstract class StronzPlayerController {
    late Playable _playable;
    Playable get playable => this._playable;

    Tracks get tracks;

    bool _buffering = true;
    bool get buffering => this._buffering;
    final StreamController<bool> _bufferingStreamController = StreamController<bool>.broadcast();
    @protected
    set buffering(bool buffering) {
        if(this._buffering != buffering) 
            this._bufferingStreamController.add(this._buffering = buffering);
    }
    
    double _aspectRatio = 1.0;
    double get aspectRatio => this._aspectRatio;
    final StreamController<double> _aspectRatioStreamController = StreamController<double>.broadcast();
    @protected
    set aspectRatio(double aspectRatio) {
        if(this._aspectRatio != aspectRatio)
            this._aspectRatioStreamController.add(this._aspectRatio = aspectRatio);
    }

    bool _playing = false;
    bool get playing => this._playing;
    final StreamController<bool> _playingStreamController = StreamController<bool>.broadcast();
    @protected
    set playing(bool playing) {
        if(this._playing != playing)
            this._playingStreamController.add(this._playing = playing);
    }

    Duration _position = Duration.zero;
    Duration get position => this._position;
    final StreamController<Duration> _positionStreamController = StreamController<Duration>.broadcast();
    @protected
    set position(Duration position) {
        if(this._position != position)
            this._positionStreamController.add(this._position = position);
    }

    double _volume = 1.0;
    double get volume => this._volume;
    final StreamController<double> _volumeStreamController = StreamController<double>.broadcast();
    @protected
    set volume(double volume) {
        if(this._volume != volume)
            this._volumeStreamController.add(this._volume = volume);
    }

    Duration _duration = Duration.zero;
    Duration get duration => this._duration;
    final StreamController<Duration> _durationStreamController = StreamController<Duration>.broadcast();
    @protected
    set duration(Duration duration) {
        if(this._duration != duration)
            this._durationStreamController.add(this._duration = duration);
    }

    bool _completed = false;
    bool get completed => this._completed;
    final StreamController<bool> _completedStreamController = StreamController<bool>.broadcast();
    @protected
    set completed(bool completed) {
        if(this._completed != completed)
            this._completedStreamController.add(this._completed = completed);
    }

    VideoTrack? _videoTrack;
    VideoTrack? get videoTrack => this._videoTrack;
    final StreamController<VideoTrack?> _videoTrackStreamController = StreamController<VideoTrack?>.broadcast();
    @protected
    set videoTrack(VideoTrack? videoTrack) {
        if(this._videoTrack != videoTrack)
            this._videoTrackStreamController.add(this._videoTrack = videoTrack);
    }

    AudioTrack? _audioTrack;
    AudioTrack? get audioTrack => this._audioTrack;
    final StreamController<AudioTrack?> _audioTrackStreamController = StreamController<AudioTrack?>.broadcast();
    @protected
    set audioTrack(AudioTrack? audioTrack) {
        if(this._audioTrack != audioTrack)
            this._audioTrackStreamController.add(this._audioTrack = audioTrack);
    }

    CaptionTrack? _captionTrack;
    CaptionTrack? get captionTrack => this._captionTrack;
    final StreamController<CaptionTrack?> _captionTrackStreamController = StreamController<CaptionTrack?>.broadcast();
    @protected
    set captionTrack(CaptionTrack? captionTrack) {
        if(this._captionTrack != captionTrack)
            this._captionTrackStreamController.add(this._captionTrack = captionTrack);
    }

    List<DurationRange> _buffered = [];
    List<DurationRange> get buffered => this._buffered;
    final StreamController<List<DurationRange>> _bufferedStreamController = StreamController<List<DurationRange>>.broadcast();
    @protected
    set buffered(List<DurationRange> buffered) {
        if(this._buffered != buffered)
            this._bufferedStreamController.add(this._buffered = buffered);
    }

    String get title => this.playable.title;
    final StreamController<String> _titleStreamController = StreamController<String>.broadcast();

    StronzPlayerStream get stream => StronzPlayerStream(
        buffering: this._bufferingStreamController.stream,
        aspectRatio: this._aspectRatioStreamController.stream,
        playing: this._playingStreamController.stream,
        position: this._positionStreamController.stream,
        volume: this._volumeStreamController.stream,
        duration: this._durationStreamController.stream,
        completed: this._completedStreamController.stream,
        videoTrack: this._videoTrackStreamController.stream,
        audioTrack: this._audioTrackStreamController.stream,
        captionTrack: this._captionTrackStreamController.stream,
        buffered: this._bufferedStreamController.stream,
        title: this._titleStreamController.stream,
    );

    @mustCallSuper
    Future<void> initialize(Playable playable, {bool autoPlay = true}) async {
        this._playable = playable;
    }

    @mustCallSuper
    Future<void> dispose() async {
        this._bufferingStreamController.close();
        this._aspectRatioStreamController.close();
        this._playingStreamController.close();
        this._positionStreamController.close();
        this._volumeStreamController.close();
        this._durationStreamController.close();
        this._completedStreamController.close();
        this._videoTrackStreamController.close();
        this._audioTrackStreamController.close();
        this._captionTrackStreamController.close();
        this._bufferedStreamController.close();
        this._titleStreamController.close();
    }

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
        this._titleStreamController.add(this.playable.title);
    }
}
