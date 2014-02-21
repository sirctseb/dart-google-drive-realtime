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

/// A [_LocalEvent] that can be undone
// TODO put in it's own file?
abstract class _LocalUndoableEvent extends _LocalEvent {
  // create an event that performs the opposite of this
  _LocalUndoableEvent get inverse;

  _LocalUndoableEvent._(_target) : super._(_target);

  void _executeAndEmit() {
    _target._executeAndEmitEvent(this);
  }
}

/** [_UndoHistory] manages the history of actions performed in the app */
// TODO events grouped into a single object changed event are still grouped
// TODO during undo in the realtime implementation, but are split up here
// TODO undo state events are not in the same order with respect to other events
// TODO as seen by client code. also rt sometimes sends two of the same events
class _UndoHistory {
  /** The list of actions in the undo history */
  List<List<_LocalUndoableEvent>> _history = [[]];

  /// The current index into the undo history.
  int _index = 0;

  // true when the last object changed that wasn't from an undo or redo
  // was a terminal change
  bool _lastWasTerminal = false;
  // accessor to return true if a change event is the first of a set
  // that is not caused by an undo or redo
  bool get _firstOfSet => _lastWasTerminal && !_undoScope && !_redoScope;

  // Add a list of events to the current undo index
  void _addUndoEvents(Iterable<_LocalUndoableEvent> events, {bool terminateSet: false, bool prepend: false}) {
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

  _LocalModel model;

  bool _undoScope = false;
  bool _redoScope = false;
  bool _initScope = false;

  _UndoHistory(_LocalModel this.model) {
    model.root.onObjectChanged.listen((_LocalObjectChangedEvent e) {
      if(_initScope) {
        // don't add to undo history in initialization
      } else if(_undoScope) {
        // if undoing, add inverse of events to history
        _addUndoEvents(e.events, prepend: true);
      } else if(_redoScope) {
        // if redoing, add events to history
        _addUndoEvents(e.events, prepend: true);
      } else {
        // store current undo/redo state
        bool _canUndo = canUndo;
        bool _canRedo = canRedo;

        // add event to current undo set
        _addUndoEvents(e.events.reversed, terminateSet: e._isTerminal);
        _lastWasTerminal = e._isTerminal;

        // if undo/redo state changed, send event
        if(_canUndo != canUndo || _canRedo != canRedo) {
          model._onUndoRedoStateChanged.add(
              new _LocalUndoRedoStateChangedEvent._(canRedo, canUndo));
        }
      }
    });
  }

  void initializeModel(initialize, _LocalModel m) {
    // call initialization callback with _initScope set to true
    _initScope = true;
    initialize(m);
    _initScope = false;
  }

  void undo() {
    // store current undo/redo state
    bool _canUndo = canUndo;
    bool _canRedo = canRedo;

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
      var event = new _LocalObjectChangedEvent._([e], e._target);
      e._target.dispatchObjectChangedEvent(event);
    });
    // unset undo latch
    _undoScope = false;

    // if undo/redo state changed, send event
    if(_canUndo != canUndo || _canRedo != canRedo) {
      model._onUndoRedoStateChanged.add(
        new _LocalUndoRedoStateChangedEvent._(canRedo, canUndo));
    }
  }
  void redo() {
    // store current undo/redo state
    bool _canUndo = canUndo;
    bool _canRedo = canRedo;

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
      var event = new _LocalObjectChangedEvent._([e], e._target);
      e._target.dispatchObjectChangedEvent(event);
    });
    // increment index
    _index++;
    // uset redo latch
    _redoScope = false;

    // if undo/redo state changed, send event
    if(_canUndo != canUndo || _canRedo != canRedo) {
      model._onUndoRedoStateChanged.add(
        new _LocalUndoRedoStateChangedEvent._(canRedo, canUndo));
    }
  }

  // TODO check on these definitions
  bool get canUndo => _index > 0;
  bool get canRedo => _index < _history.length - 1;
}
