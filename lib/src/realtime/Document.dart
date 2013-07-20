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

class Document extends EventTarget {
  SubscribeStreamProvider<CollaboratorLeftEvent> _onCollaboratorLeft;
  SubscribeStreamProvider<CollaboratorJoinedEvent> _onCollaboratorJoined;
  SubscribeStreamProvider<DocumentSaveStateChangedEvent> _onDocumentSaveStateChanged;

  Document._fromProxy(js.Proxy proxy) : super._fromProxy(proxy) {
    _onCollaboratorLeft = _getStreamProviderFor(EventType.COLLABORATOR_LEFT, CollaboratorLeftEvent._cast);
    _onCollaboratorJoined = _getStreamProviderFor(EventType.COLLABORATOR_JOINED, CollaboratorJoinedEvent._cast);
    _onDocumentSaveStateChanged = _getStreamProviderFor(EventType.DOCUMENT_SAVE_STATE_CHANGED, DocumentSaveStateChangedEvent._cast);
  }

  void close() { $unsafe.close(); }
  List<Collaborator> get collaborators => jsw.JsArrayToListAdapter.castListOfSerializables($unsafe.getCollaborators(), Collaborator._cast);
  Model get model => new Model._fromProxy($unsafe.getModel());

  void exportDocument(void successFn([dynamic _]), void failureFn([dynamic _])) => $unsafe.exportDocument(new js.Callback.once(successFn), new js.Callback.once(failureFn));

  Stream<CollaboratorLeftEvent> get onCollaboratorLeft => _onCollaboratorLeft.stream;
  Stream<CollaboratorJoinedEvent> get onCollaboratorJoined => _onCollaboratorJoined.stream;
  Stream<DocumentSaveStateChangedEvent> get onDocumentSaveStateChanged => _onDocumentSaveStateChanged.stream;
}
