import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:stronz_video_player/logic/track_loader.dart';
import 'package:stronz_video_player/stronz_video_player.dart';
import 'package:video_player/video_player.dart';

class StronzPlayerStream {
    final Stream<VideoPlayerController?> videoPlayerController;
    final Stream<bool> buffering;
    final Stream<double> aspectRatio;
    final Stream<bool> playing;
    final Stream<Duration> position;
    final Stream<double> volume;
    final Stream<Duration> duration;
    final Stream<bool> completed;
    final Stream<VideoTrack?> videoTrack;
    final Stream<AudioTrack?> audioTrack;
    final Stream<CaptionTrack?> captionTrack;
    final Stream<List<DurationRange>> buffered;
    final Stream<String> title;

    const StronzPlayerStream({
        required this.videoPlayerController,
        required this.buffering,
        required this.aspectRatio,
        required this.playing,
        required this.position,
        required this.volume,
        required this.duration,
        required this.completed,
        required this.videoTrack,
        required this.audioTrack,
        required this.captionTrack,
        required this.buffered,
        required this.title
    });
}

class StronzPlayerController {

    late Playable _playable;
    Playable get playable => this._playable;
    Tracks tracks = const EmptyTracks();

    VideoPlayerController? _videoPlayerController;
    final StreamController<VideoPlayerController?> _videoPlayerControllerStream = StreamController<VideoPlayerController?>.broadcast();
    VideoPlayerController get videoPlayerController => this._videoPlayerController!;

    bool _buffering = true;
    final StreamController<bool> _bufferingStream = StreamController<bool>.broadcast();
    bool get buffering => this._buffering;
    
    double _aspectRatio = 1.0;
    final StreamController<double> _aspectRatioStream = StreamController<double>.broadcast();
    double get aspectRatio => this._aspectRatio;

    bool _playing = false;
    final StreamController<bool> _playingStream = StreamController<bool>.broadcast();
    bool get playing => this._playing;

    Duration _position = Duration.zero;
    final StreamController<Duration> _positionStream = StreamController<Duration>.broadcast();
    Duration get position => this._position;

    double _volume = 1.0;
    final StreamController<double> _volumeStream = StreamController<double>.broadcast();
    double get volume => this._volume;

    Duration _duration = Duration.zero;
    final StreamController<Duration> _durationStream = StreamController<Duration>.broadcast();
    Duration get duration => this._duration;

    bool _completed = false;
    final StreamController<bool> _completedStream = StreamController<bool>.broadcast();
    bool get completed => this._completed;

    VideoTrack? _videoTrack;
    final StreamController<VideoTrack?> _videoTrackStream = StreamController<VideoTrack?>.broadcast();
    VideoTrack? get videoTrack => this._videoTrack;

    AudioTrack? _audioTrack;
    final StreamController<AudioTrack?> _audioTrackStream = StreamController<AudioTrack?>.broadcast();
    AudioTrack? get audioTrack => this._audioTrack;

    CaptionTrack? _captionTrack;
    final StreamController<CaptionTrack?> _captionTrackStream = StreamController<CaptionTrack?>.broadcast();
    CaptionTrack? get captionTrack => this._captionTrack;

    List<DurationRange> _buffered = [];
    final StreamController<List<DurationRange>> _bufferedStream = StreamController<List<DurationRange>>.broadcast();
    List<DurationRange> get buffered => this._buffered;

    final StreamController<String> _titleStream = StreamController<String>.broadcast();
    String get title => this.playable.title;

    StronzPlayerStream get stream => StronzPlayerStream(
        videoPlayerController: this._videoPlayerControllerStream.stream,
        buffering: this._bufferingStream.stream,
        aspectRatio: this._aspectRatioStream.stream,
        playing: this._playingStream.stream,
        position: this._positionStream.stream,
        volume: this._volumeStream.stream,
        duration: this._durationStream.stream,
        completed: this._completedStream.stream,
        videoTrack: this._videoTrackStream.stream,
        audioTrack: this._audioTrackStream.stream,
        captionTrack: this._captionTrackStream.stream,
        buffered: this._bufferedStream.stream,
        title: this._titleStream.stream
    );

    StronzPlayerController({
        required Playable playable
    }) {
        this._playable = playable;
    }

    Future<File> _generateHLSFile() async {
        String hls = "#EXTM3U\n";
        if(this.audioTrack != null)
            hls += '#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",URI="${this.audioTrack!.uri.toString()}"\n';
        if(this.captionTrack != null)
            hls += '#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",URI="${this.captionTrack!.uri.toString()}"\n';
        hls += '#EXT-X-STREAM-INF:AUDIO="audio",SUBTITLES="subs"\n${this.videoTrack!.uri.toString()}';
        
        Directory tempDir = await getTemporaryDirectory();
        File tempHls = File("${tempDir.path}/stronz_video_player.m3u8");
        await tempHls.writeAsString(hls);
        return tempHls;
    }

    Future<VideoPlayerController> _prepareVideoPlayerController() async {
        File hls = await this._generateHLSFile();
        if(this.tracks is HLSTracks)
            return VideoPlayerController.file(hls);
        else if(this.tracks is MP4Tracks)
            return VideoPlayerController.networkUrl(this.videoTrack!.uri);
        else
            throw Exception("Unsupported tracks type: ${this.tracks.runtimeType}");
    }

