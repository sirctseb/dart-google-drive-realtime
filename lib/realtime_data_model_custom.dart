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

final realtimeCustom = realtime['custom'];

/**
 * Register a custom object type. Must be called before [DocumentProvider.loadDocument].
 * Type must be a subclass of [CustomObject].
 *
 * e.g.
 *     class Book extends CustomObject {
 *       final static NAME = 'Book';
 *     }
 *     registerType(Book, Book.NAME);
 *     collaborativeField(Book.NAME, 'title');
 *     collaborativeField(Bool.NAME, 'author');
 *     docProvider.loadDocument().then((doc) {
 *       Book book = doc.model.create('Book');
 *       doc.model.root['book'] = book;
 *     });
 */
void registerType(Type type, String name) {
  // store dart type
  CustomObject._registeredTypes[name] = {'dart-type': type, 'ids': []};

  // do google registration
  if(GoogleDocProvider._globallySetup) {
    // store the js type and fields
    CustomObject._registeredTypes[name]['js-type'] = new js.JsFunction.withThis((p) {});
    CustomObject._registeredTypes[name]['fields'] = [];
    // do the js-side registration
    realtimeCustom['registerType'].apply([CustomObject._registeredTypes[name]["js-type"], name]);
  }
}

void collaborativeField(String name, String field) {
  // add field google-side
  if(GoogleDocProvider._globallySetup) {
    CustomObject._registeredTypes[name]['js-type']['prototype'][field] = realtimeCustom['collaborativeField'].apply([field]);
    CustomObject._registeredTypes[name]['fields'].add(field);
  }
}

String getId(dynamic obj) {
  // TODO should really only be dart wrappers except from type promoter
  obj = obj is js.JsObject ? obj : obj.$unsafe;
  if(GoogleDocProvider._globallySetup && isCustomObject(obj)) {
    return realtimeCustom['getId'].apply([obj]);
  }
  throw new Exception('Object $obj is not a custom object');
}

Model getModel(dynamic obj) {
  if(isCustomObject(obj)) {
    return obj._model;
  }
  throw new Exception('Object $obj is not a custom object');
}

bool isCustomObject(dynamic obj) {
  // TODO should really only be dart wrappers except from type promoter
  obj = obj is js.JsObject ? obj : obj.$unsafe;
  return (GoogleDocProvider._globallySetup && realtimeCustom['isCustomObject'].apply([obj]));
}

// TODO have subclasses just override methods instead of registration (why doesn't that work on js side also?)
void setInitializer(String name, Function initialize) {
  // do google-side registration
  if(GoogleDocProvider._globallySetup) {
    realtimeCustom.setInitializer(name, initialize);
  }
}

void setOnLoaded(String name, [Function onLoaded]) {
  // do google-side registration
  if(GoogleDocProvider._globallySetup) {
    realtimeCustom.setOnLoaded(name, onLoaded);
  }
}