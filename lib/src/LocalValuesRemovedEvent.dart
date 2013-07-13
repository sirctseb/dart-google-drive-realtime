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

class LocalValuesRemovedEvent extends LocalUndoableEvent implements rt.ValuesRemovedEvent {
  bool get bubbles => null; // TODO implement this getter

  final int index;

  final String type = ModelEventType.VALUES_REMOVED.value;

  final List values;

  LocalValuesRemovedEvent._(this.index, this.values, _target) : super._(_target);

  LocalValuesAddedEvent get inverse => new LocalValuesAddedEvent._(index, values, _target);
}
