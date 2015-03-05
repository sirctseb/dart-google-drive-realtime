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
abstract class RemoteDocumentProvider extends LocalDocumentProvider {

  static final Logger _logger = new Logger('remote-document-provider')..level = Level.FINE;

  /// Create a local [Document] which is provided to the returned [Future]
  /// initializeModel is called before the future completes
  Future<Document> loadDocument([initializeModel(Model)]) {
    // get document from peristent storage
    return getDocument().then((retrievedDoc) {
      // create the model
      var model = new _LocalModel();
      // create a document with the model
      _document = new _LocalDocument(model);

      // if retrieved doc is empty, pass normal initializeModel
      if(retrievedDoc == "") {
        _logger.fine('Got document from subclass, empty');
        model._initialize(initializeModel);
        // TODO only do initializeModel if document has never been loaded (where is this recorded)?
      } else {
        _logger.fine('Got document from subclass: $retrievedDoc');
        // otherwise, initialize with json data
        model._initialize(DocumentProvider.getModelCloner(retrievedDoc));
      }
      return _document;
    });
  }


  /**
   *  Load a document from persistent storage.
   *  Called by PersistentDocumentProvider.loadDocument to retrieve the document data.
   */
  // TODO what format does this return?
  Future<String> getDocument();
}