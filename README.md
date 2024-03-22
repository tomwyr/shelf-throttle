# Shelf Throttle

[![pub package](https://img.shields.io/pub/v/shelf_throttle.svg)](https://pub.dev/packages/shelf_throttle)

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

## Installation

Add package dependency to your `pubspec.yaml` file:
```
dependencies:
  shelf_throttle: ^0.5.0
```

Get the package:
```
dart pub get
```

Alternatively, use Dart CLI to add and get the package:
```
dart pub add shelf_throttle
```

Use it in your pipeline:
```Dart
import 'package:shelf_throttle/shelf_throttle.dart';

const window = Duration(seconds: 5);
Pipeline().addMiddleware(throttle(window)).addHandler(handleRequest);
```
