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

// TODO I have dumped a lot of js wrapping stuff here, it all needs to move out

//dynamic mapNotNull(dynamic o, Mapper mapper) => o != null ? mapper(o) : null;

List<BaseModelEvent> TranslateEventList(js.JsArray eventListProxy) {
  return eventListProxy.map(_promoteEventByType).toList(growable: false);
}
// TODO should this be a smarter list that only converts on demand list jsw version?
// TODO redundant with JsArrayToListAdapter
// functions that convert from js to dart objects
List TranslateCollaborativeListToArray(js.JsArray jsArray) {
  return jsArray.map(_promoteProxy).toList(growable: false);
}
List<dynamic> JsArrayToListAdapter(js.JsArray jsArray, Mapper mapper) {
  return jsArray.map(mapper).toList(growable: false);
}
List<List<dynamic>> JsArrayOfArraysToListAdapter(js.JsArray jsArray, Mapper mapper) {
  return jsArray.map((e) => JsArrayToListAdapter(e, mapper)).toList(growable: false);
}
// functions that conver from dart to js objects
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
class CollaborativeContainerTranslator<E> extends Translator<E> {
  static dynamic _fromJs(dynamic object) {
    return _promoteProxy(object);
  }
  static dynamic _toJs(dynamic object) {
    // TODO this should not be called toJS
    if(object is CustomObject) return object.toJs();
    if(object is CollaborativeObject) return object.$unsafe;
    if(object is List) return new js.JsObject.jsify(object);
    if(object is Map) return new js.JsObject.jsify(object);
    // TODO should still restrict to supported types here
    return object;
  }

  CollaborativeContainerTranslator() : super(_fromJs, _toJs);
}

class CollaborativeContainer<V> extends CollaborativeObject {
  CollaborativeContainer._fromProxy(js.JsObject proxy) : super._fromProxy(proxy);

  static final Translator _realtimeTranslator = new CollaborativeContainerTranslator();
  final Translator<V> _translator = _realtimeTranslator;
}