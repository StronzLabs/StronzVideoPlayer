abstract class Track {
    final Uri uri;
    
    const Track({
        required this.uri
    });
}

class VideoTrack extends Track {
    final int quality;
    final int bandwidth;

    const VideoTrack({
        required super.uri,
        required this.quality,
        required this.bandwidth
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
