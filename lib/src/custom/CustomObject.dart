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

class CustomObject {
  // information on the custom types registered
  static Map _registeredTypes = {};

  // look up CustomObject subclass by name and return a new instance
  factory CustomObject._byName(String name) {
    return reflectClass(_registeredTypes[name]['dart-type']).newInstance(new Symbol(""), []).reflectee;
  }
  CustomObject() {}

  String toString() => _internalCustomObject.toString();

  Stream<ObjectChangedEvent> get onObjectChanged => _internalCustomObject.onObjectChanged;
  Stream<ValueChangedEvent> get onValueChanged => _internalCustomObject.onValueChanged;

  dynamic get(String field) => _internalCustomObject.get(field);
  set(String field, dynamic value) => _internalCustomObject.set(field, value);

  @override
  dynamic noSuchMethod(Invocation invocation) => _internalCustomObject.noSuchMethod(invocation);

  // internal custom object implementation
  _InternalCustomObject _internalCustomObject;

  dynamic toJs() => (_internalCustomObject as _RealtimeCustomObject).$unsafe;

  bool get _isRealtimeCustomObject => _internalCustomObject is _RealtimeCustomObject;

  Model get _model {
    return new Model._fromProxy(realtimeCustom['getModel'].apply([(this._internalCustomObject as _RealtimeCustomObject).$unsafe]));
  }

  // support export for local custom object
  _export(Set ids) {
    return _internalCustomObject._export(ids);
  }
  static String _customObjectName(object) {
    for(var name in _registeredTypes.keys) {
      if(_registeredTypes[name]['ids'].contains(object.id)) {
        return name;
      }
    }

    throw new Exception('$object is not a registered custom object type');
  }
}

abstract class _InternalCustomObject extends CustomObject {}