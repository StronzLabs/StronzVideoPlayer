import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:stronz_video_player/utils/resource_manager.dart';

abstract class Track {
    final Uri uri;
    
    const Track({
        required this.uri
    });
}

class VideoTrack extends Track {
    final int quality;

    const VideoTrack({
        required super.uri,
        required this.quality
    });
}

class AudioTrack extends Track {
    final String language;

    const AudioTrack({
        required super.uri,
        required this.language
    });
}

class CaptionTrack extends Track {
    final String language;

    const CaptionTrack({
        required super.uri,
        required this.language
    });
}

abstract class Tracks {
    bool get hasVideoTrackOptions;
    bool get hasAudioTrackOptions;
    bool get hasCaptionsTrackOptions;

    bool get hasOptions => this.hasVideoTrackOptions || this.hasAudioTrackOptions || this.hasCaptionsTrackOptions;

    const Tracks();
}

class EmptyTracks extends Tracks {
    @override
    bool get hasVideoTrackOptions => false;
    @override
    bool get hasAudioTrackOptions => false;
    @override
    bool get hasCaptionsTrackOptions => false;

    const EmptyTracks();
}

class HLSTracks extends Tracks {
    final List<VideoTrack> video;
    final List<AudioTrack> audio;
    final List<CaptionTrack> caption;

    @override
    bool get hasVideoTrackOptions => this.video.length > 1;
    @override
    bool get hasAudioTrackOptions => this.audio.length > 1;
    @override
    bool get hasCaptionsTrackOptions => this.caption.isNotEmpty;

    const HLSTracks({
        required this.video,
        required this.audio,
        required this.caption
    });
}

class MP4Tracks extends Tracks {
    final VideoTrack video;

    @override
    bool get hasVideoTrackOptions => false;
    @override
    bool get hasAudioTrackOptions => false;
    @override
    bool get hasCaptionsTrackOptions => false;

    const MP4Tracks({
        required this.video
    });
}

abstract class TrackLoader {
    final Uri source;

    const TrackLoader({
        required this.source
    });

    Future<Tracks> loadTracks();

    static Future<TrackLoader> create({required Uri source}) async {
        String mime = await ResourceManager.type(source);

        if (mime == "video/mp4")
            return MP4TrackLoader(source: source);
        else if(mime == "application/vnd.apple.mpegurl")
            return HLSTrackLoader(source: source);
        else
            throw Exception("Unsupported mime type: ${mime}");
    }
}

class MP4TrackLoader extends TrackLoader {
    const MP4TrackLoader({required super.source});

    @override
    Future<Tracks> loadTracks() {
        return Future.value(MP4Tracks(
            video: VideoTrack(
                uri: super.source,
                quality: 0
            )
        ));
    }
}

class HLSTrackLoader extends TrackLoader {
    const HLSTrackLoader({required super.source});

    int deduceVariantResolution(Variant variant) {
        if(variant.format.height != null)
            return variant.format.height!;

        String resString = variant.url.queryParameters["rendition"]!;
        return int.parse(resString.substring(0, resString.length - 1));
    } 

    @override
    Future<Tracks> loadTracks() async {
        HlsPlaylist playlist = await HlsPlaylistParser.create().parseString(super.source, await ResourceManager.content(super.source));
        if(playlist is! HlsMasterPlaylist)
            throw Exception("Not a master playlist");

        List<VideoTrack> video = [
            for (Variant variant in playlist.variants)
                VideoTrack(
                    uri: variant.url,
                    quality: deduceVariantResolution(variant)
                )
        ];

        List<AudioTrack> audio = [
            for (Rendition rendition in playlist.audios)
                AudioTrack(
                    uri: rendition.url!,
                    language: rendition.name ?? rendition.format.label ?? rendition.format.language ?? "Unknown"
                )
        ];

        List<CaptionTrack> caption = [
            for (Rendition rendition in playlist.subtitles)
                CaptionTrack(
                    uri: rendition.url!,
                    language: rendition.name ?? rendition.format.label ?? rendition.format.language ?? "Unknown"
                )
        ];

        return HLSTracks(
            video: video,
            audio: audio,
            caption: caption
        );
    }
}
