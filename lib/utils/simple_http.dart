import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

Future<Response> _get(dynamic url, {Map<String, String>? headers, bool followRedirects = true, Duration? timeout, int maxRetries = 1}) async {
    assert(url is String || url is Uri);
    headers ??= {};
    if(!headers.containsKey("User-Agent"))
        headers["User-Agent"] = "Stronzflix";

    HttpClient client = HttpClient();
    client.connectionTimeout = timeout;

    for (int i = 0; i < maxRetries; i++) {
        try {
            Request req = Request("Get", url is Uri ? url : Uri.parse(url));
            req.headers.addAll(headers);
            req.followRedirects = followRedirects;

            IOClient ioClient = IOClient(client);
            StreamedResponse response = await ioClient.send(req);
            return Response.fromStream(response);
        } catch (e) {
            if (i == maxRetries - 1)
                rethrow;
        }
    }

    throw Exception("Failed to fetch resource after ${maxRetries} retries");
}

Future<Request> _head(dynamic url, {Map<String, String>? headers, bool followRedirects = true}) async {
    assert(url is String || url is Uri);
    headers ??= {};
    if(!headers.containsKey("User-Agent"))
        headers["User-Agent"] = "StronzVideoPlayer";

    Request req = Request("Head", url is Uri ? url : Uri.parse(url));
    req.headers.addAll(headers);
    req.followRedirects = followRedirects;
    return req;
}

Future<String> get(dynamic url, {Map<String, String>? headers, bool followRedirects = true, Duration? timeout, int maxRetries = 1}) async {
    return (await _get(url, headers: headers, followRedirects: followRedirects, timeout: timeout, maxRetries: maxRetries)).body;
}

Future<String> mime(dynamic url, {Map<String, String>? headers, bool followRedirects = true}) async {
    return (await _head(url, headers: headers, followRedirects: followRedirects)).send().then((response) => response.headers["content-type"] ?? "");
}
