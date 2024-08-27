import 'dart:io';

import 'package:mime/mime.dart';
import 'package:stronz_video_player/logic/resources/simple_http.dart' as http;

class ResourceManager {
    static Future<String> type(Uri uri) async {
        if (uri.scheme == "http" || uri.scheme == "https")
            return await http.mime(uri);

        return lookupMimeType(uri.toString()) ?? "unknown";
    }

    static Future<String> content(Uri uri) async {
        if (uri.scheme == "http" || uri.scheme == "https")
            return await http.get(uri);

        File file = File.fromUri(uri);
        return await file.readAsString();
    }
}