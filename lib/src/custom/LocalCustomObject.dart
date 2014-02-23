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

class _LocalCustomObject extends _LocalModelObject implements _InternalCustomObject {
  // information on the custom types registered
  static Map _registeredTypes = {};
  // map from object ids to the models that contain them
  static Map _customObjectModels = {};
  Map _fields = {};

  _LocalCustomObject(String name) {
    // initialize fields
    for(var key in _registeredTypes[name]['fields']) {
      _fields[key] = null;
    }
    _eventStreamControllers[EventType.VALUE_CHANGED.value] = _onValueChanged;
  }

  StreamController<_LocalValueChangedEvent> _onValueChanged
    = new StreamController<_LocalValueChangedEvent>.broadcast(sync: true);
  Stream<ValueChangedEvent> get onValueChanged => _onValueChanged.stream;

  dynamic get(String field) => _fields[field];
  void set(String field, dynamic value) {
    // send the event
    var event = new _LocalValueChangedEvent._(value, _fields[field], field, this);
    _emitEventsAndChanged([event]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if(_fields.containsKey(name)) {
      return get(name);
    }
    if(_fields.containsKey(name.substring(0, name.length - 1))
        && name.endsWith('=')) {
      set(name.substring(0, name.length - 1), invocation.positionalArguments[0]);
      return invocation.positionalArguments[0];
    }
    throw new NoSuchMethodError(this,
                                invocation.memberName,
                                invocation.positionalArguments,
                                invocation.namedArguments);
  }

  void _executeEvent(_LocalUndoableEvent event_in) {
    if(event_in.type == EventType.VALUE_CHANGED.value) {
        var event = event_in as _LocalValueChangedEvent;
        _fields[event.property] = event.newValue;
        // stop propagating changes if we're writing over a model object
        if(event.oldValue is _LocalModelObject && !_fields.containsValue(event.oldValue)) {
          event.oldValue.removeParentEventTarget(this);
        }
        // propagate changes on model data objects
        if(event.newValue is _LocalModelObject) {
          event.newValue.addParentEventTarget(this);
        }
    } else {
        super._executeEvent(event_in);
    }
  }
}