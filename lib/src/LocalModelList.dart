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
    _list[index] = value;
    // add event to stream
    // TODO might still be worth checking for listener to save on these
    _onValuesSet.add(new LocalValuesSetEvent._(index, [value], [oldValue]));
  }

  List<E> asArray() => _list;

  void clear() {
    // clone list
    var list = new List.from(_list);
    _list.clear();
    // add event to stream
    _onValuesRemoved.add(new LocalValuesRemovedEvent._(0,list));
  }

  void insert(int index, E value) {
    _list.insert(index, value);
    // add event to stream
    _onValuesAdded.add(new LocalValuesAddedEvent._(index, [value]));
  }

  void insertAll(int index, List<E> values) {
    _list.insertAll(index, values);
    // add event to stream
    // TODO clone values?
    _onValuesAdded.add(new LocalValuesAddedEvent._(index, values));
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
    _onValuesAdded.add(new LocalValuesAddedEvent._(_list.length - 1, [value]));
    return _list.length;
  }

  void pushAll(List<E> values) {
    _list.addAll(values);
    // add event to stream
    // TODO make sure this is the index provided when inserting at the end
    _onValuesAdded.add(new LocalValuesAddedEvent._(_list.length - values.length, values));
  }

  IndexReference registerReference(int index, bool canBeDeleted) {
    // TODO implement this method
  }

  // TODO this is an actual conflict with the List interface and would make it harder to implement it
  void remove(int index) {
    var removed = _list.removeAt(index);
    // add event to stream
    _onValuesRemoved.add(new LocalValuesRemovedEvent._(index, [removed]));
  }

  void removeRange(int startIndex, int endIndex) {
    // get range to return it
    var removed = _list.sublist(startIndex, endIndex);
    // remove from list
    _list.removeRange(startIndex, endIndex);
    // add event to stream
    _onValuesRemoved.add(new LocalValuesRemovedEvent._(startIndex, removed));
  }

  bool removeValue(E value) {
    // get index of value for event
    int index = _list.indexOf(value);
    // remove from list
    _list.remove(value);
    if(index != -1) {
      // add to stream
      _onValuesRemoved.add(new LocalValuesRemovedEvent._(index, [value]));
    }
  }

  void replaceRange(int index, List<E> values) {
    // get current values for event
    var current = _list.sublist(index, index + values.length);
    // replace values in list
    _list.replaceRange(index, index + values.length, values);
    // add event to stream
    // TODO clone values?
    _onValuesSet.add(new LocalValuesSetEvent._(index, values, current));
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

  LocalModelList() {
    // TODO pipe to _onObjectChanged when https://code.google.com/p/dart/issues/detail?id=10677 is fixed
    onValuesAdded.transform(_toObjectEvent)
      .listen((e) => _onObjectChanged.add(e));
    onValuesRemoved.transform(_toObjectEvent)
      .listen((e) => _onObjectChanged.add(e));
    onValuesSet.transform(_toObjectEvent)
      .listen((e) => _onObjectChanged.add(e));
  }

}