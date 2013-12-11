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

class Model extends EventTarget {
  SubscribeStreamProvider<UndoRedoStateChangedEvent> _onUndoRedoStateChanged;

  // TODO this should not be public but the custom library needs to be able to make a model from a proxy
  Model.fromProxy(js.Proxy proxy) : this._fromProxy(proxy);
  Model._fromProxy(js.Proxy proxy) : super._fromProxy(proxy) {
    _onUndoRedoStateChanged = _getStreamProviderFor(EventType.UNDO_REDO_STATE_CHANGED, UndoRedoStateChangedEvent._cast);
  }

  bool get isReadOnly => $unsafe['isReadOnly'];
  bool get canUndo => $unsafe['canUndo'];
  bool get canRedo => $unsafe['canRedo'];

  void beginCreationCompoundOperation() { $unsafe.beginCreationCompoundOperation(); }
  void endCompoundOperation() { $unsafe.endCompoundOperation(); }
  CollaborativeMap get root => new CollaborativeMap._fromProxy($unsafe.getRoot());
  bool get isInitialized => $unsafe.isInitialized();

  void beginCompoundOperation([String name]) => $unsafe.beginCompoundOperation(name);
  // TODO args? see below old version
  CustomObject create(String name) {
    return new CustomObject._fromProxy($unsafe['create'](name));
  }
  /*CollaborativeObject create(dynamic/*function(*)|string*/ ref, [List args = const []]) {
    final params = [ref]..addAll(args);
    return new CollaborativeObject._fromProxy($unsafe['create'].apply($unsafe, js.array(params)));
  }*/
  CollaborativeList createList([List initialValue]) => new CollaborativeList._fromProxy($unsafe.createList(initialValue == null ? null : initialValue is js.Serializable<js.Proxy> ? initialValue : js.array(initialValue)));
  CollaborativeMap createMap([Map initialValue]) => new CollaborativeMap._fromProxy($unsafe.createMap(initialValue == null ? null : initialValue is js.Serializable<js.Proxy> ? initialValue : js.map(initialValue)));
  CollaborativeString createString([String initialValue]) => new CollaborativeString._fromProxy($unsafe.createString(initialValue));

  void undo() { $unsafe.undo(); }
  void redo() { $unsafe.redo(); }

  Stream<UndoRedoStateChangedEvent> get onUndoRedoStateChanged => _onUndoRedoStateChanged.stream;
}
