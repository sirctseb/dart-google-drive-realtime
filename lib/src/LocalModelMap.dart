// Copyright (c) 2013, Christopher Best
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

class LocalModelMap<V> extends LocalModelObject implements rt.CollaborativeMap<V> {
  // TODO add promotes back in here

  @override int get length => _map.length;

  @override V operator [](String key) => _map[key];
  // TODO event
  @override void operator []=(String key, V value) {
    // get the old value
    var oldValue = this[key];
    _map[key] = value;
    // send the event
    _onValueChanged.add(new LocalValueChangedEvent._(value, oldValue, key));
  }

  void clear() {
    // remove each key and let it produce the event
    keys.forEach((key) => remove(key));
  }
  // TODO event
  @override V remove(String key) {
    // create the event
    var event = new LocalValueChangedEvent._(null, _map[key], key);
    // do the remove
    _map.remove(key);
    // send the event
    _onValueChanged.add(event);
  }
  /// deprecated : use `xxx.remove(key)`
  @deprecated V delete(String key) => remove(key);
  /// deprecated : use `xxx[key]`
  @deprecated V get(String key) => this[key];
  @override bool containsKey(String key) => _map.containsKey(key);
  /// deprecated : use `xxx.containsKey(key)`
  @deprecated bool has(String key) => containsKey(key);
  @override bool get isEmpty => _map.isEmpty;
  // TODO figure out what type to return
  List<List<V>> get items => _map.keys.map((key) => [key, _map[key]]).toList();
  // TODO return TypePromotingList object
  @override List<String> get keys => _map.keys.toList();
  /// deprecated : use `xxx[key] = value`
  @deprecated V set(String key, V value) {
    this[key] = value;
    return value;
  }
  // TODO return TypePromotingList object
  @override List<V> get values => _map.values;
  @override bool get isNotEmpty => !isEmpty;

  Stream<rt.ValueChangedEvent> get onValueChanged => _onValueChanged.stream;

  // backing map instance
  Map<String, V> _map = new Map<String, V>();
  // stream controller
  // TODO should be use a subscribestreamprovider? I don't think we need to
  // TODO we are using a broadcast stream so that new listeners don't get back events. is this the correct approach?
  StreamController<rt.ValueChangedEvent> _onValueChanged = new StreamController<rt.ValueChangedEvent>.broadcast(sync: true);

  void addAll(Map<String, V> other) {
    other.forEach((key,val) => this[key] = val);
  }

  bool containsValue(V value) => Maps.containsValue(this, value);

  void forEach(void f(String key, V value)) => Maps.forEach(this, f);

  V putIfAbsent(String key, V ifAbsent()) => Maps.putIfAbsent(this, key, ifAbsent);

  int get size => length;

  LocalModelMap() {
    // create object changed event from value changed events
    // TODO buffer multiple changes into single object changed in clear and addAll?
    // TODO see if realtime does it
    onValueChanged.transform(_toObjectEvent)
      .listen((e) => _onObjectChanged.add(e));
  }
}