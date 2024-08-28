class StronzControllerState {
    final bool? playing;
    final Duration? position;
    final double? volume;

    const StronzControllerState({
        this.playing,
        this.position,
        this.volume
    });

    const StronzControllerState.autoPlay({
        Duration? position,
        double? volume
    }) : this(
        playing: true,
        position: position,
        volume: volume
    );
}
