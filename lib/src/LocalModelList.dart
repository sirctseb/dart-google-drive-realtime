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

class LocalModelList<E> extends ModelList<E> {
  
  E operator[](int index) => _list[index];

  void operator[]=(int index, E value) {
    // TODO value set event
    _list[index] = value;
  }

  List<E> asArray() => _list;

  void clear() {
    // TODO values removed event
    _list.clear();
  }

  void insert(int index, E value) {
    // TODO values added event
    _list.insert(index, value);
  }

  void insertAll(int index, List<E> values) {
    // TODO values added event
    _list.insertAll(index, values);
  }

  // TODO anything with comparator?
  int lastIndexOf(E value, [Comparator comparator]) {
    _list.lastIndexOf(value);
  }

  int get length => _list.length;

  Stream<rt.ValuesAddedEvent> get onValuesAdded => _onValuesAdded.stream;

  Stream<rt.ValuesRemovedEvent> get onValuesRemoved => _onValuesRemoved.stream;

  Stream<rt.ValuesSetEvent> get onValuesSet => _onValuesSet.stream;

  int push(E value) {
    // TODO values added event
    _list.add(value);
    return _list.length;
  }

  void pushAll(List<E> values) {
    // TODO values added event
    _list.addAll(values);
  }

  IndexReference registerReference(int index, bool canBeDeleted) {
    // TODO implement this method
  }

  // TODO this is an actual conflict with the List interface and would make it harder to implement it
  void remove(int index) {
    // TODO values removed event
    _list.removeAt(index);
  }

  void removeRange(int startIndex, int endIndex) {
    // TODO values removed event
    _list.removeRange(startIndex, endIndex);
  }

  bool removeValue(E value) {
    // TODO values removed event
    _list.remove(value);
  }

  void replaceRange(int index, List<E> values) {
    // TODO values set event
    _list.replaceRange(index, index + values.length, values);
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
}