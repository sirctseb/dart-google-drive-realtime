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

class CustomObject extends CollaborativeContainer {
  // information on the custom types registered
  static Map _registeredTypes = {};

  // look up CustomObject subclass by name and return a new instance
  factory CustomObject._byName(String name, js.JsObject proxy) {
    var result = reflectClass(_registeredTypes[name]['dart-type']).newInstance(new Symbol(""), []).reflectee;
    // TODO had to make $unsafe not final just for this line
    result.$unsafe = proxy;
    return result;
  }

  CustomObject._fromProxy(js.JsObject proxy) : super._fromProxy(proxy) {}

  // TODO shouldn't exist but need to in order to allow subclasses
  CustomObject() : super._fromProxy(null);

  static String _findTypeName(js.JsObject proxy) {
    // get reference to id->name map
    var idToType = new Model._fromProxy(realtime['custom']['getModel'].apply([proxy])).root[_idToTypeProperty];
    return idToType[realtime['custom']['getId'].apply([proxy])];
  }

  dynamic get(String field) => $unsafe[field];
  void set(String field, dynamic value) {
    $unsafe[field] = _toJs(value);
  }

  dynamic toJs() => $unsafe;

  Model get _model {
    return new Model._fromProxy(realtimeCustom['getModel'].apply([$unsafe]));
  }

  static String _customObjectName(object) {
    for(var name in _registeredTypes.keys) {
      if(_registeredTypes[name]['ids'].contains(getId(object))) {
        return name;
      }
    }

    throw new Exception('$object is not a registered custom object type');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if(CustomObject._registeredTypes[_findTypeName(this.$unsafe)]['fields'].contains(name)) {
      return get(name);
    }
    if(CustomObject._registeredTypes[_findTypeName(this.$unsafe)]['fields'].contains(name.substring(0, name.length - 1))
        && name.endsWith('=')) {
      set(name.substring(0, name.length - 1), invocation.positionalArguments[0]);
      return invocation.positionalArguments[0];
    }
    throw new NoSuchMethodError(this,
                                invocation.memberName,
                                invocation.positionalArguments,
                                invocation.namedArguments);
  }

  static final String _idToTypeProperty = '_idToType';
}