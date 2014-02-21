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

  /// Create a local [Document] which is provided to the returned [Future]
  /// initializeModel is called before the future completes
  Future<Document> loadDocument([initializeModel(Model)]) {
    var model = new _LocalModel(initializeModel);
    // create a document with the model
    var document = new _LocalDocument(model);
    _document = document;
    var completer = new Completer();
    // complete with document
    completer.complete(document);
    return completer.future;
  }

  Future<String> exportDocument() {
    return new Future.value(json.stringify((_document.model as _LocalModel).toJSON()));
  }

  void registerType(Type type, String name, List fields) {
    _LocalCustomObject._registeredTypes[name] =
      {'fields': fields};
    CustomObject._registeredTypes[name] = {'dart-type': type};
  }

  static bool _isCustomObject(dynamic object) {
    return object is CustomObject && object._isLocalCustomObject;
  }
}