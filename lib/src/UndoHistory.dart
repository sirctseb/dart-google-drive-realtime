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

  /// The current index into the undo history.
  int _index = -1;

  // Add a list of events to the current undo index
  void _addUndoEvents(List<LocalUndoableEvent> events, {bool newSet: false}) {
    if(newSet) {
      _history.add([]);
      _index++;
    }
    _history[_index].addAll(events);
  }

  bool _undoLatch = false;
  bool _redoLatch = false;
  UndoHistory(LocalModelMap root) {
    root.onObjectChanged.listen((LocalObjectChangedEvent e) {
      if(_undoLatch) {
        // if undoing, add inverse of events to history
        _addUndoEvents(e.events);
      } else if(_undoLatch) {
        // if redoing, add events to history
        _addUndoEvents(e.events);
      } else {
        // add event to current undo set
        _addUndoEvents(e.events, newSet: e._undoSetRoot);
        // TODO if new undo set, truncate history after this
      }
    });
  }

  void undo() {
    // set undo latch
    _undoLatch = true;
    // save current events
    var current = _history[_index];
    // put empty list in place
    _history[_index] = [];
    // undo events
    current.reversed.forEach((e) => e._undo());
    // decrement index
    _index--;
    // unset undo latch
    _undoLatch = false;
  }
  void redo() {
    // set redo latch
    _redoLatch = true;
    // increment index
    _index++;
    // save current events
    var current = _history[_index];
    // put empty list in place
    _history[_index];
    // redo events
    // TODO we call undo instead of redo because the events in the list
    // TODO are events instigated by undo calls, so they are the inverse of what
    // TODO The original events were. this is not obvious and we should consider
    // TODO changing it to make it clearer
    current.reversed.forEach((e) => e._undo());
    // uset redo latch
    _redoLatch = false;
  }
}
