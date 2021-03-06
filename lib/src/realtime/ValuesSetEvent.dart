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

class ValuesSetEvent extends BaseModelEvent {
  static ValuesSetEvent _cast(js.JsObject proxy) => proxy == null ? null : new ValuesSetEvent._fromProxy(proxy);

  ValuesSetEvent._fromProxy(js.JsObject proxy) : super._fromProxy(proxy);

  int get index => $unsafe['index'];
  List<dynamic> get newValues => JsArrayToListAdapter($unsafe['newValues'], CollaborativeObject._realtimeTranslator.fromJs);
  List<dynamic> get oldValues => JsArrayToListAdapter($unsafe['oldValues'], CollaborativeObject._realtimeTranslator.fromJs);
}
