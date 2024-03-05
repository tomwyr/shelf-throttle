import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_throttle/shelf_throttle.dart';

void main() async {
  final handler = throttle(Duration(seconds: 5)).addHandler(handleRequest);
  await serve(handler, 'localhost', 8080);
}

Future<Response> handleRequest(Request request) async {
  return switch ((request.method, request.url.path)) {
    ('GET', 'hello') => Response.ok('hi'),
    ('GET', 'world') => Response.ok('planet'),
    _ => Response.notFound('Not found')
  };
}
