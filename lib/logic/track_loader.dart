import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:stronz_video_player/utils/simple_http.dart' as http;

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

class Tracks {
    final List<VideoTrack> video;
    final List<AudioTrack> audio;
    final List<CaptionTrack> caption;

    const Tracks({
        required this.video,
        required this.audio,
        required this.caption
    });
}

abstract class TrackLoader {
    final Uri source;

    const TrackLoader({
        required this.source
    });

    Future<Tracks> loadTracks();

    static Future<TrackLoader> create({required Uri source}) async {
        String mime = await http.mime(source);

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
        return Future.value(Tracks(
            video: [ VideoTrack(
                uri: super.source,
                quality: 0
            ) ],
            audio: [],
            caption: []
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

        HlsPlaylist playlist = await HlsPlaylistParser.create().parseString(super.source, await http.get(super.source));
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

        return Tracks(
            video: video,
            audio: audio,
            caption: caption
        );
    }
}
