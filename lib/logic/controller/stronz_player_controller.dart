import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stronz_video_player/data/player_preferences.dart';
import 'package:stronz_video_player/data/stronz_controller_state.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/controller_stream.dart';
import 'package:stronz_video_player/data/tracks.dart';
import 'package:stronz_video_player/logic/controller/stronz_external_controller.dart';
import 'package:stronz_video_player/logic/track_loader.dart';
import 'package:sutils/sutils.dart';
import 'package:video_player/video_player.dart';

abstract class StronzPlayerController {

    List<StronzExternalController> externalControllers;
    StronzPlayerController(this.externalControllers);

    late Playable _playable;
    Playable get playable => this._playable;

    Tracks tracks = const EmptyTracks();

    bool _buffering = true;
    bool get buffering => this._buffering;
    final StreamController<bool> _bufferingStreamController = StreamController<bool>.broadcast();
    @protected
    set buffering(bool buffering) {
        if(this._buffering != buffering) {
            this._bufferingStreamController.add(this._buffering = buffering);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }
    
    double _aspectRatio = 1.0;
    double get aspectRatio => this._aspectRatio;
    final StreamController<double> _aspectRatioStreamController = StreamController<double>.broadcast();
    @protected
    set aspectRatio(double aspectRatio) {
        if(this._aspectRatio != aspectRatio) {
            this._aspectRatioStreamController.add(this._aspectRatio = aspectRatio);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    bool _playing = false;
    bool get playing => this._playing;
    final StreamController<bool> _playingStreamController = StreamController<bool>.broadcast();
    @protected
    set playing(bool playing) {
        if(this._playing != playing) {
            this._playingStreamController.add(this._playing = playing);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    Duration _position = Duration.zero;
    Duration get position => this._position;
    final StreamController<Duration> _positionStreamController = StreamController<Duration>.broadcast();
    @protected
    set position(Duration position) {
        if(this._position != position) {
            this._positionStreamController.add(this._position = position);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    double _volume = 1.0;
    double get volume => this._volume;
    final StreamController<double> _volumeStreamController = StreamController<double>.broadcast();
    @protected
    set volume(double volume) {
        if(this._volume != volume) {
            this._volumeStreamController.add(this._volume = volume);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    Duration _duration = Duration.zero;
    Duration get duration => this._duration;
    final StreamController<Duration> _durationStreamController = StreamController<Duration>.broadcast();
    @protected
    set duration(Duration duration) {
        if(this._duration != duration) {
            this._durationStreamController.add(this._duration = duration);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    bool _completed = false;
    bool get completed => this._completed;
    final StreamController<bool> _completedStreamController = StreamController<bool>.broadcast();
    @protected
    set completed(bool completed) {
        if(this._completed != completed) {
            this._completedStreamController.add(this._completed = completed);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    VideoTrack? _videoTrack;
    VideoTrack? get videoTrack => this._videoTrack;
    final StreamController<VideoTrack?> _videoTrackStreamController = StreamController<VideoTrack?>.broadcast();
    @protected
    set videoTrack(VideoTrack? videoTrack) {
        if(this._videoTrack != videoTrack) {
            this._videoTrackStreamController.add(this._videoTrack = videoTrack);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    AudioTrack? _audioTrack;
    AudioTrack? get audioTrack => this._audioTrack;
    final StreamController<AudioTrack?> _audioTrackStreamController = StreamController<AudioTrack?>.broadcast();
    @protected
    set audioTrack(AudioTrack? audioTrack) {
        if(this._audioTrack != audioTrack) {
            this._audioTrackStreamController.add(this._audioTrack = audioTrack);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    CaptionTrack? _captionTrack;
    CaptionTrack? get captionTrack => this._captionTrack;
    final StreamController<CaptionTrack?> _captionTrackStreamController = StreamController<CaptionTrack?>.broadcast();
    @protected
    set captionTrack(CaptionTrack? captionTrack) {
        if(this._captionTrack != captionTrack) {
            this._captionTrackStreamController.add(this._captionTrack = captionTrack);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    List<DurationRange> _buffered = [];
    List<DurationRange> get buffered => this._buffered;
    final StreamController<List<DurationRange>> _bufferedStreamController = StreamController<List<DurationRange>>.broadcast();
    @protected
    set buffered(List<DurationRange> buffered) {
        if(this._buffered != buffered) {
            this._bufferedStreamController.add(this._buffered = buffered);
            for (StronzExternalController controller in this.externalControllers)
                controller.informState(this.state);
        }
    }

    String get title => this.playable.title;
    final StreamController<String> _titleStreamController = StreamController<String>.broadcast();

    ControllerStream get stream => ControllerStream(
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

    StronzControllerState get state => StronzControllerState(
        playing: this.playing,
        position: this.position,
        volume: this.volume,
        videoTrack: this.videoTrack?.quality,
        audioTrack: this.audioTrack?.language,
        captionTrack: this.captionTrack?.language,
    );

    Future<void> _loadTracks(StronzControllerState? initialState) async {
        Uri source = await this.playable.source;
        TrackLoader loader = await TrackLoader.create(source: source);
        this.tracks = await loader.loadTracks();

        if (this.tracks is MP4Tracks) {
            MP4Tracks tracks = this.tracks as MP4Tracks;
            this.videoTrack = tracks.video;
            this.audioTrack = null;
            this.captionTrack = null;
        }
        else if(this.tracks is HLSTracks) {
            HLSTracks tracks = this.tracks as HLSTracks;
            this.videoTrack = tracks.video.firstWhere(
                (element) => element.quality == (initialState?.videoTrack ?? PlayerPreferences.videoTrack),
                orElse: () => tracks.video.reduce((a, b) => a.quality > b.quality ? a : b)
            );
            this.audioTrack = tracks.audio.firstWhereOrNull(
                (element) => element.language == (initialState?.audioTrack ?? PlayerPreferences.audioTrack),
            ) ?? tracks.audio.firstOrNull;
            this.captionTrack = tracks.caption.firstWhereOrNull(
                (element) => element.language == (initialState?.captionTrack ?? PlayerPreferences.captionTrack)
            );

        } else 
            throw Exception("Unsupported tracks type: ${this.tracks.runtimeType}");
    }

    @mustCallSuper
    Future<void> initialize(Playable playable, {StronzControllerState? initialState}) async {
        this._playable = playable;

        for (StronzExternalController controller in this.externalControllers) {
            await controller.initialize(this._playable, (event) => switch (event) {
                StronzExternalControllerEvent.play => this.play(),
                StronzExternalControllerEvent.pause => this.pause(),
            });
        }

        await this._loadTracks(initialState);
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

        for (StronzExternalController controller in this.externalControllers)
            await controller.dispose();
    }

    Future<void> play();
    Future<void> pause();
    @mustCallSuper
    Future<void> setVolume(double volume) async {
        PlayerPreferences.volume = volume;
        await PlayerPreferences.instance.serialize();
    }

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
        await this._loadTracks(this.state);
        this._titleStreamController.add(this.playable.title);
        
        for (StronzExternalController controller in this.externalControllers)
            await controller.switchTo(playable);
    }
}
