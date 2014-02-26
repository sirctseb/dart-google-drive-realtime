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

class _LocalModelObject extends _LocalEventTarget implements CollaborativeObject {

  /// Local objects have no js Proxy
  final js.Proxy $unsafe = null;

  final String id;

  final _LocalModel _model;

  /// Local objects have no js Proxy
  dynamic toJs() => null;

  static int _idNum = 0;
  static String get nextId => (_idNum++).toString();

  _LocalModelObject(_LocalModel this._model) : id = nextId;

  // create an emit a _LocalObjectChangedEvent from a list of events
  void _emitEventsAndChanged(List<_LocalUndoableEvent> events) {
    _model.beginCompoundOperation();

    // add events to undo history
    _model._undoHistory._addUndoEvents(events);

    // create change event
    var event = new _LocalObjectChangedEvent._(events,this);
    for(int i = 0; i < events.length; i++) {
      // execute events
      _executeEvent(events[i]);
      // fire actual events
      _eventStreamControllers[events[i].type].add(events[i]);
    }
    dispatchObjectChangedEvent(event);
    _model.endCompoundOperation();
  }
  void _executeAndEmitEvent(_LocalUndoableEvent event) {
    _model.beginCompoundOperation();

    // add events to undo history
    _model._undoHistory._addUndoEvents([event]);

    // make change
    _executeEvent(event);
    // emit event
    _eventStreamControllers[event.type].add(event);

    _model.endCompoundOperation();
  }

  void _executeEvent(_LocalUndoableEvent event) {}

  // map from event type to stream controller they go on
  Map<String, StreamController> _eventStreamControllers = {};

  /// JSON serialized data
  Map toJSON() {
    // TODO implement for custom object
    return {
      "id": this.id,
      "type": "", // TODO
      "value": {} // TODO
    };
  }
}