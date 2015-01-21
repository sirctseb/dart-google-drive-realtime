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

class _LocalModelMap<V> extends _LocalModelObject implements CollaborativeMap<V> {

  @override int get length {
    _LocalDocument._verifyDocument(this);
    return _map.length;
  }

  @override V operator [](String key) {
    _LocalDocument._verifyDocument(this);
    return _map[key];
  }
  @override void operator []=(String key, V value) {
    _LocalDocument._verifyDocument(this);
    if(this[key] != value) {
      // send the event
      var event = new _LocalValueChangedEvent._(value, _map[key], key, this);
      _emitEventsAndChanged([event]);
    }
  }

  void clear() {
    _LocalDocument._verifyDocument(this);
    // remove each key and let it produce the event
    keys.forEach((key) => remove(key));
  }

  @override V remove(String key) {
    _LocalDocument._verifyDocument(this);
    var oldValue = this[key];
    // create the event
    var event = new _LocalValueChangedEvent._(null, _map[key], key, this);
    // send the event
    _emitEventsAndChanged([event]);
    return oldValue;
  }
  /// deprecated : use `xxx.remove(key)`
  @deprecated V delete(String key) => remove(key);
  /// deprecated : use `xxx[key]`
  @deprecated V get(String key) => this[key];
  @override bool containsKey(String key) {
    _LocalDocument._verifyDocument(this);
    return _map.containsKey(key);
  }
  /// deprecated : use `xxx.containsKey(key)`
  @deprecated bool has(String key) => containsKey(key);
  @override bool get isEmpty {
    _LocalDocument._verifyDocument(this);
    return _map.isEmpty;
  }
  List<List<V>> get items {
    _LocalDocument._verifyDocument(this);
    return _map.keys.map((key) => [key, _map[key]]).toList();
  }
  @override List<String> get keys {
    _LocalDocument._verifyDocument(this);
    return _map.keys.toList();
  }
  /// deprecated : use `xxx[key] = value`
  @deprecated V set(String key, V value) {
    _LocalDocument._verifyDocument(this);
    var oldValue = this[key];
    this[key] = value;
    return oldValue;
  }
  @override List<V> get values {
    _LocalDocument._verifyDocument(this);
    return _map.values;
  }
  @override bool get isNotEmpty => !isEmpty;

  Stream<ValueChangedEvent> get onValueChanged => _onValueChanged.stream;

  // backing map instance
  Map<String, V> _map = new Map<String, V>();
  // stream controller
  // TODO should be use a subscribestreamprovider? I don't think we need to
  StreamController<ValueChangedEvent> _onValueChanged = new StreamController<ValueChangedEvent>.broadcast(sync: true);

  void addAll(Map<String, V> other) {
    other.forEach((key,val) => this[key] = val);
  }

  bool containsValue(V value) => Maps.containsValue(this, value);

  void forEach(void f(String key, V value)) => Maps.forEach(this, f);

  V putIfAbsent(String key, V ifAbsent()) => Maps.putIfAbsent(this, key, ifAbsent);

  int get size => length;

  String toString() {
    _LocalDocument._verifyDocument(this);
    var valList = _map.keys.map((key) {
      return '$key: ' +
          (_map[key] is _LocalModelObject ?
          _map[key].toString() :
          '[JsonValue ${json.stringify(_map[key])}]');
    });
    return '{${valList.join(", ")}}';
  }

  _LocalModelMap(_LocalModel model, [Map initialValue]) :
    super(model) {
    // initialize with value
    if(initialValue != null) {
      initializeWithValue(initialValue);
    }

    _eventStreamControllers[EventType.VALUE_CHANGED.value] = _onValueChanged;
  }
  void initializeWithValue(Map initialValue) {
    // don't emit events, but do propagate changes
    _map.addAll(initialValue);
    _map.forEach((key,value) {
      if(value is _LocalModelObject) {
        value.addParentEventTarget(this);
      }
    });
  }

  void _executeEvent(_LocalUndoableEvent event_in) {
    _LocalDocument._verifyDocument(this);
    if(event_in.type == EventType.VALUE_CHANGED.value) {
        var event = event_in as _LocalValueChangedEvent;
        if(event.newValue == null) {
          _map.remove(event.property);
        } else {
          _map[event.property] = event.newValue;
        }
        // stop propagating changes if we're writing over a model object
        if(event.oldValue is _LocalModelObject && !_map.values.contains(event.oldValue)) {
          event.oldValue.removeParentEventTarget(this);
        }
        // propagate changes on model data objects
        if(event.newValue is _LocalModelObject) {
          event.newValue.addParentEventTarget(this);
        }
    } else {
        super._executeEvent(event_in);
    }
  }

  /// JSON serialized data
  // TODO output numbers as floating point
  Map toJSON() {
    return {
      "id": this.id,
      "type": "Map",
      "value": new Map.fromIterable(_map.keys, value: (key) {
        if(_map[key] is _LocalModelObject) return _map[key].toJSON();
        return {"json": _map[key]};
      })
    };
  }
}