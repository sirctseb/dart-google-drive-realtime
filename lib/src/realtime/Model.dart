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

  bool get isReadOnly => $unsafe['isReadOnly'];
  bool get canUndo => $unsafe['canUndo'];
  bool get canRedo => $unsafe['canRedo'];

  void beginCreationCompoundOperation() { $unsafe.callMethod('beginCreationCompoundOperation'); }
  void endCompoundOperation() { $unsafe.callMethod('endCompoundOperation'); }
  CollaborativeMap get root => new CollaborativeMap._fromProxy($unsafe.callMethod('getRoot'));
  bool get isInitialized => $unsafe.callMethod('isInitialized');

  void beginCompoundOperation([String name]) => $unsafe.callMethod('beginCompoundOperation',[name]);
  // TODO args? see below old version
  CustomObject create(String name) {
    // create custom object on js side
    var unsafeCustom = $unsafe.callMethod('create', [name]);
    // store id to type association
    // TODO call to getId fails with dart2js
    _storeIdType(realtime['custom']['getId'].apply([unsafeCustom]), name);
    // make realtime backing object
    var backingObject = new _RealtimeCustomObject._fromProxy(unsafeCustom);
    // make CustomObject to return
    var customObject = new CustomObject._byName(name);
    // set internal object
    customObject._internalCustomObject = backingObject;
    // return custom object subclass
    return customObject;
  }
  void _storeIdType(String id, String name) {
    // make sure map exists
    // TODO can we do this during initialization?
    if(!root.containsKey(_RealtimeCustomObject._idToTypeProperty)) {
      root[_RealtimeCustomObject._idToTypeProperty] = createMap();
    }
    // store id to name
    // TODO try to removed these from map when they are removed from the model?
    root[_RealtimeCustomObject._idToTypeProperty][id] = name;
  }
  /*CollaborativeObject create(dynamic/*function(*)|string*/ ref, [List args = const []]) {
    final params = [ref]..addAll(args);
    return new CollaborativeObject._fromProxy($unsafe['create'].apply($unsafe, js.array(params)));
  }*/
  CollaborativeList createList([List initialValue]) => new CollaborativeList._fromProxy($unsafe.callMethod('createList', [initialValue == null ? null : ListToJsArrayAdapter(initialValue, CollaborativeContainer._realtimeTranslator.toJs)]));
  CollaborativeMap createMap([Map initialValue]) => new CollaborativeMap._fromProxy($unsafe.callMethod('createMap', [initialValue == null ? null : MapToJsObjectAdapter(initialValue, CollaborativeContainer._realtimeTranslator.toJs)]));
  CollaborativeString createString([String initialValue]) => new CollaborativeString._fromProxy($unsafe.callMethod('createString', [initialValue]));

  void undo() { $unsafe.callMethod('undo'); }
  void redo() { $unsafe.callMethod('redo'); }

  Stream<UndoRedoStateChangedEvent> get onUndoRedoStateChanged => _onUndoRedoStateChanged.stream;
}
