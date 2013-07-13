// Copyright (c) 2013, Alexandre Ardhuin
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

class LocalValuesSetEvent extends LocalUndoableEvent implements rt.ValuesSetEvent {

  bool get bubbles => null; // TODO implement this getter

  final int index;

  final List newValues;

  final List oldValues;

  final String type = ModelEventType.VALUES_SET.value;

  LocalValuesSetEvent._(this.index, this.newValues, this.oldValues, _target) : super._(_target);

  LocalValuesSetEvent get inverse => new LocalValuesSetEvent._(index, oldValues, newValues, _target);
}