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

class DocumentSaveStateChangedEvent extends TypedProxy {
  static DocumentSaveStateChangedEvent _cast(js.JsObject proxy) => proxy == null ? null : new DocumentSaveStateChangedEvent._fromProxy(proxy);

  DocumentSaveStateChangedEvent._fromProxy(js.JsObject proxy) : super.fromProxy(proxy);

  bool get isSaving => $unsafe['isSaving'];
  Document get target => new Document._fromProxy($unsafe['targer']);
  String get type => $unsafe['type'];
}

class _LocalDocumentSaveStateChangedEvent implements DocumentSaveStateChangedEvent {
  final bool isSaving;
  final Document target;
  final String type;

  _LocalDocumentSaveStateChangedEvent(this.isSaving, this.target, this.type);

  // define js-backed fields for the analyzer
  js.JsObject $unsafe;
  toJs() => null;
}