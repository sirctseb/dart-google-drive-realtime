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

// TODO this should not actually extend LocalEvent,
// TODO and UndoRedoStateChangedEvent should not extend BaseModelEvent
class _LocalUndoRedoStateChangedEvent extends _LocalEvent implements UndoRedoStateChangedEvent {

  bool get bubbles => null; // TODO implement this getter

  final bool canRedo;

  final bool canUndo;

  final String type = _ModelEventType.UNDO_REDO_STATE_CHANGED.value;

  _LocalUndoRedoStateChangedEvent._(this.canRedo, this.canUndo)
    : super._(null);
}