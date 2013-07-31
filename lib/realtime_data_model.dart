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

library realtime_data_model;

import 'dart:async';
import 'dart:collection';
import 'dart:json' as json;

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:meta/meta.dart';
import 'package:realtime_data_model/src/local/local_realtime_data_model.dart';
import 'package:google_oauth2_client/google_oauth2_browser.dart';
import 'package:google_drive_v2_api/drive_v2_api_browser.dart' as driveclient;
import 'package:google_drive_v2_api/drive_v2_api_client.dart' as driveclient;

import 'src/utils.dart';

part 'src/realtime/BaseModelEvent.dart';
part 'src/realtime/CollaborativeContainer.dart';
part 'src/realtime/CollaborativeList.dart';
part 'src/realtime/CollaborativeMap.dart';
part 'src/realtime/CollaborativeObject.dart';
part 'src/realtime/CollaborativeString.dart';
part 'src/realtime/Collaborator.dart';
part 'src/realtime/CollaboratorJoinedEvent.dart';
part 'src/realtime/CollaboratorLeftEvent.dart';
part 'src/realtime/Document.dart';
part 'src/realtime/DocumentClosedError.dart';
part 'src/realtime/DocumentSaveStateChangedEvent.dart';
part 'src/realtime/Error.dart';
part 'src/realtime/EventTarget.dart';
part 'src/realtime/IndexReference.dart';
part 'src/realtime/Model.dart';
part 'src/realtime/ObjectChangedEvent.dart';
part 'src/realtime/ReferenceShiftedEvent.dart';
part 'src/realtime/Retainable.dart';
part 'src/realtime/TextDeletedEvent.dart';
part 'src/realtime/TextInsertedEvent.dart';
part 'src/realtime/TypePromoter.dart';
part 'src/realtime/ValueChangedEvent.dart';
part 'src/realtime/ValuesAddedEvent.dart';
part 'src/realtime/ValuesRemovedEvent.dart';
part 'src/realtime/ValuesSetEvent.dart';
part 'src/realtime/UndoRedoStateChangedEvent.dart';
part 'src/realtime/error_type.dart';
part 'src/realtime/event_type.dart';

// js.Proxy for "gapi.drive.realtime"
final realtime = js.retain(js.context['gapi']['drive']['realtime']);

String get token => realtime['getToken']();

// load a realtime object for a file with the given id
void load(String docId,
  [void onFileLoaded(Document document),
   void initializeModel(Model model),
   void errorFn(Error error)]) {
  realtime.load(docId,
      onFileLoaded == null ? null : new js.Callback.once((p) => onFileLoaded(new Document._fromProxy(p))),
      initializeModel == null ? null : new js.Callback.once((p) => initializeModel(new Model._fromProxy(p))),
      errorFn == null ? null : new js.Callback.once((p) => errorFn(new Error._fromProxy(p)))
  );
}


/** Starts the realtime system
 * If local is false, uses realtime-client-utils.js method for creating a new realtime-connected document
 * If local is true, a new local model will be created
 */
void start(Map realtimeOptions, {bool local: false}) {
  if(local) {
    var model = new LocalModel(realtimeOptions['initializeModel']);
    // create a document with the model
    var document = new LocalDocument(model);
    // do onFileLoaded callback
    realtimeOptions["onFileLoaded"](document);
  } else {
    // function to create a Drive file and load the realtime object
    // using an existing OAuth2 object
    var createAndLoadFile = (OAuth2 auth) {
      // create drive api object
      var drive = new driveclient.Drive(auth);
      // allow it to make authorized requests (I guess. I got it from the examples)
      drive.makeAuthRequests = true;
      // insert a new file
      drive.files.insert(
        new driveclient.File.fromJson({'mimetype': 'application/vnd.google-apps.drive-sdk', 'title': 'tabasci tab'})
      ).then((driveclient.File file) {
          // load realtime object for the file
          load(file.id, realtimeOptions['onFileLoaded'], realtimeOptions['initializeModel']);
      }).catchError((obj) {
        print('file insert failed: $obj');
      });
    };

    // load realtime api before starting
    js.context['gapi']['load']('drive-realtime', new js.Callback.once(() {

      // TODO realtime library checks gapi.auth.getToken().access_token for authentication,
      // so we need to do one of two things:
      // 1. authenticate on the javascript side and let gapi.auth set itself up, or
      // 2. authenticate on the dart side and set gapi.auth.getToken to a function
      //    that returns an object with a valid access_token

      int ofTheTwoThings = 1;

      if(ofTheTwoThings == 1) {
        // 1:
        // load js auth client library
        js.context['gapi']['load']('auth:client', new js.Callback.once(() {
          // authorize on js side
          js.context['gapi']['auth']['authorize'](js.map({
              'client_id': '1066816720974',
              'scope': ['https://www.googleapis.com/auth/drive.install',
                        'https://www.googleapis.com/auth/drive.file',
                        'openid'],
              'immediate': true
            }), new js.Callback.once((p){
              // continue creating and loading the file
              createAndLoadFile(new SimpleOAuth2(js.context['gapi']['auth']['getToken']()['access_token']));
              // TODO there should also be a handler for the case where the immediate auth doesn't
              // go through and does the pop-up authentication
          }));
        }));
      } else {
        // 2:
        // create auth object
        var dartAuth = new GoogleOAuth2(
          '1066816720974.apps.googleusercontent.com',
          ['https://www.googleapis.com/auth/drive.install',
           'https://www.googleapis.com/auth/drive.file',
           'openid'],
          // TODO this calls login but doesn't let the exception through
          // so we have to do it with login calls below
          autoLogin: false
        );
        // function to install gapi.auth.getToken and continue with createAndLoadFile
        var onTokenLoad = (Token t) {
          // overwrite gapi.auth.getToken with a function that
          // returns an object with valid data in access_token
          js.context['gapi']['auth'] = js.map({
            'getToken':
              new js.Callback.many(() =>
                js.map({
                  'access_token': t.data
                }))
          });
          // continue with creating a drive file and loading realtime object
          createAndLoadFile(dartAuth);
        };
        // try silent login
        dartAuth.login(immediate: true).then(onTokenLoad).catchError((obj) {
          // if no immediate auth, show window to get auth
          dartAuth.login(immediate: false).then(onTokenLoad).catchError((obj) {
            print('authentication failue');
          });
        });
      }
    }));
  }
}


