import 'dart:async';

import 'package:shelf/shelf.dart';

import 'transformer.dart';

/// Delays each request at least [window] from the previously received request.
///
/// If time since the last request is greater than [window], the current request
/// will be processed immediately.
/// If time since the last request is less than [window], the current request
/// will be delayed until that time is equal to [window].
///
/// If there's more requests in the queue awaiting their turn, the actual delay
/// calculation will be relative to the last request in the queue.
/// The effective delay will be equal to the time it takes for the last request
/// in the queue to be resumed + [window].
Middleware throttle(Duration window) {
  final controller = StreamController<Request>.broadcast();
  final stream = controller.stream.throttle(window);

  return (innerHandler) {
    return (request) async {
      final resumeEvent =
          stream.firstWhere((resumedRequest) => resumedRequest == request);
      controller.add(request);
      await resumeEvent;
      return innerHandler(request);
    };
  };
}
