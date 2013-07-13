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

class LocalModel implements rt.Model {
  UndoHistory _undoHistory;

  // TODO sit would be better to include Document in the interface
  // TODO and have the model created automatically with the same callback style
  LocalModel([initialize]) {
    _undoHistory = new UndoHistory(root);
    if(initialize != null) {
      _undoHistory.initializeModel(initialize, this);
    }
  }

  // TODO need to make local event
  StreamController<LocalUndoRedoStateChangedEvent> _onUndoRedoStateChanged =
    new StreamController<LocalUndoRedoStateChangedEvent>.broadcast(sync: true);

  // TODO is this ever true?
  bool get isReadOnly => false;

  // TODO need to implement undo system
  bool get canUndo => _undoHistory.canUndo;
  bool get canRedo => _undoHistory.canRedo;

  // TODO need to implement compound operations. meaningful for undo/redo
  // TODO also, what is beginCreationCompoundOperation
  void beginCreationCompoundOperation() {}
  void endCompoundOperation() {}

  final LocalModelMap root = new LocalModelMap();

  // TODO is this ever false?
  // TODO we should probably provide the same initialization callback method as realtime
  bool get isInitialized => true;

  // TODO need to implement compound operations. meaningful for undo/redo
  void beginCompoundOperation([String name]) {}
  // TODO implement LocalModelObject and return here
  rt.CollaborativeObject create(dynamic/*function(*)|string*/ ref, [List args = const []]) {
    return null;
  }
  LocalModelList createList([List initialValue]) {
    return new LocalModelList(initialValue);
  }
  LocalModelMap createMap([Map initialValue]) {
    // TODO take initial value in constructor
    return new LocalModelMap(initialValue);
  }
  LocalModelString createString([String initialValue]) {
    return new LocalModelString(initialValue);
  }

  // TODO implement undo/redo
  void undo() {
    // TODO check canUndo
    // undo events
    _undoHistory.undo();
  }
  void redo() {
    // TODO check canRedo
    // redo events
    _undoHistory.redo();
  }

  // TODO need to make local event
  Stream<rt.UndoRedoStateChangedEvent> get onUndoRedoStateChanged => _onUndoRedoStateChanged.stream;

  /// Local models have no js Proxy
  final js.Proxy $unsafe = null;

  /// Local models have no js Proxy
  dynamic toJs() => null;
}
