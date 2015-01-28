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

  /// Initialize the model from existing data
  _initializeFromJson(String data) {
    _undoHistory.initializeModel(_createInitializationFunction(data), this);
  }

  /// Create an initialization function to intialize a model from existing data
  static _createInitializationFunction(String data) {
    return (_LocalModel model) {
      var map = json.parse(data);
      Map root = map['data']['value'];
      var refs = {'root': model.root};
      for(var key in root.keys) {
        model.root[key] = model._reviveExportedObject(root[key], refs);
      }
    };
  }

  /// Recursivel revive an object from exported data
  dynamic _reviveExportedObject(Map object, refs) {
    if(object['type'] == 'List') {
      // create collaborative list
      var list = createList();
      // add to refs
      refs[object['id']] = list;
      // revive data in list
      for(var element in object['value']) {
        list.push(_reviveExportedObject(element, refs));
      }
      return list;
    } else if(object['type'] == 'Map') {
      // create collaborative map
      var map = createMap();
      // add to refs
      refs[object['id']] = map;
      // revive data in map
      for(var key in object['value'].keys) {
        map[key] = _reviveExportedObject(object['value'][key], refs);
      }
    } else if(object['type'] == 'EditableString') {
      // create string
      var string = this.createString(object['value']);
      // add to refs
      refs[object['id']] = string;
      return string;
    } else if(object.containsKey('json')) {
      // return native object
      return object['json'];
    } else if(_LocalCustomObject._registeredTypes.containsKey(object['type'])) {
      // revive custom object
      var type = object['type'];
      // create custom object
      var customObject = this.create(type);
      // add to refs
      refs[object['id']] = customObject;
      // set properties
      for(var key in object['value'].keys) {
        customObject.set(key, _reviveExportedObject(object['value'][key], refs));
      }
      // TODO
      // check for onLoadedFn function
      //if(_LocalCustomObject._registeredTypes[type]['onLoadedFn'] != null) {
        // call onLoadedFn
        //TODO from js
        //rdm.CustomObject.customTypes_[type].onLoadedFn.call(customObject);
      //}
      CustomObject._registeredTypes[type]['ids'].add(getId(customObject));
      return customObject;
    } else if(object.containsKey('type')) {
      // if there is a type but it is not registered, throw an error
      throw new Exception('Cannot create collaborative object with unregistered type: ${object['type']}');
    } else if(object.containsKey('ref')) {
      return refs[object['ref']];
    } else {
      throw new Exception('Object ${json.stringify(object)} is not a valid exported object');
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
    // store id in type map
    CustomObject._registeredTypes[name]['ids'].add(getId(customObject));
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
  Map _export() {
    return {
      "appId": "local", // TODO
      "revision": 1, // TODO
      "data": root._export(new Set())
    };
  }
}
