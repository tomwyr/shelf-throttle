import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:shelf_throttle/src/transformer.dart';
import 'package:test/test.dart';
import 'package:time/time.dart';

import 'common.dart';

void main() {
  group('ThrottleTransformer', () {
    StreamSubscription<int>? subscription;

    tearDown(() {
      subscription?.cancel();
    });

    StreamController<int> listen(
      Duration minTime,
      void Function(int value) onData,
    ) {
      final controller = StreamController<int>();
      subscription = controller.stream.throttle(minTime).listen(onData);
      return controller;
    }

    testAsync(
      'emits multiple events added at irregular intervals after expected amount of time passes',
      (async) {
        final onData = MockCallback();
        final controller = listen(1.seconds, onData.call);

        Iterable<int>.generate(4).forEach(controller.add);
        async.flushMicrotasks();
        verify(() => onData(any())).called(1);

        // 2.0s
        async.elapse(2.seconds);
        verify(() => onData(any())).called(2);
        Iterable<int>.generate(3).forEach(controller.add);

        // 5.0s
        async.elapse(3.seconds);
        verify(() => onData(any())).called(3);
        Iterable<int>.generate(3).forEach(controller.add);

        // 8.9s
        async.elapse(3.9.seconds);
        verify(() => onData(any())).called(3);

        // 9.1s
        async.elapse(0.2.seconds);
        verify(() => onData(any())).called(1);
      },
    );
  });
}
