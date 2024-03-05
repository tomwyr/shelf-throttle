import 'package:mocktail/mocktail.dart';
import 'package:shelf_throttle/src/queue.dart';
import 'package:test/test.dart';
import 'package:time/time.dart';

import 'common.dart';

void main() {
  group('IntervalQueue', () {
    testAsync('removes element with no delay when the queue is empty', (async) {
      final onRemove = MockCallback();
      final queue = IntervalQueue(1.seconds, onRemove.call);

      queue.add(1);

      verify(() => onRemove(1));
    });

    testAsync(
      'removes next element after interval when elements are added at the same time',
      (async) {
        final onRemove = MockCallback();
        final queue = IntervalQueue(1.seconds, onRemove.call);

        queue.add(1);
        queue.add(2);

        // 0.9s
        async.elapse(0.9.seconds);
        verifyNever(() => onRemove(2));

        // 1.1s
        async.elapse(0.2.seconds);
        verify(() => onRemove(2));
      },
    );

    testAsync(
      'removes next element after remaining part of interval when next element is added with a delay less than interval',
      (async) {
        final onRemove = MockCallback();
        final queue = IntervalQueue(1.seconds, onRemove.call);

        queue.add(1);
        // 0.5s
        async.elapse(0.5.seconds);
        queue.add(2);

        // 0.9s
        async.elapse(0.4.seconds);
        verifyNever(() => onRemove(2));

        // 1.1s
        async.elapse(0.2.seconds);
        verify(() => onRemove(2));
      },
    );

    testAsync(
      'removes next element with no delay when next element is added with a delay greater than interval',
      (async) {
        final onRemove = MockCallback();
        final queue = IntervalQueue(1.seconds, onRemove.call);

        queue.add(1);
        // 1.5s
        async.elapse(1.5.seconds);
        queue.add(2);

        verify(() => onRemove(2));
      },
    );

    testAsync(
      'removes multiple elements added simultaneously after expected amount of time passes',
      (async) {
        final onRemove = MockCallback();
        final queue = IntervalQueue(1.seconds, onRemove.call);

        Iterable<int>.generate(10).forEach(queue.add);

        // 8.9s
        async.elapse(8.9.seconds);
        verify(() => onRemove(any())).called(9);

        // 9.1s
        async.elapse(0.2.seconds);
        verify(() => onRemove(any())).called(1);
      },
    );

    testAsync(
      'removes multiple elements added at irregular intervals after expected amount of time passes',
      (async) {
        final onRemove = MockCallback();
        final queue = IntervalQueue(1.seconds, onRemove.call);

        Iterable<int>.generate(4).forEach(queue.add);

        // 2.0s
        async.elapse(2.seconds);
        Iterable<int>.generate(3).forEach(queue.add);

        // 5.0s
        async.elapse(3.seconds);
        Iterable<int>.generate(3).forEach(queue.add);

        // 8.9s
        async.elapse(3.9.seconds);
        verify(() => onRemove(any())).called(9);

        // 9.1s
        async.elapse(0.2.seconds);
        verify(() => onRemove(any())).called(1);
      },
    );

    test('throws when element is added after disposing the queue', () {
      final queue = IntervalQueue(1.seconds, (element) {});

      queue.dispose();

      expect(() => queue.add(1), throwsA(isA<AddAfterDisposedError>()));
    });
  });
}
