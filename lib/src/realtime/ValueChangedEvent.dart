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

class ValueChangedEvent extends BaseModelEvent {
  static ValueChangedEvent _cast(js.JsObject proxy) => proxy == null ? null : new ValueChangedEvent._fromProxy(proxy);

  ValueChangedEvent._fromProxy(js.JsObject proxy) : super._fromProxy(proxy);

  dynamic get newValue => _promoteProxy($unsafe['newValue']);
  dynamic get oldValue => _promoteProxy($unsafe['oldValue']);
  String get property => $unsafe['property'];
}
