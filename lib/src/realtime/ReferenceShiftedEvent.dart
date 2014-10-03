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

class ReferenceShiftedEvent extends BaseModelEvent {
  static ReferenceShiftedEvent _cast(js.JsObject proxy) => proxy == null ? null : new ReferenceShiftedEvent._fromProxy(proxy);

  ReferenceShiftedEvent._fromProxy(js.JsObject proxy) : super._fromProxy(proxy);

  int get newIndex => $unsafe['newIndex'];
  int get oldIndex => $unsafe['oldIndex'];
}
