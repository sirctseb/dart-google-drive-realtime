// Copyright (c) 2013, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of realtime_data_model;

// TODO(aa) make this class mixin ListMixin
class CollaborativeList<E> extends CollaborativeContainer /* with ListMixin<E> */ {
  SubscribeStreamProvider<ValuesAddedEvent> _onValuesAdded;
  SubscribeStreamProvider<ValuesRemovedEvent> _onValuesRemoved;
  SubscribeStreamProvider<ValuesSetEvent> _onValuesSet;

  CollaborativeList._fromProxy(js.Proxy proxy) : super._fromProxy(proxy) {
    _onValuesAdded = _getStreamProviderFor(EventType.VALUES_ADDED, ValuesAddedEvent._cast);
    _onValuesRemoved = _getStreamProviderFor(EventType.VALUES_REMOVED, ValuesRemovedEvent._cast);
    _onValuesSet = _getStreamProviderFor(EventType.VALUES_SET, ValuesSetEvent._cast);
  }

  dynamic _toJs(E e) => _translator == null ? e : _translator.toJs(e);
  E _fromJs(dynamic value) => _translator == null ? value : _translator.fromJs(value);

  /*@override*/ int get length => $unsafe['length'];

  /*@override*/ E operator [](int index) {
    if (index < 0 || index >= this.length) throw new RangeError.value(index);
    return _fromJs($unsafe.get(index));
  }
  /*@override*/ void operator []=(int index, E value) {
    if (index < 0 || index >= this.length) throw new RangeError.value(index);
    $unsafe.set(index, _toJs(value));
  }

  void clear() { $unsafe.clear(); }
  /// Deprecated : use `xxx[index]` instead
  @deprecated E get(int index) => this[index];
  void insert(int index, E value) { $unsafe.insert(index, _toJs(value)); }
  int push(E value) => $unsafe.push(_toJs(value));
  IndexReference registerReference(int index, bool canBeDeleted) => new IndexReference._fromProxy($unsafe.registerReference(index, canBeDeleted));
  void remove(int index) { $unsafe.remove(index); }
  void removeRange(int startIndex, int endIndex) { $unsafe.removeRange(startIndex, endIndex); }
  bool removeValue(E value) => $unsafe.removeValue(_toJs(value));
  /// Deprecated : use `xxx[index] = value` instead
  @deprecated void set(int index, E value) { $unsafe.set(index, _toJs(value)); }

  List<E> asArray() => jsw.JsArrayToListAdapter.cast($unsafe.asArray(), _translator);
  int indexOf(E value, [Comparator comparator]) => $unsafe.indexOf(_toJs(value), comparator);
  void insertAll(int index, List<E> values) { $unsafe.insertAll(index, values is js.Serializable<js.Proxy> ? values : js.array(values.map(_toJs))); }
  int lastIndexOf(E value, [Comparator comparator]) => $unsafe.lastIndexOf(_toJs(value), comparator);
  void pushAll(List<E> values) { $unsafe.pushAll(values is js.Serializable<js.Proxy> ? values : js.array(values.map(_toJs))); }
  void replaceRange(int index, List<E> values) { $unsafe.replaceRange(index, values is js.Serializable<js.Proxy> ? values : js.array(values.map(_toJs))); }

  Stream<ValuesAddedEvent> get onValuesAdded => _onValuesAdded.stream;
  Stream<ValuesRemovedEvent> get onValuesRemoved => _onValuesRemoved.stream;
  Stream<ValuesSetEvent> get onValuesSet => _onValuesSet.stream;
}
