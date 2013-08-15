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

part of local_realtime_data_model;

class LocalDocument extends LocalRetainable implements rt.Document {
  final LocalModel model;

  void close() {}
  List<rt.Collaborator> get collaborators => [];

  void exportDocument(void successFn([dynamic _]), void failureFn([dynamic _])) {
    try {
      successFn(json.stringify(model.root));
    } catch(e) {
      // TODO is anything passed to the failure function? the exception?
      failureFn(e);
    }
  }

  // TODO we can't access the private stream controller form doc provider
  // TODO we should handle this privacy better
  void changeSaveState(LocalDocumentSaveStateChangedEvent event) {
    _onDocumentSaveStateChanged.add(event);
  }
  // TODO do anything with collaborators?
  StreamController<rt.CollaboratorLeftEvent> _onCollaboratorLeft = new StreamController<rt.CollaboratorLeftEvent>.broadcast();
  StreamController<rt.CollaboratorJoinedEvent> _onCollaboratorJoined = new StreamController<rt.CollaboratorJoinedEvent>.broadcast();
  StreamController<LocalDocumentSaveStateChangedEvent> _onDocumentSaveStateChanged = new StreamController<LocalDocumentSaveStateChangedEvent>.broadcast();
  Stream<rt.CollaboratorLeftEvent> get onCollaboratorLeft => _onCollaboratorLeft.stream;
  Stream<rt.CollaboratorJoinedEvent> get onCollaboratorJoined => _onCollaboratorJoined.stream;
  Stream<rt.DocumentSaveStateChangedEvent> get onDocumentSaveStateChanged => _onDocumentSaveStateChanged.stream;

  LocalDocument(LocalModel this.model);

  /// Local document has no proxy
  final js.Proxy $unsafe = null;
  /// Local document has no proxy
  dynamic toJs() { return null;}
}
