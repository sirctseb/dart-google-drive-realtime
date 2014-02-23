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

class _LocalTextInsertedEvent extends _LocalUndoableEvent implements TextInsertedEvent {

  bool get bubbles => null; // TODO implement this getter

  final int index;

  final String text;

  final String type = EventType.TEXT_INSERTED.value;

  _LocalTextInsertedEvent._(this.index, this.text, _target) : super._(_target);

  _LocalTextDeletedEvent get inverse => new _LocalTextDeletedEvent._(index, text, _target);
}