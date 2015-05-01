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

// TODO this is a weird construction to get the same syntax as js lib
class DeleteModeType {
  String get SHIFT_AFTER_DELETE => realtime['IndexReference']['DeleteMode']['SHIFT_AFTER_DELETE'];
  String get SHIFT_BEFORE_DELETE => realtime['IndexReference']['DeleteMode']['SHIFT_BEFORE_DELETE'];
  String get SHIFT_TO_INVALID => realtime['IndexReference']['DeleteMode']['SHIFT_TO_INVALID'];
}

class IndexReference extends CollaborativeObject {
  SubscribeStreamProvider<ReferenceShiftedEvent> _onReferenceShifted;

  IndexReference._fromProxy(js.JsObject proxy) : super._fromProxy(proxy) {
    _onReferenceShifted = _getStreamProviderFor(EventType.REFERENCE_SHIFTED, ReferenceShiftedEvent._cast);
  }

  static DeleteModeType DeleteMode;

  String get deleteMode => $unsafe.callMethod('deleteMode');
  bool get canBeDeleted => $unsafe['canBeDeleted'];
  int get index => $unsafe['index'];
  set index(int i) => $unsafe['index'] = i;
  CollaborativeObject get referencedObject => CollaborativeObject._realtimeTranslator.fromJs($unsafe['referencedObject']);

  Stream<ReferenceShiftedEvent> get onReferenceShifted => _onReferenceShifted.stream;
}
