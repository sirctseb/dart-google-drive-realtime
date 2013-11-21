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

library realtime_data_model_custom;

import 'package:js/js.dart' as js;

import 'realtime_data_model.dart';

final realtimeCustom = realtime['custom'];

dynamic collaborativeField(String name) => realtimeCustom.collaborativeField(name);

String getId(dynamic obj) => realtimeCustom.getId(obj);

Model getModel(dynamic obj) => new Model.fromProxy(realtimeCustom.getModel(obj));

bool isCustomObject(dynamic obj) => realtimeCustom.isCustomObject(obj);

void registerType(js.Serializable<js.FunctionProxy> type, String name) {
  realtimeCustom.registerType(type, name);
}

void setInitializer(js.Serializable<js.FunctionProxy> type, Function initialize) {
  realtimeCustom.setInitializer(type, initialize);
}

void setOnLoaded(js.Serializable<js.FunctionProxy> type, [Function onLoaded]) {
  realtimeCustom.setOnLoaded(type, onLoaded);
}