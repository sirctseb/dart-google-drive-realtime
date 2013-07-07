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
dynamic promoteProxy(dynamic object) {
  String type;

  if(object is js.Proxy) {
    var realtimeNamespace = js.context['gapi']['drive']['realtime'];
    if(js.instanceof(object, realtimeNamespace['CollaborativeMap'])) {
      return new CollaborativeMap.fromProxy(object);
    } else if(js.instanceof(object, realtimeNamespace['CollaborativeList'])) {
      return new CollaborativeList.fromProxy(object);
    } else if(js.instanceof(object, realtimeNamespace['CollaborativeString'])) {
      return new CollaborativeString.fromProxy(object);
    } else if(js.instanceof(object, js.context['Array'])
               || js.instanceof(object, js.context['Object'])) {
      return json.parse(js.context['JSON']['stringify'](object));
    }
  }
  // string, bool, numbers all get the correct type automatically
  return object;
}
/// Construct typed event classes based on type
dynamic promoteEventByType(BaseModelEvent event) {
  // TODO we only use this for events that fire on strings, lists, and maps, but maybe we should support the rest?
  if(event.type == EventType.TEXT_DELETED.value) {
    return new TextDeletedEvent.fromProxy(event.toJs());
  }
  if(event.type == EventType.TEXT_INSERTED.value) {
    return new TextInsertedEvent.fromProxy(event.toJs());
  }
  if(event.type == EventType.VALUES_ADDED.value) {
    return new ValuesAddedEvent.fromProxy(event.toJs());
  }
  if(event.type == EventType.VALUES_REMOVED.value) {
    return new ValuesRemovedEvent.fromProxy(event.toJs());
  }
  if(event.type == EventType.VALUES_SET.value) {
    return new ValuesSetEvent.fromProxy(event.toJs());
  }
  if(event.type == EventType.VALUE_CHANGED.value) {
    return new ValueChangedEvent.fromProxy(event.toJs());
  }
  // TODO throw
  return null;
}