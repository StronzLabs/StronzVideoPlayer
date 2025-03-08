abstract class Playable {
    String get title;
    Future<Uri> get source;
    Playable? get next;
    Uri get thumbnail;

    const Playable();
}
