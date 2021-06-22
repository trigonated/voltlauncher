/// Extensions for the [Iterable] class.
extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => (this.isNotEmpty) ? this.first : null;

  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  Iterable<T> mapNotNull<T>(T? f(E e)) {
    return this.map(f).where((e) => e != null).map((e) => e!);
  }

  Future<Iterable<T>> mapAsync<T>(Future<T> f(E e)) async {
    return Future.wait(this.map((i) async => await f(i)));
  }
}
