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

// as a shortcut to defining a separate interface with two subclasses for realtime and local,
// we can just implement the realtime interface if it doesn't require special realtime members
class _LocalValueChangedEvent extends _LocalUndoableEvent implements ValueChangedEvent {
  // TODO why doesn't fromProxy cause a problem?

  bool get bubbles => null; // TODO implement this getter

  final newValue;

  final oldValue;

  final String property;

  final String type = _ModelEventType.VALUE_CHANGED.value;

  _LocalValueChangedEvent._(this.newValue, this.oldValue, this.property, _target) : super._(_target);

  _LocalValueChangedEvent get inverse => new _LocalValueChangedEvent._(oldValue, newValue, property, _target);
}