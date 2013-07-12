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

class LocalModelList<E> extends LocalModelObject implements rt.CollaborativeList <E> {

  E operator[](int index) => _list[index];

  void operator[]=(int index, E value) {
    if (index < 0 || index >= length) throw new RangeError.value(index);
    // get old value
    var oldValue = _list[index];

    // set actual value
    _list[index] = value;

    // add event to stream
    // TODO might still be worth checking for listener to save on these
    var event = new LocalValuesSetEvent._(index, [value], [oldValue], this);
    _emitChangedEvent([_onValuesSet], [event]);
  }

  List<E> asArray() => _list;

  void clear() {
    // clone list
    var list = new List.from(_list);
    _list.clear();
    // add event to stream
    var event = new LocalValuesRemovedEvent._(0,list, this);
    _emitChangedEvent([_onValuesRemoved], [event]);
  }

  void insert(int index, E value) {
    _list.insert(index, value);
    // add event to stream
    var event = new LocalValuesAddedEvent._(index, [value], this);
    _emitChangedEvent([_onValuesAdded],[event]);
  }

  void insertAll(int index, List<E> values) {
    _list.insertAll(index, values);
    // add event to stream
    // TODO clone values?
    var event = new LocalValuesAddedEvent._(index, values, this);
    _emitChangedEvent([_onValuesAdded], [event]);
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

  Stream<rt.ValuesAddedEvent> get onValuesAdded => _onValuesAdded.stream;

  Stream<rt.ValuesRemovedEvent> get onValuesRemoved => _onValuesRemoved.stream;

  Stream<rt.ValuesSetEvent> get onValuesSet => _onValuesSet.stream;

  int push(E value) {
    _list.add(value);
    // add event to stream
    // TODO make sure this is the index provided when inserting at the end
    var event = new LocalValuesAddedEvent._(_list.length - 1, [value], this);
    _emitChangedEvent([_onValuesAdded], [event]);
    return _list.length;
  }

  void pushAll(List<E> values) {
    _list.addAll(values);
    // add event to stream
    // TODO make sure this is the index provided when inserting at the end
    var event = new LocalValuesAddedEvent._(_list.length - values.length, values, this);
    _emitChangedEvent([_onValuesAdded], [event]);
  }

  IndexReference registerReference(int index, bool canBeDeleted) {
    // TODO implement this method
  }

  // TODO this is an actual conflict with the List interface and would make it harder to implement it
  void remove(int index) {
    var removed = _list.removeAt(index);
    // add event to stream
    var event = new LocalValuesRemovedEvent._(index, [removed], this);
    _emitChangedEvent([_onValuesRemoved], [event]);
  }

  void removeRange(int startIndex, int endIndex) {
    // get range to return it
    var removed = _list.sublist(startIndex, endIndex);
    // remove from list
    _list.removeRange(startIndex, endIndex);
    // add event to stream
    var event = new LocalValuesRemovedEvent._(startIndex, removed, this);
    _emitChangedEvent([_onValuesRemoved], [event]);
  }

  bool removeValue(E value) {
    // get index of value for event
    int index = _list.indexOf(value);
    // remove from list
    _list.remove(value);
    if(index != -1) {
      // add to stream
      var event = new LocalValuesRemovedEvent._(index, [value], this);
      _emitChangedEvent([_onValuesRemoved], [event]);
    }
  }

  void replaceRange(int index, List<E> values) {
    // get current values for event
    var current = _list.sublist(index, index + values.length);
    // replace values in list
    _list.replaceRange(index, index + values.length, values);
    // add event to stream
    // TODO clone values?
    var event = new LocalValuesSetEvent._(index, values, current, this);
    _emitChangedEvent([_onValuesSet],[event]);
  }

  // backing field
  final List _list = [];
  // stream controllers
  StreamController<rt.ValuesAddedEvent> _onValuesAdded
    = new StreamController<rt.ValuesAddedEvent>.broadcast(sync: true);
  StreamController<rt.ValuesRemovedEvent> _onValuesRemoved
    = new StreamController<rt.ValuesRemovedEvent>.broadcast(sync: true);
  StreamController<rt.ValuesSetEvent> _onValuesSet
    = new StreamController<rt.ValuesSetEvent>.broadcast(sync: true);

  // map from object ids of contained elements to subscriptions to their object changed streams
  Map<String, StreamSubscription<LocalObjectChangedEvent>> _ssMap =
    new Map<String, StreamSubscription<LocalObjectChangedEvent>>();
  // check if value is a model object and start propagating object changed events
  void _propagateChanges(dynamic element) {
    // start propagating changes if element is model object and not already subscribed
    // TODO do we do the same check in map?
    if(element is LocalModelObject && !_ssMap.containsKey((element as LocalModelObject).id)) {
      _ssMap[(element as LocalModelObject).id] =
        (element as LocalModelObject)._onPostObjectChanged.listen((e) {
          // fire on normal object changed stream
          _onObjectChanged.add(e);
          // fire on propogation stream
          _onPostObjectChangedController.add(e);
        });
    }
  }
  // check if value is a model object and stop propagating object changed events
  void _stopPropagatingChanges(dynamic element) {
    // stop propagation if overwritten element is model object and it is no longer anywhere in the list
    // TODO this depends on this method being called _after_ the element is removed from _list
    if(element is LocalModelObject && !_list.contains(element)) {
      _ssMap[(element as LocalModelObject).id].cancel();
      _ssMap.remove((element as LocalModelObject).id);
    }
  }

  LocalModelList([List initialValue]) {
    // initialize with values
    if(initialValue != null) {
      // don't fire events but do propagate changes
      _list.addAll(initialValue);
      initialValue.forEach((element) => _propagateChanges(element));
    }

    // listen for events to add or cancel object changed propagation
    onValuesAdded.listen((LocalValuesAddedEvent e) {
      e.values.forEach((element) => _propagateChanges(element));
    });
    onValuesRemoved.listen((LocalValuesRemovedEvent e){
      e.values.forEach((element) => _stopPropagatingChanges(element));
    });
    onValuesSet.listen((LocalValuesSetEvent e) {
      e.oldValues.forEach((element) => _stopPropagatingChanges(element));
      e.newValues.forEach((element) => _propagateChanges(element));
    });
  }

}