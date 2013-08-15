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
  /// Load a document which is provided to the returned Future.
  /// If this is the first time the document has been loaded, initializeModel is called
  /// with Document.model where it can be initialized.
  Future<Document> loadDocument([initializeModel(Model)]);
}