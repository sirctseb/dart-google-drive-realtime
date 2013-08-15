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
  Future<String> exportDocument();
}