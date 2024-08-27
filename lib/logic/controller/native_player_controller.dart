import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:stronz_video_player/data/playable.dart';
import 'package:stronz_video_player/data/tracks.dart';
import 'package:stronz_video_player/logic/controller/stronz_player_controller.dart';
import 'package:stronz_video_player/logic/track_loader.dart';
import 'package:video_player/video_player.dart';

class NativePlayerController extends StronzPlayerController {

    @override
    Tracks tracks = const EmptyTracks();

    VideoPlayerController? _videoPlayerController;
    final StreamController<VideoPlayerController?> _videoPlayerControllerController = StreamController<VideoPlayerController?>.broadcast();
    Stream<VideoPlayerController?> get videoPlayerControllerStream => this._videoPlayerControllerController.stream;
    VideoPlayerController? get videoPlayerControllerOrNull => this._videoPlayerController;
    VideoPlayerController get videoPlayerController => this._videoPlayerController!;

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
        super.buffering = true;
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
                this._videoPlayerControllerController.add(newController);
                
                super.buffering = false;
                oldController.dispose();
            }
        }

        newController.addListener(bufferingListener);
    }

    void _autoSelectTracks() {
        if(this.tracks is HLSTracks) {
            HLSTracks tracks = this.tracks as HLSTracks;
            super.videoTrack = tracks.video.firstOrNull;
            super.audioTrack = tracks.audio.firstOrNull;
            super.captionTrack = tracks.caption.firstOrNull;

        } else if (this.tracks is MP4Tracks) {
            MP4Tracks tracks = this.tracks as MP4Tracks;
            super.videoTrack = tracks.video;
            super.audioTrack = null;
            super.captionTrack = null;
        } else
            throw Exception("Unsupported tracks type: ${this.tracks.runtimeType}");
    }

    @override
    Future<void> initialize(Playable playable, {bool autoPlay = true}) async {
        await super.initialize(playable);
        
        Uri source = await this.playable.source;
        TrackLoader loader = await TrackLoader.create(source: source);
        this.tracks = await loader.loadTracks();
        this._autoSelectTracks();

        this._videoPlayerController = await this._prepareVideoPlayerController();
            
        this._videoPlayerControllerController.add(this.videoPlayerController);
        this.videoPlayerController.addListener(this._onVideoPlayerControllerEvent);
        await this.videoPlayerController.initialize();
        this._videoPlayerControllerController.add(this.videoPlayerController);

        if(autoPlay)
            await this.videoPlayerController.play();
    }

    Future<void> _disposeVideoPlayerController() async {
        await this._videoPlayerController?.dispose();
        this._videoPlayerControllerController.add(null);
        this._videoPlayerController = null;
    }

    @override
    Future<void> dispose() async {
        await this._disposeVideoPlayerController();
        super.dispose();
    }

    @override
    Future<void> play() => this.videoPlayerController.play();
    @override
    Future<void> pause() => this.videoPlayerController.pause();
    @override
    Future<void> setVolume(double volume) => this.videoPlayerController.setVolume(volume);
    @override
    Future<void> seekTo(Duration position) => this.videoPlayerController.seekTo(position);

    @override
    Future<void> setVideoTrack(VideoTrack? track) async {
        super.videoTrack = track;
        await this._refreshHLSFile();        
    }

    @override
    Future<void> setAudioTrack(AudioTrack? track) async {
        super.audioTrack = track;
        await this._refreshHLSFile();
    }

    @override
    Future<void> setCaptionTrack(CaptionTrack? track) async {
        super.captionTrack = track;
        await this._refreshHLSFile();
    }

    @override
    Future<void> switchTo(Playable playable) async {
        super.buffering = true;
        super.position = Duration.zero;
        super.duration = Duration.zero;

        await this._disposeVideoPlayerController();
        await super.switchTo(playable);
        await this.initialize(playable);
        
        super.buffering = false;
    }

    void _onVideoPlayerControllerEvent() {
        super.buffering = this.videoPlayerController.value.isBuffering;
        super.aspectRatio = this.videoPlayerController.value.aspectRatio;
        super.playing = this.videoPlayerController.value.isPlaying;
        super.position = this.videoPlayerController.value.position;
        super.volume = this.videoPlayerController.value.volume;
        super.duration = this.videoPlayerController.value.duration;
        super.buffered = this.videoPlayerController.value.buffered;
        super.completed = this.videoPlayerController.value.position == this.videoPlayerController.value.duration;
    }
}
