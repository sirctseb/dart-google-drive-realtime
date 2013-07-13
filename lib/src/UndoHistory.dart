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
  // create an event that performs the opposite of this
  LocalUndoableEvent get inverse;

  LocalUndoableEvent._(_target) : super._(_target);

  void _executeAndEmit() {
    _target._executeAndEmitEvent(this);
  }
}

/** [UndoHistory] manages the history of actions performed in the app */
class UndoHistory {
  /** The list of actions in the undo history */
  List<List<LocalUndoableEvent>> _history = [[]];

  /// The current index into the undo history.
  int _index = 0;

  // Add a list of events to the current undo index
  void _addUndoEvents(Iterable<LocalUndoableEvent> events, {bool terminateSet: false, bool prepend: true}) {
    _history[_index].addAll(events);
    if(terminateSet) {
      _history.add([]);
      _index++;
      LocalObjectChangedEvent._terminalEvent = null;
    }
  }

  bool _undoLatch = false;
  bool _redoLatch = false;
  UndoHistory(LocalModelMap root) {
    root.onObjectChanged.listen((LocalObjectChangedEvent e) {
      if(_undoLatch) {
        // if undoing, add inverse of events to history
        _addUndoEvents(e.events, prepend: true);
      } else if(_undoLatch) {
        // if redoing, add events to history
        _addUndoEvents(e.events, prepend: true);
      } else {
        // add event to current undo set
        _addUndoEvents(e.events, terminateSet: LocalObjectChangedEvent._terminalEvent == e);
      }
    });
  }

  void undo() {
    // set undo latch
    _undoLatch = true;
    // decrement index
    _index--;
    // save current events
    var current = _history[_index];
    // put empty list in place
    _history[_index] = [];
    // undo events
    current.forEach((e) => e._undo());
    // unset undo latch
    _undoLatch = false;
    LocalObjectChangedEvent._terminalEvent = null;
  }
  void redo() {
    // set redo latch
    _redoLatch = true;
    // save current events
    var current = _history[_index];
    // put empty list in place
    _history[_index] = [];
    // redo events
    // TODO we call undo instead of redo because the events in the list
    // TODO are events instigated by undo calls, so they are the inverse of what
    // TODO The original events were. this is not obvious and we should consider
    // TODO changing it to make it clearer
    current.forEach((e) => e._undo());
    // increment index
    _index++;
    // uset redo latch
    _redoLatch = false;
    LocalObjectChangedEvent._terminalEvent = null;
  }
}
