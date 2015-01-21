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

class _LocalModel implements Model {
  _UndoHistory _undoHistory;

  /// Create a local model with a callback
  _LocalModel([initialize]) {
    // TODO js doesn't use createMap for this
    _root = createMap();
    _undoHistory = new _UndoHistory(this);
  }

  _initialize(opt_initializerFn) {
    if(opt_initializerFn != null) {
      _undoHistory.initializeModel(opt_initializerFn, this);
    }
  }

  StreamController<_LocalUndoRedoStateChangedEvent> _onUndoRedoStateChanged =
    new StreamController<_LocalUndoRedoStateChangedEvent>.broadcast(sync: true);

  // TODO is this ever true?
  bool get isReadOnly => false;

  bool get canUndo {
    _LocalDocument._verifyDocument(this);
    return _undoHistory.canUndo;
  }
  bool get canRedo {
    _LocalDocument._verifyDocument(this);
    return _undoHistory.canRedo;
  }

  void endCompoundOperation() {
    _LocalDocument._verifyDocument(this);
    _undoHistory.endCompoundOperation();
  }

  // TODO can't be final because we need to pass this to constructor
  _LocalModelMap _root;
  _LocalModelMap get root {
    _LocalDocument._verifyDocument(this);
    return _root;
  }

  // TODO is this ever false?
  // TODO we should probably provide the same initialization callback method as realtime
  bool get isInitialized {
    _LocalDocument._verifyDocument(this);
    return true;
  }

  void beginCompoundOperation([String name]) {
    _LocalDocument._verifyDocument(this);
    _undoHistory.beginCompoundOperation(Scope.CO);
  }

  CustomObject create(String name) {
    _LocalDocument._verifyDocument(this);
    var backingObject = new _LocalCustomObject(this, name);
    // make CustomObject to return
    var customObject = new CustomObject._byName(name);
    // set internal object
    customObject._internalCustomObject = backingObject;
    // store map from id to model
    _LocalCustomObject._customObjectModels[getId(customObject)] = this;
    // return custom object subclass
    return customObject;
  }
  _LocalModelList createList([List initialValue]) {
    _LocalDocument._verifyDocument(this);
    return new _LocalModelList(this, initialValue);
  }
  _LocalModelMap createMap([Map initialValue]) {
    _LocalDocument._verifyDocument(this);
    return new _LocalModelMap(this, initialValue);
  }
  _LocalModelString createString([String initialValue]) {
    _LocalDocument._verifyDocument(this);
    return new _LocalModelString(this, initialValue);
  }

  void undo() {
    _LocalDocument._verifyDocument(this);
    // TODO check canUndo
    // undo events
    _undoHistory.undo();
  }
  void redo() {
    _LocalDocument._verifyDocument(this);
    // TODO check canRedo
    // redo events
    _undoHistory.redo();
  }

  Stream<UndoRedoStateChangedEvent> get onUndoRedoStateChanged => _onUndoRedoStateChanged.stream;

  /// Local models have no js Proxy
  final js.JsObject $unsafe = null;

  /// Local models have no js Proxy
  dynamic toJs() => null;

  /// JSON serialized data
  Map toJSON() {
    return {
      "appId": "", // TODO
      "revision": 0, // TODO
      "data": root.toJSON()
    };
  }
}
