import 'dart:collection';

/// A queue that removes first item in the queue every [interval] and notifies
/// the listener about each element removed via the [onRemove] callback.
///
/// Removal of the next element is scheduled when first element is added to the
/// queue and after each consecutive removal.
/// If the are no more elements in the queue and a new element is added, the
/// [interval] is counted from the moment of adding that new element.
class IntervalQueue<E> {
  IntervalQueue(this.interval, this.onRemove);

  final Duration interval;
  final void Function(E element) onRemove;

  final _queue = Queue<E>();

  var _pendingRemoval = false;
  var _disposed = false;

  void add(E element) {
    if (_disposed) {
      throw AddAfterDisposedError();
    }
    _queue.add(element);
    if (!_pendingRemoval) {
      _removeNext();
    }
  }

  void dispose() {
    _disposed = true;
  }

  void _removeNextAfterInterval() async {
    _pendingRemoval = true;
    await Future.delayed(interval);
    _pendingRemoval = false;
    if (!_disposed && _queue.isNotEmpty) {
      _removeNext();
    }
  }

  void _removeNext() {
    if (_queue.isEmpty) {
      throw RemovalOnEmptyError();
    }
    onRemove(_queue.removeFirst());
    _removeNextAfterInterval();
  }
}

class AddAfterDisposedError extends Error {
  @override
  String toString() {
    return 'Element cannot be added to an interval queue after it has been disposed';
  }
}

class RemovalOnEmptyError extends Error {
  @override
  String toString() {
    return 'Element cannot be removed from an interval queue that is empty';
  }
}
