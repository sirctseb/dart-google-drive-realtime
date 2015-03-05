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

/// A class to create and load realtime documents
abstract class DocumentProvider {
  /// The [Document] provided by this provider. Null until after the future returned by loadDocument completes
  Document get document;

  /**
   *  Load a document which is provided to the returned Future.
   * If this is the first time the document has been loaded, initializeModel is called
   * with Document.model where it can be initialized.
   */
  Future<Document> loadDocument([initializeModel(Model)]);

  /**
   * Export document to json format as returned by drive.realtime.get.
   * See https://developers.google.com/drive/v2/reference/realtime/get
   * The json format is undocumented as of 2013-8-15
   */
  // TODO currently GoogleDocProvider gets from server but Local and Persistent get from local object. is this a problem?
  Future<Map> exportDocument();

  /**
   * Get a function that can be passed to loadDocument that will initialize the
   * model with the contents of the exported model provided.
   *
   * e.g.
   *     // export an old document
   *     oldDocProvider.exportDocument().then((exported) {
   *       // load a new document and initialize with the old document contents
   *       newDocProvider.loadDocument(DocumentProvider.getModelCloner(exported)).then((doc) {
   *         // work with new document
   *       });
   *     });
   *
   * exportedDocument is either a JSON string like exportDocument returns, or a parsed version
   */
  static Function getModelCloner(exportedDocument) {
    if(exportedDocument is String) {
      exportedDocument = JSON.decode(exportedDocument);
    }
    return (_LocalModel model) {
      Map root = exportedDocument['data']['value'];
      var refs = {'root': model.root};
      for(var key in root.keys) {
        model.root[key] = _reviveExportedObject(model, root[key], refs);
      }
    };
  }

  /// Recursively revive an object from exported data
  static dynamic _reviveExportedObject(Model model, Map object, refs) {
    if(object['type'] == 'List') {
      // create collaborative list
      var list = model.createList();
      // add to refs
      refs[object['id']] = list;
      // revive data in list
      for(var element in object['value']) {
        list.push(_reviveExportedObject(model, element, refs));
      }
      return list;
    } else if(object['type'] == 'Map') {
      // create collaborative map
      var map = model.createMap();
      // add to refs
      refs[object['id']] = map;
      // revive data in map
      for(var key in object['value'].keys) {
        map[key] = _reviveExportedObject(model, object['value'][key], refs);
      }
      return map;
    } else if(object['type'] == 'EditableString') {
      // create string
      var string = model.createString(object['value']);
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
      var customObject = model.create(type);
      // add to refs
      refs[object['id']] = customObject;
      // set properties
      for(var key in object['value'].keys) {
        customObject.set(key, _reviveExportedObject(model, object['value'][key], refs));
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
      throw new Exception('Object ${JSON.encode(object)} is not a valid exported object');
    }
  }
}