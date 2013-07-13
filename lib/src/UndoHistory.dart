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

  // true when the last object changed that wasn't from an undo or redo
  // was a terminal change
  bool _lastWasTerminal = false;
  // accessor to return true if a change event is the first of a set
  // that is not caused by an undo or redo
  bool get _firstOfSet => _lastWasTerminal && !_undoScope && !_redoScope;

  // Add a list of events to the current undo index
  void _addUndoEvents(Iterable<LocalUndoableEvent> events, {bool terminateSet: false, bool prepend: false}) {
    // if this is the first of a set and we're not undoing or redoing,
    // truncate the history after this point
    if(_firstOfSet) {
      _history.removeRange(_index, _history.length);
      _history.add([]);
    }
    if(prepend) {
      _history[_index].insertAll(0, events);
    } else {
      _history[_index].addAll(events);
    }
    if(terminateSet) {
      _history.add([]);
      _index++;
    }
  }

  bool _undoScope = false;
  bool _redoScope = false;
  UndoHistory(LocalModelMap root) {
    root.onObjectChanged.listen((LocalObjectChangedEvent e) {
      if(_undoScope) {
        // if undoing, add inverse of events to history
        _addUndoEvents(e.events, prepend: true);
      } else if(_redoScope) {
        // if redoing, add events to history
        _addUndoEvents(e.events, prepend: true);
      } else {
        // add event to current undo set
        _addUndoEvents(e.events.reversed, terminateSet: e._isTerminal);
        _lastWasTerminal = e._isTerminal;
      }
    });
  }

  void undo() {
    // set undo latch
    _undoScope = true;
    // decrement index
    _index--;
    // save current events
    var inverses = _history[_index].map((e) => e.inverse).toList();
    // put empty list in place
    _history[_index] = [];
    // do changes and events
    inverses.forEach((e) => e._executeAndEmit());
    // do object changed events
    inverses.forEach((e) {
      var event = new LocalObjectChangedEvent._([e], e._target);
      e._target._onObjectChanged.add(event);
      e._target._onPostObjectChangedController.add(event);
    });
    // unset undo latch
    _undoScope = false;
  }
  void redo() {
    // set redo latch
    _redoScope = true;
    // save current events
    var inverses = _history[_index].map((e) => e.inverse).toList();
    // put empty list in place
    _history[_index] = [];
    // redo events
    inverses.forEach((e) => e._executeAndEmit());
    // do object changed events
    inverses.forEach((e) {
      var event = new LocalObjectChangedEvent._([e], e._target);
      e._target._onObjectChanged.add(event);
      e._target._onPostObjectChangedController.add(event);
    });
    // increment index
    _index++;
    // uset redo latch
    _redoScope = false;
  }

  // TODO check on these definitions
  bool get canUndo => _index > 0;
  bool get canRedo => _index < _history.length - 1;
}
