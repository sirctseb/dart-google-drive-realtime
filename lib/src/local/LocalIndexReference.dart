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

// TODO why does this extend LocalModelObject? Why does IndexReferences extend CollaborativeObject?
class _LocalIndexReference extends _LocalModelObject implements IndexReference {

  final bool canBeDeleted;

  int index;

  Stream<_LocalReferenceShiftedEvent> get onReferenceShifted => _onReferenceShifted.stream;

  final CollaborativeObject referencedObject;

  // TODO js api shows model as param to constructor
  _LocalIndexReference._(this.index, this.canBeDeleted, this.referencedObject, _LocalModel model) :
    super(model);

  StreamController<_LocalReferenceShiftedEvent> _onReferenceShifted
    = new StreamController<_LocalReferenceShiftedEvent>.broadcast(sync: true);

  // update index and send event for a shift
  void _shift(int newIndex) {
    int oldIndex = index;
    index = newIndex;
    _onReferenceShifted.add(new _LocalReferenceShiftedEvent._(index, oldIndex, this));
  }
}