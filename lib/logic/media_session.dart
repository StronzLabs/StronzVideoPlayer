

import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'package:image/image.dart' as img;
import 'package:sutils/sutils.dart';

enum MediaSessionEvent {
    play,
    pause,
}

class MediaSession {
    static final _MediaSession _instance = Platform.isWindows ? _WindowsMediaSession() : _OtherMediaSession();

    static Future<void> start(String title, Uri thumbnail, void Function(MediaSessionEvent) handler) =>
        MediaSession._instance.start(title, thumbnail, handler);
    static Future<void> stop() => MediaSession._instance.stop();
    static Future<void> informPaused() => MediaSession._instance.informPaused();
    static Future<void> informPlaying() => MediaSession._instance.informPlaying();
}

abstract class _MediaSession {
    Future<void> start(String title, Uri thumbnail, void Function(MediaSessionEvent) handler);
    Future<void> stop();
    Future<void> informPaused();
    Future<void> informPlaying();
}

class _WindowsMediaSession extends _MediaSession {

    SMTCWindows? _smtc;

    Future<Uint8List> fetchThumbnail(Uri thumbnail) async {
        Uint8List thumbnailBytes;

        if (thumbnail.scheme == 'http' || thumbnail.scheme == 'https')
            thumbnailBytes = await HTTP.getRaw(thumbnail);
        else
            thumbnailBytes = File(thumbnail.toString()).readAsBytesSync();

        img.Image? image = img.decodeImage(thumbnailBytes);
        if (image != null)
            thumbnailBytes = img.encodeJpg(image);
        return thumbnailBytes;
    }

    @override
    Future<void> start(String title, Uri thumbnail, void Function(MediaSessionEvent) handler) async {        
        this._smtc = SMTCWindows(
            metadata: MusicMetadata(
                title: title,
                albumArtist: 'StronzVideoPlayer',
                thumbnailStream: await fetchThumbnail(thumbnail)
            ),
            config: const SMTCConfig(
                fastForwardEnabled: false,
                rewindEnabled: false,
                prevEnabled: false,
                stopEnabled: false,
                nextEnabled: false,
                pauseEnabled: true,
                playEnabled: true,
            ),
        );
        this._smtc!.setPlaybackStatus(PlaybackStatus.Playing);

        this._smtc!.buttonPressStream.listen((event) {
            switch (event) {
                case PressedButton.play:
                    this.informPlaying();
                    handler(MediaSessionEvent.play);
                    break;
                case PressedButton.pause:
                    this.informPaused();
                    handler(MediaSessionEvent.pause);
                    break;
                default:
                    break;
            }
        });
    }

    @override
    Future<void> stop() async {
        await this._smtc?.disableSmtc();
        await this._smtc?.dispose();
        this._smtc = null;
    }

    @override
    Future<void> informPaused() async {
        await this._smtc!.setPlaybackStatus(PlaybackStatus.Paused);
    }

    @override
    Future<void> informPlaying() async {
        this._smtc!.setPlaybackStatus(PlaybackStatus.Playing);
    }
}

class _OtherMediaSession extends _MediaSession {

    AudioPlayerHandler? _audioHandler;

    @override
    Future<void> start(String title, Uri thumbnail, void Function(MediaSessionEvent) handler) async {
        this._audioHandler ??= await AudioService.init(
            builder: () => AudioPlayerHandler(),
            config: const AudioServiceConfig(
                androidNotificationChannelName: 'Audio playback',
                androidNotificationOngoing: true,
            )
        );

        await this._audioHandler!.start(title, thumbnail, handler);
    }

    @override
    Future<void> stop() async {
        await this._audioHandler?.stop();
    }

    @override
    Future<void> informPaused() async {
        this._audioHandler?.informPaused();
    }

    @override
    Future<void> informPlaying() async {
        this._audioHandler?.informPlaying();
    }
}

class AudioPlayerHandler extends BaseAudioHandler {
    
    void Function(MediaSessionEvent)? _handler;

    void informPaused() {
        super.playbackState.add(super.playbackState.value.copyWith(
            playing: false,
            controls: [
                MediaControl.play
            ]
        ));
    }

    void informPlaying() {
        super.playbackState.add(super.playbackState.value.copyWith(
            playing: true,
            controls: [
                MediaControl.pause
            ]
        ));
    }

    Future<void> start(String title, Uri thumbnail, void Function(MediaSessionEvent) handler) async {
        this._handler = handler;

        super.playbackState.add(PlaybackState(
            controls: [
                MediaControl.pause
            ],
            processingState: AudioProcessingState.ready,
            playing: true
        ));
    
        super.mediaItem.add(MediaItem(
            id: title,
            album: "StronzVideoPlayer",
            title: title,
            artUri: thumbnail
        ));
    }

    @override
    Future<void> play() async {
        this._handler?.call(MediaSessionEvent.play);
        this.informPlaying();
    }

    @override
    Future<void> pause() async {
        this._handler?.call(MediaSessionEvent.pause);
        this.informPaused();
    }

    @override
    Future<void> stop() async {
        super.playbackState.add(super.playbackState.value.copyWith(
            processingState: AudioProcessingState.idle,
            playing: false
        ));
        await playbackState.firstWhere((state) => state.processingState == AudioProcessingState.idle);
        this._handler = null;
    }
}