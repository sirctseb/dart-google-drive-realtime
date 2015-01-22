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

typedef bool Comparator<T>(T a, T b);

class _LocalModelList<E> extends _LocalIndexReferenceContainer implements CollaborativeList<E> {

  E operator[](int index) {
    _LocalDocument._verifyDocument(this);
    return _list[index];
  }

  void operator[]=(int index, E value) {
    _LocalDocument._verifyDocument(this);
    if (index < 0 || index >= length) throw new RangeError.value(index);
    // add event to stream
    var event = new _LocalValuesSetEvent._(index, [value], [_list[index]], this);
    _emitEventsAndChanged([event]);
  }

  List<E> asArray() {
    _LocalDocument._verifyDocument(this);
    return _list;
  }

  void clear() {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesRemovedEvent._(0, _list.toList(), this);
    _emitEventsAndChanged([event]);
  }

  void insert(int index, E value) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesAddedEvent._(index, [value], this);
    _emitEventsAndChanged([event]);
  }

  void insertAll(int index, List<E> values) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesAddedEvent._(index, values, this);
    _emitEventsAndChanged([event]);
  }

  int lastIndexOf(E value, [Comparator comparator]) {
    _LocalDocument._verifyDocument(this);
    if(comparator != null) {
      for(var i = _list.length - 1; i >= 0; i--) {
        if(comparator(_list[i], value)) {
          return i;
        }
      }
    } else {
      return _list.lastIndexOf(value);
    }
    // for analyzer
    return -1;
  }

  /// Deprecated : use `xxx[index]` instead
  @deprecated E get(int index) {
    _LocalDocument._verifyDocument(this);
    return this[index];
  }

  int indexOf(E value, [Comparator comparator]) {
    _LocalDocument._verifyDocument(this);
    if(comparator != null) {
      for(var i = 0; i < _list.length; i++) {
        if(comparator(_list[i], value)) {
          return i;
        }
      }
    } else {
      return _list.indexOf(value);
    }
    return -1;
  }

  /// Deprecated : use `xxx[index] = value` instead
  @deprecated void set(int index, E value) {
    _LocalDocument._verifyDocument(this);
    this[index] = value;
  }

  int get length {
    _LocalDocument._verifyDocument(this);
    return _list.length;
  }
  set length(int l) {
    _LocalDocument._verifyDocument(this);
    if(l > this.length) {
      throw 'Cannot set the list length to be greater than the current value.';
    } else {
      this.removeRange(l, this.length);
    }
  }

  Stream<ValuesAddedEvent> get onValuesAdded => _onValuesAdded.stream;

  Stream<ValuesRemovedEvent> get onValuesRemoved => _onValuesRemoved.stream;

  Stream<ValuesSetEvent> get onValuesSet => _onValuesSet.stream;

  int push(E value) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesAddedEvent._(_list.length, [value], this);
    _emitEventsAndChanged([event]);
    return _list.length;
  }

  void pushAll(List<E> values) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesAddedEvent._(_list.length, values, this);
    _emitEventsAndChanged([event]);
  }

  // TODO this is an actual conflict with the List interface and would make it harder to implement it
  void remove(int index) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesRemovedEvent._(index, [_list[index]], this);
    _emitEventsAndChanged([event]);
  }

  void removeRange(int startIndex, int endIndex) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesRemovedEvent._(startIndex, _list.sublist(startIndex, endIndex), this);
    _emitEventsAndChanged([event]);
  }

  bool removeValue(E value) {
    _LocalDocument._verifyDocument(this);
    // get index of value for event
    int index = _list.indexOf(value);
    if(index != -1) {
      // add to stream
      var event = new _LocalValuesRemovedEvent._(index, [value], this);
      _emitEventsAndChanged([event]);
      return true;
    }
    return false;
  }

  void replaceRange(int index, List<E> values) {
    _LocalDocument._verifyDocument(this);
    // add event to stream
    var event = new _LocalValuesSetEvent._(index, values, _list.sublist(index, index + values.length), this);
    _emitEventsAndChanged([event]);
  }

  String toString() {
    _LocalDocument._verifyDocument(this);
    return _toStringHelper(new Set());
  }

  String _toStringHelper(Set ids) {
    _LocalDocument._verifyDocument(this);

    if(ids.contains(this.id)) {
      return '<List: ${this.id}>';
    }

    ids.add(this.id);

    return '[' +
    this._list.map((e) {
      if(e is _LocalModelObject || isCustomObject(e)) {
        return e._toStringHelper(ids);
      } else {
        return '[JsonValue ${json.stringify(e)}]';
      }
    }).join(', ') +
    ']';
  }

  // backing field
  final List _list = [];
  // stream controllers
  StreamController<ValuesAddedEvent> _onValuesAdded
    = new StreamController<ValuesAddedEvent>.broadcast(sync: true);
  StreamController<ValuesRemovedEvent> _onValuesRemoved
    = new StreamController<ValuesRemovedEvent>.broadcast(sync: true);
  StreamController<ValuesSetEvent> _onValuesSet
    = new StreamController<ValuesSetEvent>.broadcast(sync: true);

  // check if value is a model object and start propagating object changed events
  void _propagateChanges(dynamic element) {
    _LocalDocument._verifyDocument(this);
    // start propagating changes if element is model object and not already subscribed
    if(element is _LocalModelObject) {
      element.addParentEventTarget(this);
    }
  }
  // check if value is a model object and stop propagating object changed events
  void _stopPropagatingChanges(dynamic element) {
    _LocalDocument._verifyDocument(this);
    // stop propagation if overwritten element is model object and it is no longer anywhere in the list
    if(element is _LocalModelObject && !_list.contains(element)) {
      element.removeParentEventTarget(this);
    }
  }

  _LocalModelList(_LocalModel model, [List initialValue]) :
    super(model) {
    // initialize with values
    if(initialValue != null) {
      initializeWithValue(initialValue);
    }
    initializeEvents();
  }
  // TODO should be private
  void initializeEvents() {

    // listen for events to add or cancel object changed propagation
    onValuesAdded.listen((_LocalValuesAddedEvent e) {
      e.values.forEach((element) => _propagateChanges(element));
    });
    onValuesRemoved.listen((_LocalValuesRemovedEvent e){
      e.values.forEach((element) => _stopPropagatingChanges(element));
    });
    onValuesSet.listen((_LocalValuesSetEvent e) {
      e.oldValues.forEach((element) => _stopPropagatingChanges(element));
      e.newValues.forEach((element) => _propagateChanges(element));
    });

    _eventStreamControllers[EventType.VALUES_SET.value] = _onValuesSet;
    _eventStreamControllers[EventType.VALUES_ADDED.value] = _onValuesAdded;
    _eventStreamControllers[EventType.VALUES_REMOVED.value] = _onValuesRemoved;
  }
  // TODO should be private
  void initializeWithValue(List initialValue) {
    // don't fire events but do propagate changes
    _list.addAll(initialValue);
    initialValue.forEach((element) => _propagateChanges(element));
  }

  void _executeEvent(_LocalUndoableEvent event_in) {
    _LocalDocument._verifyDocument(this);
    if(event_in.type == EventType.VALUES_SET.value) {
        var event = event_in as _LocalValuesSetEvent;
        _list.setRange(event.index, event.index + event.newValues.length, event.newValues);
    } else if(event_in.type == EventType.VALUES_REMOVED.value) {
        var event = event_in as _LocalValuesRemovedEvent;
        // update list
        _list.removeRange(event.index, event.index + event.values.length);
        // update references
        _shiftReferencesOnDelete(event.index, event.values.length);
    } else if(event_in.type == EventType.VALUES_ADDED.value) {
        _LocalValuesAddedEvent event = event_in as _LocalValuesAddedEvent;
        // update list
        _list.insertAll(event.index, event.values);
        // update references
        _shiftReferencesOnInsert(event.index, event.values.length);
    } else {
      super._executeEvent(event_in);
    }
  }

  /// JSON serialized data
  Map _export(Set ids) {
    _LocalDocument._verifyDocument(this);

    return {
      "id": this.id,
      "type": "List",
      "value": _list.map((e) {
        if(e is _LocalModelObject) return e._export(ids);
        return {"json": e};
      }).toList()
    };
  }
}