# Shelf Throttle

A [Shelf](https://github.com/dart-lang/shelf/tree/master) middleware that applies global throttling to all incoming requests with a given time window.

```Dart
// Server
// Handle requests with a 5 seconds window.
final handler = throttle(Duration(seconds: 5)).addHandler(handleRequest);
await serve(handler, host, port);

// Client
// Handled with no delay.
get('$baseUrl/hello');
// Wait for 3 seconds of the 5 seconds window.
await Future.delayed(Duration(seconds: 3));
// Handled after another 2 seconds.
get('$baseUrl/world');
```
