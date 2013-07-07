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
  LocalModel() : root = new LocalModelMap();
  
  // TODO need to make local event
  StreamController<rt.UndoRedoStateChangedEvent> _onUndoRedoStateChanged =
    new StreamController<rt.UndoRedoStateChangedEvent>.broadcast(sync: true);

  // TODO is this ever true?
  bool get isReadOnly => false;
  
  // TODO need to implement undo system
  bool get canUndo => false;
  bool get canRedo => false;

  // TODO need to implement compound operations. meaningful for undo/redo
  // TODO also, what is beginCreationCompoundOperation
  void beginCreationCompoundOperation() {}
  void endCompoundOperation() {}
  
  final LocalModelMap root;
  
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
    // TODO take initial values in constructor
    var list = new LocalModelList();
    if(initialValue != null)
      list.pushAll(initialValue);
    return list;
  }
  LocalModelMap createMap([Map initialValue]) {
    // TODO take initial value in constructor
    var map = new LocalModelMap();
    if(initialValue != null) {
      map.addAll(initialValue);
    }
    return map;
  }
  // TODO implement LocalModelString and return here
  rt.CollaborativeString createString([String initialValue]) {
    return null;
  }

  // TODO implement undo/redo
  void undo() { }
  void redo() { }

  // TODO need to make local event
  Stream<rt.UndoRedoStateChangedEvent> get onUndoRedoStateChanged => _onUndoRedoStateChanged.stream;

  /// Local models have no js Proxy
  final js.Proxy $unsafe = null;

  /// Local models have no js Proxy
  dynamic toJs() => null;
}
