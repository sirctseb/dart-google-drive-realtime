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

class _LocalValuesSetEvent extends _LocalUndoableEvent implements ValuesSetEvent {

  bool get bubbles => null; // TODO implement this getter

  final int index;

  final List newValues;

  // TODO so we can do _updateState
//  final List oldValues;
  List _oldValues;
  List get oldValues => _oldValues;

  final String type = EventType.VALUES_SET.value;

  _LocalValuesSetEvent._(this.index, this.newValues, this._oldValues, _target) : super._(_target);

  _LocalValuesSetEvent get inverse => new _LocalValuesSetEvent._(index, oldValues, newValues, _target);

  void _updateState() {
    _oldValues = (_target as _LocalModelList).asArray().sublist(index, index + newValues.length);
  }
}