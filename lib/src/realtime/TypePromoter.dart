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

/// Promote proxied objects to collaborative objects if they are that type
dynamic _promoteProxy(dynamic object) {
  String type;

  if(object is js.JsObject) {
    if(realtimeCustom['isCustomObject'].apply([object])) {
      // TODO do backing object assignment in the CustomObject constructor
      // make realtime backing object
      var backingObject = new _RealtimeCustomObject._fromProxy(object);
      // make CustomObject to return
      var customObject = new CustomObject._byName(_RealtimeCustomObject._findTypeName(object));
      // set internal object
      customObject._internalCustomObject = backingObject;
      // return custom object subclass
      return customObject;
    } else if(object.instanceof(realtime['CollaborativeMap'])) {
      return new CollaborativeMap._fromProxy(object);
    } else if(object.instanceof(realtime['CollaborativeList'])) {
      return new CollaborativeList._fromProxy(object);
    } else if(object.instanceof(realtime['CollaborativeString'])) {
      return new CollaborativeString._fromProxy(object);
    } else if(object.instanceof(js.context['Array'])
               || object.instanceof(js.context['Object'])) {
      return json.parse(js.context['JSON']['stringify'].apply([object]));
    }
  }
  // string, bool, numbers all get the correct type automatically
  return object;
}
/// Construct typed event classes based on type
dynamic _promoteEventByType(js.JsObject event) {
  if(event['type'] == EventType.TEXT_DELETED.value) {
    return new TextDeletedEvent._fromProxy(event);
  }
  if(event['type'] == EventType.TEXT_INSERTED.value) {
    return new TextInsertedEvent._fromProxy(event);
  }
  if(event['type'] == EventType.VALUES_ADDED.value) {
    return new ValuesAddedEvent._fromProxy(event);
  }
  if(event['type'] == EventType.VALUES_REMOVED.value) {
    return new ValuesRemovedEvent._fromProxy(event);
  }
  if(event['type'] == EventType.VALUES_SET.value) {
    return new ValuesSetEvent._fromProxy(event);
  }
  if(event['type'] == EventType.VALUE_CHANGED.value) {
    return new ValueChangedEvent._fromProxy(event);
  }
  // TODO throw
  return null;
}