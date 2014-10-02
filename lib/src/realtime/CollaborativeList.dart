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

  CollaborativeList._fromProxy(js.JsObject proxy) : super._fromProxy(proxy) {
    _onValuesAdded = _getStreamProviderFor(EventType.VALUES_ADDED, ValuesAddedEvent._cast);
    _onValuesRemoved = _getStreamProviderFor(EventType.VALUES_REMOVED, ValuesRemovedEvent._cast);
    _onValuesSet = _getStreamProviderFor(EventType.VALUES_SET, ValuesSetEvent._cast);
  }

  dynamic _toJs(E e) => _translator == null ? e : _translator.toJs(e);
  E _fromJs(dynamic value) => _translator == null ? value : _translator.fromJs(value);

  /*@override*/ int get length => $unsafe['length'];
  set length(int l) {
    $unsafe['length'] = l;
  }

  /*@override*/ E operator [](int index) {
    if (index < 0 || index >= this.length) throw new RangeError.value(index);
    return _fromJs($unsafe.callMethod('get', [index]));
  }
  /*@override*/ void operator []=(int index, E value) {
    if (index < 0 || index >= this.length) throw new RangeError.value(index);
    $unsafe.callMethod('set', [index, _toJs(value)]);
  }

  void clear() { $unsafe.callMethod('clear'); }
  /// Deprecated : use `xxx[index]` instead
  @deprecated E get(int index) => this[index];
  void insert(int index, E value) { $unsafe.callMethod('insert', [index, _toJs(value)]); }
  int push(E value) => $unsafe.callMethod('push', [_toJs(value)]);
  IndexReference registerReference(int index, bool canBeDeleted) => new IndexReference._fromProxy($unsafe.callMethod('registerReference', [index, canBeDeleted]));
  void remove(int index) { $unsafe.callMethod('remove', [index]); }
  void removeRange(int startIndex, int endIndex) { $unsafe.callMethod('removeRange', [startIndex, endIndex]); }
  bool removeValue(E value) => $unsafe.callMethod('removeValue', [_toJs(value)]);
  /// Deprecated : use `xxx[index] = value` instead
  @deprecated void set(int index, E value) { $unsafe.callMethod('set', [index, _toJs(value)]); }

  List<E> asArray() => TranslateCollaborativeListToArray($unsafe.callMethod('asArray'));
  int indexOf(E value, [Comparator comparator]) => $unsafe.callMethod('indexOf', [_toJs(value), comparator]);
  // TODO do we really have to check if these arrays are already JsArrays?
  void insertAll(int index, List<E> values) { $unsafe.callMethod('insertAll', [index, values is js.JsArray ? values : new js.JsArray.from(values.map(_toJs))]); }
  int lastIndexOf(E value, [Comparator comparator]) => $unsafe.callMethod('lastIndexOf',[_toJs(value), comparator]);
  void pushAll(List<E> values) { $unsafe.callMethod('pushAll', [values is js.JsArray ? values : new js.JsArray.from(values.map(_toJs))]); }
  void replaceRange(int index, List<E> values) { $unsafe.callMethod('replaceRange', [index, values is js.JsArray ? values : new js.JsArray.from(values.map(_toJs))]); }

  Stream<ValuesAddedEvent> get onValuesAdded => _onValuesAdded.stream;
  Stream<ValuesRemovedEvent> get onValuesRemoved => _onValuesRemoved.stream;
  Stream<ValuesSetEvent> get onValuesSet => _onValuesSet.stream;
}
