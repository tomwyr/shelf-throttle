import 'package:fake_async/fake_async.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

@isTest
void testAsync(Object? description, dynamic Function(FakeAsync async) body) {
  test(description, () => fakeAsync(body));
}

class MockCallback<E> extends Mock {
  void call(E element);
}
