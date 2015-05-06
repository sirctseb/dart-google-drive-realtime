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

  Model._fromProxy(js.JsObject proxy) : super._fromProxy(proxy) {
    _onUndoRedoStateChanged = _getStreamProviderFor(EventType.UNDO_REDO_STATE_CHANGED, UndoRedoStateChangedEvent._cast);
  }

  // TODO I don't think this was supposed to be public on js side
  /*static CollaborativeObject getObject(Model model, String id) {
    print(realtime['Model']);
    return CollaborativeObjectTranslator._fromJs(realtime['Model'].callMethod('getObject', [model.toJs(), id]));
  }*/

  int get bytesUsed => $unsafe['bytesUsed'];

  bool get isReadOnly => $unsafe['isReadOnly'];
  bool get canUndo => $unsafe['canUndo'];
  bool get canRedo => $unsafe['canRedo'];

  void beginCreationCompoundOperation() { $unsafe.callMethod('beginCreationCompoundOperation'); }
  void endCompoundOperation() {
    try {
      $unsafe.callMethod('endCompoundOperation');
    } catch (e) {
      // TODO workaround for passing exceptions through from js
      throw new Exception('Not in a compound operation.');
    }
  }
  CollaborativeMap get root => new CollaborativeMap._fromProxy($unsafe.callMethod('getRoot'));
  bool get isInitialized => $unsafe.callMethod('isInitialized');

  void beginCompoundOperation([String name = '', bool undoable = true]) =>
      $unsafe.callMethod('beginCompoundOperation',[name, undoable]);
  // TODO args? see below old version
  CustomObject create(String name) {
    // create custom object on js side
    var unsafeCustom = $unsafe.callMethod('create', [name]);
    // store id to type association
    // TODO call to getId fails with dart2js
    _storeIdType(realtime['custom']['getId'].apply([unsafeCustom]), name);
    // make CustomObject
    var customObject = new CustomObject._byName(name, unsafeCustom);
    // store id in type map
    CustomObject._registeredTypes[name]['ids'].add(getId(customObject));
    // return custom object subclass
    return customObject;
  }
  void _storeIdType(String id, String name) {
    // make sure map exists
    // TODO can we do this during initialization?
    if(!root.containsKey(CustomObject._idToTypeProperty)) {
      root[CustomObject._idToTypeProperty] = createMap();
    }
    // store id to name
    // TODO try to remove these from map when they are removed from the model?
    root[CustomObject._idToTypeProperty][id] = name;
  }
  CollaborativeList createList([List initialValue]) => new CollaborativeList._fromProxy($unsafe.callMethod('createList', [initialValue == null ? null : ListToJsArrayAdapter(initialValue, CollaborativeObject._realtimeTranslator.toJs)]));
  CollaborativeMap createMap([Map initialValue]) => new CollaborativeMap._fromProxy($unsafe.callMethod('createMap', [initialValue == null ? null : MapToJsObjectAdapter(initialValue, CollaborativeObject._realtimeTranslator.toJs)]));
  CollaborativeString createString([String initialValue]) => new CollaborativeString._fromProxy($unsafe.callMethod('createString', [initialValue]));

  void undo() { $unsafe.callMethod('undo'); }
  void redo() { $unsafe.callMethod('redo'); }

  int get serverRevision => $unsafe['serverRevision'];
  String toJson([String appId, int revision]) {
    return $unsafe.callMethod('toJson', [appId, revision]);
  }

  Stream<UndoRedoStateChangedEvent> get onUndoRedoStateChanged => _onUndoRedoStateChanged.stream;
}
