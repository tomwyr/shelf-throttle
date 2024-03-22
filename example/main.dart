import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_throttle/shelf_throttle.dart';

void main() async {
  const message = 'Responding at most once each 5 seconds';
  final handler = throttle(Duration(seconds: 5)).addHandler((request) => Response.ok(message));
  await serve(handler, 'localhost', 8080);
}
