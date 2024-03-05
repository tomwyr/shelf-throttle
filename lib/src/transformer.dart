import 'dart:async';

import 'queue.dart';

/// A stream transformer that emits incoming events with at least a [window]
/// interval. If the incoming events are emitted with intervals greater than
/// [window], the original stream remains unaffected.
class ThrottleTransformer<T> implements StreamTransformer<T, T> {
  ThrottleTransformer(this.window);

  final Duration window;

  @override
  Stream<T> bind(Stream<T> stream) {
    late final StreamController<T> controller;
    final queue = IntervalQueue<T>(window, (value) => controller.add(value));
    controller = stream.intercept(
      onListen: (value) => queue.add(value),
      onDone: () => queue.dispose(),
    );
    return controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() => StreamTransformer.castFrom(this);
}

extension StreamThrottle<T> on Stream<T> {
  /// An operator that applies [ThrottleTransformer] to this stream.
  Stream<T> throttle(Duration window) => transform(ThrottleTransformer(window));
}

extension StreamIntercept<T> on Stream<T> {
  /// Creates a new stream controller and ties it to this stream by subscribing
  /// and unsubscribing this stream on the new controller's listen and cancel
  /// events.
  ///
  /// The above implies that events from this stream will only be emitted while
  /// the new controller's is listened to.
  ///
  /// The operator lets the calling code receive notifications about events
  /// emitted by stream, and decide if and how the events should be delivered
  /// to the new controller's stream.
  ///
  /// Returns created controller as the result.
  StreamController<T> intercept({
    void Function(T value)? onListen,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    late StreamSubscription subscription;
    final controller = StreamController<T>.broadcast(
      onListen: () {
        subscription = listen(
          onListen,
          onDone: onDone,
          onError: onError,
          cancelOnError: cancelOnError,
        );
      },
      onCancel: () => subscription.cancel(),
    );
    return controller;
  }
}
