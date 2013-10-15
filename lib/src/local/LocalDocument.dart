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

class _LocalDocument extends _LocalRetainable implements Document {
  final _LocalModel model;

  void close() {}
  List<Collaborator> get collaborators => [];

  void exportDocument(void successFn([dynamic _]), void failureFn([dynamic _])) {
    try {
      successFn(json.stringify(model.root));
    } catch(e) {
      // TODO is anything passed to the failure function? the exception?
      failureFn(e);
    }
  }

  // TODO do anything with collaborators?
  // TODO we're overriding _on* with the wrong type in the local classes, giving us analyzer warnings
  // TODO we could use different variable names and set these to null to remove warnings
  // TODO OR we could subclass SubscribeStreamProvider and override the stream accessor using normal StreamController,
  // TODO but then it's not really a SubscribeStreamProvider
  // TODO OR we could just use SubscribeStreamProvider as is, but we don't need the functionality, and it makes a stream controller on each stream access
  StreamController<CollaboratorLeftEvent> _onCollaboratorLeft = new StreamController<CollaboratorLeftEvent>.broadcast();
  StreamController<CollaboratorJoinedEvent> _onCollaboratorJoined = new StreamController<CollaboratorJoinedEvent>.broadcast();
  StreamController<_LocalDocumentSaveStateChangedEvent> _onDocumentSaveStateChanged = new StreamController<_LocalDocumentSaveStateChangedEvent>.broadcast();
  Stream<CollaboratorLeftEvent> get onCollaboratorLeft => _onCollaboratorLeft.stream;
  Stream<CollaboratorJoinedEvent> get onCollaboratorJoined => _onCollaboratorJoined.stream;
  Stream<DocumentSaveStateChangedEvent> get onDocumentSaveStateChanged => _onDocumentSaveStateChanged.stream;

  _LocalDocument(_LocalModel this.model);

  /// Local document has no proxy
  final js.Proxy $unsafe = null;
  /// Local document has no proxy
  dynamic toJs() { return null;}
}
