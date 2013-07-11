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

/// A [LocalEvent] that can be undone
// TODO put in it's own file?
abstract class LocalUndoableEvent extends LocalEvent {
  // apply the inverse of the change the event represents
  void _undo();
  // apply the change the event represents
  void _redo();

  LocalUndoableEvent._(_target) : super._(_target);
}

/** [UndoHistory] manages the history of actions performed in the app */
class UndoHistory {
  /** The list of actions in the undo history */
  List<List<LocalUndoableEvent>> _history = [];

  /** The current index into the undo history.
   * At any time, history[index-1] has been performed and history index has not
   */
  int _index = 0;
}
