abstract class Playable {
    String get title;
    Future<Uri> get source;
    Playable? get next;

    const Playable();
}
