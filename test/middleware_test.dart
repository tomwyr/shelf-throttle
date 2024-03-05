import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_throttle/shelf_throttle.dart';
import 'package:test/test.dart';
import 'package:time/time.dart';

import 'common.dart';

void main() {
  group('throttle', () {
    late Handler request;
    late Handler respond;

    setUpAll(() {
      final uri = Uri(scheme: 'scheme', path: '/path');
      registerFallbackValue(Request('method', uri));
    });

    setUp(() {
      respond = MockHandler().call;
      request = throttle(1.seconds).addHandler(respond);
    });

    testAsync(
      'responds to multiple requests sent at irregular intervals after expected amount of time passes',
      (async) {
        sendRequest(int index) {
          when(() => respond(any())).thenAnswer((_) async => MockResponse());
          request(MockRequest());
        }

        Iterable<int>.generate(4).forEach(sendRequest);
        async.flushMicrotasks();
        verify(() => respond(any())).called(1);

        // 2.0s
        async.elapse(2.seconds);
        verify(() => respond(any())).called(2);
        Iterable<int>.generate(3).forEach(sendRequest);

        // 5.0s
        async.elapse(3.seconds);
        verify(() => respond(any())).called(3);
        Iterable<int>.generate(3).forEach(sendRequest);

        // 8.9s
        async.elapse(3.9.seconds);
        verify(() => respond(any())).called(3);

        // 9.1s
        async.elapse(12.2.seconds);
        async.flushMicrotasks();
        verify(() => respond(any())).called(1);
      },
    );
  });
}

class MockHandler extends Mock {
  FutureOr<Response> call(Request request);
}

class MockRequest extends Mock implements Request {}

class MockResponse extends Mock implements Response {}
