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

class CollaborativeMap<V> extends CollaborativeContainer implements Map<String, V> {
  SubscribeStreamProvider<ValueChangedEvent> _onValueChanged;

  CollaborativeMap._fromProxy(js.Proxy proxy)
      : super._fromProxy(proxy) {
    _onValueChanged = _getStreamProviderFor(EventType.VALUE_CHANGED, ValueChangedEvent._cast);
  }

  dynamic _toJs(V e) => _translator == null ? e : _translator.toJs(e);
  V _fromJs(dynamic value) => _translator == null ? value :
      _translator.fromJs(value);

  @override int get length => $unsafe['size'];
  /// deprecated : use `xxx.length`
  @deprecated int get size => length;

  @override V operator [](String key) => _fromJs($unsafe.get(key));
  @override void operator []=(String key, V value) {
    $unsafe.set(key, _toJs(value));
  }

  void clear() { $unsafe.clear(); }
  @override V remove(String key) => _fromJs($unsafe.delete(key));
  /// deprecated : use `xxx.remove(key)`
  @deprecated V delete(String key) => remove(key);
  /// deprecated : use `xxx[key]`
  @deprecated V get(String key) => this[key];
  @override bool containsKey(String key) => $unsafe.has(key);
  /// deprecated : use `xxx.containsKey(key)`
  @deprecated bool has(String key) => containsKey(key);
  @override bool get isEmpty => $unsafe.isEmpty();
  List<List<V>> get items => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe.items(), (e) => jsw.JsArrayToListAdapter.cast(e, _translator));
  @override List<String> get keys => jsw.JsArrayToListAdapter.cast($unsafe.keys());
  /// deprecated : use `xxx[key] = value`
  @deprecated V set(String key, V value) => _fromJs($unsafe.set(key, _toJs(value)));
  @override List<V> get values => jsw.JsArrayToListAdapter.cast($unsafe.values(), _translator);
  @override bool get isNotEmpty => !isEmpty;

  // use Maps to implement functions
  @override bool containsValue(V value) => Maps.containsValue(this, value);
  @override V putIfAbsent(String key, V ifAbsent()) => Maps.putIfAbsent(this, key, ifAbsent);
  @override void forEach(void f(String key, V value)) => Maps.forEach(this, f);

  Stream<ValueChangedEvent> get onValueChanged => _onValueChanged.stream;

  void addAll(Map<String, V> other) {
    other.forEach((key, value) => this[key] = value);
  }
}
