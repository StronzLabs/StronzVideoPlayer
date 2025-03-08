import 'dart:async';
import 'dart:io';

import 'package:stronz_video_player/src/data/stronz_controller_state.dart';
import 'package:stronz_video_player/src/data/playable.dart';
import 'package:stronz_video_player/src/data/tracks.dart';
import 'package:stronz_video_player/src/logic/controller/stronz_player_controller.dart';
import 'package:sutils/utils.dart';
import 'package:video_player/video_player.dart';

class NativePlayerController extends StronzPlayerController {

    NativePlayerController(super.externalControllers);
    
    VideoPlayerController? _videoPlayerController;
    final StreamController<VideoPlayerController?> _videoPlayerControllerController = StreamController<VideoPlayerController?>.broadcast();

    Stream<VideoPlayerController?> get videoPlayerControllerStream => this._videoPlayerControllerController.stream;
    VideoPlayerController? get videoPlayerControllerOrNull => this._videoPlayerController;
    VideoPlayerController get videoPlayerController => this._videoPlayerController!;

    HttpServer? _server;
    late String _hls;

    void _generateHLSFile() {
        String hls = "#EXTM3U\n";
        if(this.audioTrack != null)
            hls += '#EXT-X-MEDIA:TYPE=AUDIO,NAME="${this.audioTrack!.language}",GROUP-ID="audio",DEFAULT=YES,URI="${this.audioTrack!.uri.toString()}"\n';
        if(this.captionTrack != null)
            hls += '#EXT-X-MEDIA:TYPE=SUBTITLES,NAME="${this.captionTrack!.language}",GROUP-ID="subs",DEFAULT=YES,URI="${this.captionTrack!.uri.toString()}"\n';
        hls += '#EXT-X-STREAM-INF:BANDWIDTH=${this.videoTrack!.bandwidth}${this.audioTrack != null ? ',AUDIO="audio"' : ''}${this.captionTrack != null ? ',SUBTITLES="subs"' : ''}\n${this.videoTrack!.uri.toString()}';
        
        this._hls = hls;
    }

    Future<VideoPlayerController> _prepareVideoPlayerController() async {
        Uri uri;
        switch (this.tracks.runtimeType) {
            case HLSTracks:
                this._generateHLSFile();
                uri = Uri.parse("http://${this._server!.address.address}:${this._server!.port}/index.m3u8");
                break;
            case MP4Tracks:
                uri = this.videoTrack!.uri;
                break;
            default:
                throw Exception("Unsupported tracks type: ${this.tracks.runtimeType}");
        }

        return VideoPlayerController.networkUrl(uri,
            // TODO: https://github.com/jakky1/video_player_win/issues/45
            httpHeaders: Platform.isWindows && this.tracks is HLSTracks ? {} : {"User-Agent": HTTP.userAgent}
        );
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

    Future<void> _startServer() async {
        await this._closeServer();
        this._server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        this._server!.forEach((request) {
            request.response.headers.contentType = ContentType.parse("application/vnd.apple.mpegurl");
            request.response.write(this._hls);
            request.response.close();
        });
    }

    Future<void> _closeServer() async {
        if(this._server != null)
            await this._server!.close(force: true);
    }

    @override
    Future<void> initialize(Playable playable, {StronzControllerState? initialState}) async {
        if(super.initialized)
            return;
        await super.initialize(playable);
        await SafeWakelock.enable();

        await this._startServer();
        await this._initializeVideoPlayerController();

        if(initialState == null)
            return;
        if(initialState.playing ?? false)
            await this.play();
        if(initialState.position != null)
            await this.seekTo(initialState.position!);
        if(initialState.volume != null)
            await this.setVolume(initialState.volume!);
    }

    Future<void> _initializeVideoPlayerController() async {
        this._videoPlayerController = await this._prepareVideoPlayerController();

        this._videoPlayerControllerController.add(this.videoPlayerController);
        this.videoPlayerController.addListener(this._onVideoPlayerControllerEvent);
        await this.videoPlayerController.initialize();
        this._videoPlayerControllerController.add(this.videoPlayerController);
    }

    Future<void> _disposeVideoPlayerController() async {
        await this._videoPlayerController?.dispose();
        this._videoPlayerControllerController.add(null);
        this._videoPlayerController = null;
    }

    @override
    Future<void> dispose() async {
        if(!super.initialized)
            return;
        await this._disposeVideoPlayerController();
        await this._closeServer();
        await SafeWakelock.disable();
        await super.dispose();
    }

    @override
    Future<bool> play() async {
        if(!await super.play())
            return false;
        await SafeWakelock.enable();
        await this._videoPlayerController?.play();
        return true;
    }

    @override
    Future<bool> pause() async {
        if(!await super.pause())
            return false;
        await SafeWakelock.disable();
        await this._videoPlayerController?.pause();
        return true;
    }

    @override
    Future<void> setVolume(double volume) async {
        await super.setVolume(volume);
        await this._videoPlayerController?.setVolume(volume);
    }

    @override
    Future<bool> seekTo(Duration position) async {
        if(!await super.seekTo(position))
            return false;
        await this._videoPlayerController?.seekTo(position);
        return true;
    }

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
        await this._initializeVideoPlayerController();
        await this.play();
        
        super.buffering = false;
    }

    void _onVideoPlayerControllerEvent() {
        super.buffering = this.videoPlayerController.value.isBuffering;
        super.aspectRatio = this.videoPlayerController.value.aspectRatio;
        super.playing = this.videoPlayerController.value.isPlaying && !this.videoPlayerController.value.isBuffering;
        super.position = this.videoPlayerController.value.position;
        super.volume = this.videoPlayerController.value.volume;
        super.duration = this.videoPlayerController.value.duration;
        super.buffered = this.videoPlayerController.value.buffered;
        super.completed = this.videoPlayerController.value.position == this.videoPlayerController.value.duration;
    }
}
