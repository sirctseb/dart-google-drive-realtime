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

/// A class to create local documents with no persistence
class LocalDocumentProvider extends DocumentProvider {
  Document get document => _document;
  Document _document;
  String _initData;

  /// Create a local [Document] which is provided to the returned [Future]
  /// initializeModel is called before the future completes
  Future<Document> loadDocument([initializeModel(Model)]) {
    // TODO this now depends on having realtime api loaded
    // TODO _initData != null case, use loadFromJson
    var completer = new Completer();

    //if(_initData != null) {
      //model._initialize(DocumentProvider.getModelCloner(_initData));
    //} else {
      realtime['newInMemoryDocument'].apply([
        // complete future on file loaded
        (p) {
          completer.complete(_document = new Document._fromProxy(p));
        },
        // pass initializeModel through if supplied
        initializeModel == null ? null : (p) => initializeModel(new Model._fromProxy(p)),
        // throw dart error on error
        (p) => throw new Error._fromProxy(p)]);
    //}
    return completer.future;
  }

  Future<Map> exportDocument() {
    // TODO
    return new Future.value(null);
    //return new Future.value(_document.model.toJson());
  }

  static bool _isCustomObject(dynamic object) {
    return object is CustomObject && object._isLocalCustomObject;
  }

  LocalDocumentProvider([String data]) {
    _initData = data;
  }
}