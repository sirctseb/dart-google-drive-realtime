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

class _LocalModelList<E> extends _LocalIndexReferenceContainer implements CollaborativeList<E> {

  E operator[](int index) => _list[index];

  void operator[]=(int index, E value) {
    if (index < 0 || index >= length) throw new RangeError.value(index);
    // add event to stream
    var event = new _LocalValuesSetEvent._(index, [value], [_list[index]], this);
    _emitEventsAndChanged([event]);
  }

  List<E> asArray() => _list;

  void clear() {
    // add event to stream
    var event = new _LocalValuesRemovedEvent._(0, _list.toList(), this);
    _emitEventsAndChanged([event]);
  }

  void insert(int index, E value) {
    // add event to stream
    var event = new _LocalValuesAddedEvent._(index, [value], this);
    _emitEventsAndChanged([event]);
  }

  void insertAll(int index, List<E> values) {
    // add event to stream
    // TODO clone values?
    var event = new _LocalValuesAddedEvent._(index, values, this);
    _emitEventsAndChanged([event]);
  }

  // TODO anything with comparator?
  int lastIndexOf(E value, [Comparator comparator]) {
    _list.lastIndexOf(value);
  }

  /// Deprecated : use `xxx[index]` instead
  @deprecated E get(int index) => this[index];

  int indexOf(E value, [Comparator comparator]) {
    return _list.indexOf(value);
  }

  /// Deprecated : use `xxx[index] = value` instead
  @deprecated void set(int index, E value) { this[index] = value; }

  int get length => _list.length;

  Stream<ValuesAddedEvent> get onValuesAdded => _onValuesAdded.stream;

  Stream<ValuesRemovedEvent> get onValuesRemoved => _onValuesRemoved.stream;

  Stream<ValuesSetEvent> get onValuesSet => _onValuesSet.stream;

  int push(E value) {
    // add event to stream
    // TODO make sure this is the index provided when inserting at the end
    var event = new _LocalValuesAddedEvent._(_list.length, [value], this);
    _emitEventsAndChanged([event]);
    return _list.length;
  }

  void pushAll(List<E> values) {
    // add event to stream
    // TODO make sure this is the index provided when inserting at the end
    var event = new _LocalValuesAddedEvent._(_list.length, values, this);
    _emitEventsAndChanged([event]);
  }

  // TODO this is an actual conflict with the List interface and would make it harder to implement it
  void remove(int index) {
    // add event to stream
    var event = new _LocalValuesRemovedEvent._(index, [_list[index]], this);
    _emitEventsAndChanged([event]);
  }

  void removeRange(int startIndex, int endIndex) {
    // add event to stream
    var event = new _LocalValuesRemovedEvent._(startIndex, _list.sublist(startIndex, endIndex), this);
    _emitEventsAndChanged([event]);
  }

  bool removeValue(E value) {
    // get index of value for event
    int index = _list.indexOf(value);
    if(index != -1) {
      // add to stream
      var event = new _LocalValuesRemovedEvent._(index, [value], this);
      _emitEventsAndChanged([event]);
    }
  }

  void replaceRange(int index, List<E> values) {
    // add event to stream
    // TODO clone values?
    var event = new _LocalValuesSetEvent._(index, values, _list.sublist(index, index + values.length), this);
    _emitEventsAndChanged([event]);
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
    // start propagating changes if element is model object and not already subscribed
    // TODO do we do the same check in map?
    if(element is _LocalModelObject) {
      element.addParentEventTarget(this);
    }
  }
  // check if value is a model object and stop propagating object changed events
  void _stopPropagatingChanges(dynamic element) {
    // stop propagation if overwritten element is model object and it is no longer anywhere in the list
    if(element is _LocalModelObject && !_list.contains(element)) {
      element.removeParentEventTarget(this);
    }
  }

  _LocalModelList([List initialValue]) {
    // initialize with values
    if(initialValue != null) {
      initializeWithValue(initialValue);
    }
    initializeEvents();
  }
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
  void initializeWithValue(List initialValue) {
    // don't fire events but do propagate changes
    _list.addAll(initialValue);
    initialValue.forEach((element) => _propagateChanges(element));
  }

  // TODO we could alternatively listen for our own events and do the modifications there
  void _executeEvent(_LocalUndoableEvent event_in) {
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
  Map toJSON() {
    return {
      "id": this.id,
      "type": "List",
      "value": _list.map((e) {
        if(e is _LocalModelObject) return e.toJSON();
        return {"json": e};
      }).toList()
    };
  }
}