    Future<void> _refreshHLSFile() async {
        VideoPlayerController newController = await this._prepareVideoPlayerController();
        VideoPlayerController oldController = this.videoPlayerController;

        bool wasPlaying = this.playing;
        await oldController.pause();
        this._bufferingStream.add(this._buffering = true);
        await newController.initialize();
        await newController.seekTo(this.position);
        await newController.setVolume(this.volume);
        if(wasPlaying)
            await newController.play();

        void bufferingListener() {
            if(!newController.value.isBuffering && (newController.value.isPlaying || !wasPlaying)) {
                newController.removeListener(bufferingListener);
                if(this._videoPlayerController == null) {
                    newController.dispose();
                    return;
                }
                oldController.removeListener(this._onVideoPlayerControllerEvent);
                newController.addListener(this._onVideoPlayerControllerEvent);
                
                this._videoPlayerController = newController;
                this._videoPlayerControllerStream.add(newController);
                
                this._bufferingStream.add(this._buffering = false);
                oldController.dispose();
            }
        }

        newController.addListener(bufferingListener);
    }

    void _autoSelectTracks() {
        if(this.tracks is HLSTracks) {
            HLSTracks tracks = this.tracks as HLSTracks;
            this._videoTrack = tracks.video.firstOrNull;
            this._audioTrack = tracks.audio.firstOrNull;
            this._captionTrack = tracks.caption.firstOrNull;

        } else if (this.tracks is MP4Tracks) {
            MP4Tracks tracks = this.tracks as MP4Tracks;
            this._videoTrack = tracks.video;
            this._audioTrack = null;
            this._captionTrack = null;
        } else
            throw Exception("Unsupported tracks type: ${this.tracks.runtimeType}");
    }

    Future<void> initialize({bool autoPlay = true}) async {
        Uri source = await this.playable.source;
        TrackLoader loader = await TrackLoader.create(source: source);
        this.tracks = await loader.loadTracks();

        this._autoSelectTracks();

        this._videoPlayerController = await this._prepareVideoPlayerController();
            
        this._videoPlayerControllerStream.add(this.videoPlayerController);
        this.videoPlayerController.addListener(this._onVideoPlayerControllerEvent);
        await this.videoPlayerController.initialize();

        if(autoPlay)
            await this.videoPlayerController.play();
    }

    Future<void> dispose({bool closeStreams = true}) async {
        await this._videoPlayerController?.dispose();
        this._videoPlayerControllerStream.add(null);
        this._videoPlayerController = null;

        if(closeStreams) {
            this._videoPlayerControllerStream.close();
            this._bufferingStream.close();
            this._aspectRatioStream.close();
            this._playingStream.close();
            this._positionStream.close();
            this._volumeStream.close();
            this._durationStream.close();
            this._completedStream.close();
            this._videoTrackStream.close();
            this._audioTrackStream.close();
            this._captionTrackStream.close();
            this._bufferedStream.close();

        }
    }

    Future<void> play() => this.videoPlayerController.play();
    Future<void> pause() => this.videoPlayerController.pause();
    Future<void> setVolume(double volume) => this.videoPlayerController.setVolume(volume);

    Future<void> playOrPause() {
        if(this.playing)
            return this.pause();
        else
            return this.play();
    }

    Future<void> seekTo(Duration position) => this.videoPlayerController.seekTo(position);

    Future<void> setVideoTrack(VideoTrack? track) async {
        this._videoTrack = track;
        this._videoTrackStream.add(this._videoTrack);
        await this._refreshHLSFile();        
    }

    Future<void> setAudioTrack(AudioTrack? track) async {
        this._audioTrack = track;
        this._audioTrackStream.add(this._audioTrack);
        await this._refreshHLSFile();
    }

    Future<void> setCaptionTrack(CaptionTrack? track) async {
        this._captionTrack = track;
        this._captionTrackStream.add(this._captionTrack);
        await this._refreshHLSFile();
    }

    Future<void> switchTo(Playable playable) async {
        this._bufferingStream.add(this._buffering = true);
        this._positionStream.add(this._position = Duration.zero);
        this._durationStream.add(this._duration = Duration.zero);
        await this.dispose(closeStreams: false);
        this._playable = playable;
        this._titleStream.add(this.playable.title);
        await this.initialize();
        this._bufferingStream.add(this._buffering = false);
    }

    void _onVideoPlayerControllerEvent() {
        if(this.videoPlayerController.value.isBuffering != this._buffering) {
            this._buffering = this.videoPlayerController.value.isBuffering;
            this._bufferingStream.add(this._buffering);
        }
        if(this.videoPlayerController.value.aspectRatio != this._aspectRatio) {
            this._aspectRatio = this.videoPlayerController.value.aspectRatio;
            this._aspectRatioStream.add(this._aspectRatio);
        }
        if(this.videoPlayerController.value.isPlaying != this._playing) {
            this._playing = this.videoPlayerController.value.isPlaying;
            this._playingStream.add(this._playing);
        }
        if(this.videoPlayerController.value.position != this._position) {
            this._position = this.videoPlayerController.value.position;
            this._positionStream.add(this._position);
        }
        if(this.videoPlayerController.value.volume != this._volume) {
            this._volume = this.videoPlayerController.value.volume;
            this._volumeStream.add(this._volume);
        }
        if(this.videoPlayerController.value.duration != this._duration) {
            this._duration = this.videoPlayerController.value.duration;
            this._durationStream.add(this._duration);
        }
        if(this.videoPlayerController.value.position == this.videoPlayerController.value.duration && !this._completed) {
            this._completed = true;
            this._completedStream.add(this._completed);
        }
        if(this.videoPlayerController.value.buffered != this._buffered) {
            this._buffered = this.videoPlayerController.value.buffered;
            this._bufferedStream.add(this._buffered);
        }
    }
}
