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


typedef T Mapper<F,T>(F o);

// TODO should this be a smarter list that only converts on demand like jsw version?
List<dynamic> JsArrayToListAdapter(js.JsArray jsArray, Mapper mapper) {
  return jsArray.map(mapper).toList(growable: false);
}
js.JsArray ListToJsArrayAdapter(List<dynamic> list, Mapper mapper) {
  return new js.JsArray.from(list.map(mapper));
}
js.JsObject MapToJsObjectAdapter(Map<String, dynamic> map, Mapper mapper) {
  var translated = {};
  for(var key in map.keys) {
    translated[key] = mapper(map[key]);
  }
  return new js.JsObject.jsify(translated);
}

class Translator<E> {
  final Mapper<dynamic, E> fromJs;
  final Mapper<E, dynamic> toJs;

  Translator(this.fromJs, this.toJs);
}

// translator to promote to collaborative types
class CollaborativeObjectTranslator<E> extends Translator<E> {
  // returns the type of an object contained in a model
  // Map, List, EditableString, JsonValue, or <CustomObjectName>
  static String typeof(dynamic object) {
    if(object.hasProperty('clear') &&
        object.hasProperty('delete') &&
        object.hasProperty('get') &&
        object.hasProperty('has') &&
        object.hasProperty('isEmpty') &&
        object.hasProperty('items') &&
        object.hasProperty('keys') &&
        object.hasProperty('set') &&
        object.hasProperty('values')) {
      return 'Map';
    } else if(object.hasProperty('asArray') &&
        object.hasProperty('clear') &&
        object.hasProperty('get') &&
        object.hasProperty('indexOf') &&
        object.hasProperty('insert') &&
        object.hasProperty('insertAll') &&
        object.hasProperty('lastIndexOf') &&
        object.hasProperty('move') &&
        object.hasProperty('moveToList') &&
        object.hasProperty('push') &&
        object.hasProperty('pushAll') &&
        object.hasProperty('registerReference') &&
        object.hasProperty('remove') &&
        object.hasProperty('removeRange') &&
        object.hasProperty('removeValue') &&
        object.hasProperty('replaceRange') &&
        object.hasProperty('set')) {
      return 'List';
    } else if(object.hasProperty('append') &&
        object.hasProperty('getText') &&
        object.hasProperty('insertString') &&
        object.hasProperty('registerReference') &&
        object.hasProperty('removeRange') &&
        object.hasProperty('setText')) {
      return 'EditableString';
    } else if(isCustomObject(object)) {
      return CustomObject._customObjectName(object);
    } else if(object.instanceof(js.context['Array']) || object.instanceof(js.context['Object'])) {
      return 'JsonValue';
    }
    return 'native';
  }

  static dynamic _fromJs(dynamic object) {
    if(object is js.JsObject) {
      var type = typeof(object);
      if(realtimeCustom['isCustomObject'].apply([object])) {
        // make CustomObject to return
        var customObject = new CustomObject._byName(CustomObject._findTypeName(object), object);
        // return custom object subclass
        return customObject;
      //} else if(object.instanceof(realtime['CollaborativeMap'])) {
      } else if(type == 'Map') {
        return new CollaborativeMap._fromProxy(object);
      //} else if(object.instanceof(realtime['CollaborativeList'])) {
      } else if(type == 'List') {
        return new CollaborativeList._fromProxy(object);
      //} else if(object.instanceof(realtime['CollaborativeString'])) {
      } else if(type == 'EditableString') {
        return new CollaborativeString._fromProxy(object);
      //} else if(object.instanceof(js.context['Array'])
                 //|| object.instanceof(js.context['Object'])) {
      } else if(type == 'JsonValue') {
        return JSON.decode(js.context['JSON']['stringify'].apply([object]));
      }
    }
    // string, bool, numbers all get the correct type automatically
    return object;
  }
  static dynamic _toJs(dynamic object) {
    // TODO this should not be called toJS
    if(object is CustomObject) return object.toJs();
    if(object is CollaborativeObject) return object.toJs();
    if(object is List) return new js.JsObject.jsify(object);
    if(object is Map) return new js.JsObject.jsify(object);
    // TODO should still restrict to supported types here
    return object;
  }

  CollaborativeObjectTranslator() : super(_fromJs, _toJs);
}

/// Construct typed event classes based on type
class EventTranslator<E> extends Translator<E> {
  static dynamic _fromJs(js.JsObject event) {
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

  static dynamic _toJs(dynamic object) {
    // TODO this should not be called toJS
    if(object is CustomObject) return object.toJs();
    if(object is CollaborativeObject) return object.toJs();
    if(object is List) return new js.JsObject.jsify(object);
    if(object is Map) return new js.JsObject.jsify(object);
    // TODO should still restrict to supported types here
    return object;
  }

  EventTranslator() : super(_fromJs, _toJs);
}