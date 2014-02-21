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

// TODO check for google api loaded before doing google-side things
// TODO registration can now be in one place since we register on both

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
  CustomObject._registeredTypes[name] = {'dart-type': type};

  // do google registration
  // make sure js drive stuff is loaded
  GoogleDocProvider._globalSetup().then((bool success) {
    // store the js type and fields
    _RealtimeCustomObject._registeredTypes[name] = {
                              // TODO is this the best way to just create a js function?
                             'js-type': new js.FunctionProxy.withThis((p) {}),
                             'fields': []};
    // do the js-side registration
    realtimeCustom.registerType(_RealtimeCustomObject._registeredTypes[name]["js-type"], name);
  });

  // do local registration
  _LocalCustomObject._registeredTypes[name] = {'fields': []};
}

void collaborativeField(String name, String field) {
  // add field google-side
  _RealtimeCustomObject._registeredTypes[name]['js-type']['prototype'][field] = realtimeCustom['collaborativeField'](field);
  _RealtimeCustomObject._registeredTypes[name]['fields'].add(field);

  // add field locally
  _LocalCustomObject._registeredTypes[name]['fields'].add(field);
}

String getId(dynamic obj) {
  if(GoogleDocProvider._isCustomObject(obj)) {
    return realtimeCustom.getId(obj);
  } else if(LocalDocumentProvider._isCustomObject(obj)) {
    // TODO should refactor so id accessor is not in custom object
    return obj._internalCustomObject.id;
  }
  throw new Exception('Object $obj is not a custom object');
}

Model getModel(dynamic obj) {
  if(GoogleDocProvider._isCustomObject(obj) || LocalDocumentProvider._isCustomObject(obj)) {
    return obj._model;
  }
  throw new Exception('Object $obj is not a custom object');
}

bool isCustomObject(dynamic obj) {
  return GoogleDocProvider._isCustomObject(obj) || LocalDocumentProvider._isCustomObject(obj);
}

// TODO have subclasses just override methods instead of registration (why doesn't that work on js side also?)
void setInitializer(String name, Function initialize) {
  // do google-side registration
  realtimeCustom.setInitializer(name, initialize);

  // store on local side
  _LocalCustomObject._registeredTypes[name]['initializerFn'] = initialize;
}

void setOnLoaded(String name, [Function onLoaded]) {
  // do google-side registration
  realtimeCustom.setOnLoaded(name, onLoaded);

  // store on local side
  _LocalCustomObject._registeredTypes[name]['onLoadedFn'] = onLoaded;
}