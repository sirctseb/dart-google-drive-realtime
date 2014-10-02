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

// TODO extending Container instead of Object for _translator
class _RealtimeCustomObject extends CollaborativeContainer implements _InternalCustomObject {
  // information on the custom types registered
  static Map _registeredTypes = {};
  static final String _idToTypeProperty = '_idToType';

  _RealtimeCustomObject(String name) : super._fromProxy(new js.Proxy(_registeredTypes[name]["js-type"])) {}
  _RealtimeCustomObject._fromProxy(js.Proxy proxy) : super._fromProxy(proxy) {}
  static String _findTypeName(js.Proxy proxy) {
    // get reference to id->name map
    var idToType = new Model._fromProxy(realtime['custom']['getModel'].apply([proxy])).root[_idToTypeProperty];
    return idToType[realtime['custom']['getId'].apply([proxy])];
  }

  // TODO these could go in Container also probably
  dynamic _toJs(e) => _translator == null ? e : _translator.toJs(e);
  V _fromJs(dynamic value) => _translator == null ? value :
      _translator.fromJs(value);

  dynamic get(String field) => $unsafe[field];
  void set(String field, dynamic value) {
    $unsafe[field] = _toJs(value);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if(_registeredTypes[_findTypeName(this.$unsafe)]['fields'].contains(name)) {
      return get(name);
    }
    if(_registeredTypes[_findTypeName(this.$unsafe)]['fields'].contains(name.substring(0, name.length - 1))
        && name.endsWith('=')) {
      set(name.substring(0, name.length - 1), invocation.positionalArguments[0]);
      return invocation.positionalArguments[0];
    }
    throw new NoSuchMethodError(this,
                                invocation.memberName,
                                invocation.positionalArguments,
                                invocation.namedArguments);
  }
}