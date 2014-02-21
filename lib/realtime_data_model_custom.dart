// Copyright (c) 2013, Alexandre Ardhuin
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

final realtimeCustom = realtime['custom'];

// TODO make field a separate call like js lib
void registerType(Type type, String name, List fields) {
  // store dart type
  CustomObject._registeredTypes[name] = {'dart-type': type};

  // do google registration
  // make sure js drive stuff is loaded
  GoogleDocProvider._globalSetup().then((bool success) {
    // store the js type and fields
    _RealtimeCustomObject._registeredTypes[name] = {
                              // TODO is this the best way to just create a js function?
                             'js-type': new js.FunctionProxy.withThis((p) {}),
                             'fields': fields};
    // do the js-side registration
    realtimeCustom.registerType(_RealtimeCustomObject._registeredTypes[name]["js-type"], name);
    // add fields
    for(var field in fields) {
      _RealtimeCustomObject._registeredTypes[name]['js-type']['prototype'][field] = realtimeCustom['collaborativeField'](field);
    }
  });

  // do local registration
  _LocalCustomObject._registeredTypes[name] = {'fields': fields};
}

dynamic collaborativeField(String name) => realtimeCustom.collaborativeField(name);

String getId(dynamic obj) {
  if(GoogleDocProvider._isCustomObject(obj)) {
    return realtimeCustom.getId(obj);
  } else if(LocalDocumentProvider._isCustomObject(obj)) {
    // TODO should refactor so id accessor is not in custom object
    return obj._internalCustomObject.id;
  }
}

Model getModel(dynamic obj) {
  // TODO test that obj is custom object
  return obj._model;
}

bool isCustomObject(dynamic obj) {
  return GoogleDocProvider._isCustomObject(obj) || LocalDocumentProvider._isCustomObject(obj);
}

// TODO move these two into do providers
void setInitializer(js.Serializable<js.FunctionProxy> type, Function initialize) {
  realtimeCustom.setInitializer(type, initialize);
}

void setOnLoaded(js.Serializable<js.FunctionProxy> type, [Function onLoaded]) {
  realtimeCustom.setOnLoaded(type, onLoaded);
}