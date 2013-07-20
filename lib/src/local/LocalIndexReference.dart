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

part of local_realtime_data_model;

class LocalIndexReference extends LocalModelObject implements rt.IndexReference {

  final bool canBeDeleted;

  int index;

  Stream<LocalReferenceShiftedEvent> get onReferenceShifted => _onReferenceShifted.stream;

  final rt.CollaborativeObject referencedObject;

  // TODO js api shows model as param to constructor
  LocalIndexReference._(this.index, this.canBeDeleted, this.referencedObject);

  StreamController<LocalReferenceShiftedEvent> _onReferenceShifted
    = new StreamController<LocalReferenceShiftedEvent>.broadcast(sync: true);

  // update index and send event for a shift
  void _shift(int newIndex) {
    int oldIndex = index;
    index = newIndex;
    _onReferenceShifted.add(new LocalReferenceShiftedEvent._(index, oldIndex, referencedObject));
  }
}