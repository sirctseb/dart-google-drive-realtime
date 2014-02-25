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

class Scope extends IsEnum<String> {
  static final NONE = new Scope._('none');
  static final CO = new Scope._('co');
  static final UNDO = new Scope._('undo');
  static final REDO = new Scope._('redo');
  static final INIT = new Scope._('init');

  static final _INSTANCES = [NONE, CO, UNDO, REDO, INIT];

  static Scope find(Object o) => findIn(_INSTANCES, o);

  Scope._(String value) : super(value);

  bool operator ==(Object other) => value == (other is Scope ? other.value : other);
}

typedef String Sorter(dynamic element, int index);

/** [_UndoHistory] manages the history of actions performed in the app */
// TODO events grouped into a single object changed event are still grouped
// TODO during undo in the realtime implementation, but are split up here
// TODO undo state events are not in the same order with respect to other events
// TODO as seen by client code. also rt sometimes sends two of the same events
class _UndoHistory {
  /** The list of actions in the undo history */
  List<List<_LocalUndoableEvent>> _history = [];

  /// The current index into the undo history.
  int _index = 0;

  List<_LocalUndoableEvent> _currentCO = null;

  List<Scope> _COScopes = [];

  void beginCompoundOperation(Scope scope) {
    if(_COScopes.length == 0) {
      _currentCO = [];
    }
    _COScopes.add(scope);
  }

  void endCompoundOperation() {
    var scope = _COScopes.removeLast();
    if(_COScopes.length == 0) {
      // invert the operations and reverse the order
      var inverseCO = _currentCO.reversed.map((e) {
        return e.inverse;
      }).toList(growable: false);
      // clear current CO
      _currentCO = null;
      if(scope == Scope.UNDO) {
        // if we started from an undo, replace history at previous index with current CO
        _history[_index] = inverseCO;
      } else if(scope == Scope.REDO) {
        // if we started from a redo, replace history at current index with current CO
        _history[_index] = inverseCO;
      } else if(scope != Scope.INIT) {
        // add to the history
        _history.removeRange(_index, _history.length);
        _history.add(inverseCO);
        _index++;
      }
    }
  }

  // Add a list of events to the current undo index
  void _addUndoEvents(Iterable<_LocalUndoableEvent> events) {
    if(_COScopes.length == 0 || _COScopes[0] != Scope.INIT) {
      _currentCO.addAll(events);
    }
  }

  _LocalModel model;

  _UndoHistory(_LocalModel this.model) {}

  void initializeModel(initialize, _LocalModel m) {
    // call initialization callback with _initScope set to true
    beginCompoundOperation(Scope.INIT);
    initialize(m);
    endCompoundOperation();
  }

  // TODO move this (and typedef above) to utils
  static Map bucket(List list, Sorter sorter) {
    Map buckets = {};
    for(int i = 0; i < list.length; i++) {
      var value = list[i];
      var key = sorter(value, i);
      if(key != null) {
        var bucket = buckets.containsKey(key) ? buckets[key] : (buckets[key] = []);
        bucket.add(value);
      }
    }
    return buckets;
  }

  void undo() {
    // store current undo/redo state
    bool _canUndo = canUndo;
    bool _canRedo = canRedo;

    beginCompoundOperation(Scope.UNDO);

    // decrement index
    _index--;
    // do changes and events
    _history[_index].forEach((e) {
      e._updateState();
      e._executeAndEmit();
    });
    // group by target
    // TODO take id of object base class
    var bucketed = bucket(_history[_index], (e, index) => e._target.id);
    // do object changed events
    for(var id in bucketed.keys) {
      var event = new _LocalObjectChangedEvent._(bucketed[id], bucketed[id][0]._target);
      bucketed[id][0]._target.dispatchObjectChangedEvent(event);
    }

    // unset undo scope flag
    endCompoundOperation();

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

    beginCompoundOperation(Scope.REDO);

    // redo events
    _history[_index].forEach((e) {
      e._updateState();
      e._executeAndEmit();
    });
    // group by target
    var bucketed = bucket(_history[_index], (e, index) => e._target.id);
    // do object changed events
    for(var id in bucketed.keys) {
      var event = new _LocalObjectChangedEvent._(bucketed[id], bucketed[id][0]._target);
      bucketed[id][0]._target.dispatchObjectChangedEvent(event);
    }

    endCompoundOperation();

    // increment index
    _index++;

    // if undo/redo state changed, send event
    if(_canUndo != canUndo || _canRedo != canRedo) {
      model._onUndoRedoStateChanged.add(
        new _LocalUndoRedoStateChangedEvent._(canRedo, canUndo));
    }
  }

  // TODO check on these definitions
  bool get canUndo => _index > 0;
  bool get canRedo => _index < _history.length;
}
