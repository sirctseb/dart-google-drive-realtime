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

/// A class to create and load documents from Google Drive
class GoogleDocProvider extends DocumentProvider {
  Document get document => _document;
  Document _document;

  /// Load the Google Drive document which is provided to the returned Future.
  /// If this is the first time the document has been loaded, initializeModel is called
  /// with Document.model where it can be initialized.
  Future<Document> loadDocument([initializeModel(Model)]) {

    // check global setup
    return _globalSetup().then((success) {
      // TODO make better state for determining if we need to do a file insert
      if(_newTitle != null) {
        // insert file
        return drive.files.insert(
          new driveclient.File.fromJson({'mimetype': 'application/vnd.google-apps.drive-sdk', 'title': _newTitle})
        ).then((driveclient.File file) {
          // store fileId
          this._fileId = file.id;
          return _doRealtimeLoad(initializeModel);
        });
      } else {
        return _doRealtimeLoad(initializeModel);
      }
    });
  }
  Future<Document> _doRealtimeLoad([initializeModel(Model)]) {
    var completer = new Completer();
    // call realtime load
    realtime['load'](fileId,
      // complete future on file loaded
      new js.Callback.once((p) {
        // TODO document has to be retained. test if it can be released after complete call
        // TODO it looks like relaese/retain don't ref count. release invalidates immediately
        completer.complete(_document = new Document._fromProxy(p)..retain());
      }),
      // pass initializeModel through if supplied
      initializeModel == null ? null : new js.Callback.once((p) => initializeModel(new Model._fromProxy(p))),
      // throw dart error on error
      new js.Callback.once((p) => throw new Error._fromProxy(p))
    );
    return completer.future;
  }

  /// The client ID of the application. Must be set before creating a [GoogleDocProvider]
  static String clientId;

  String _fileId;
  /// The fileId of the provided document
  String get fileId => _fileId;

  /// Create a provider for a given fileId
  GoogleDocProvider(String fileId) : _fileId = fileId;
  String _newTitle;
  /// Create a provider for a new file
  // TODO what options to take? title, mime type, others?
  GoogleDocProvider.newDoc(String title) {
    _newTitle = title;
  }

  // check authentication, create drive client, load relatime api
  Future<bool> _globalSetup() {
    return authenticate().then((auth) {
      _loadDrive();
      return _loadRealtimeApi();
    }).then((realtime) {
      return true;
    });
  }

  // drive client object, set on authorization
  static driveclient.Drive drive;
  /// Create a drive api object
  static void _loadDrive() {
    if(drive != null) return;
    // create drive client object
    drive = new driveclient.Drive(auth);
    // allow it to make authorized requests (I guess. I got it from the examples)
    drive.makeAuthRequests = true;
  }

  // true if the realtime api is loaded
  static js.Proxy realtime;
  /// Load the realtime api
  static Future<js.Proxy> _loadRealtimeApi() {
    var completer = new Completer();

    // TODO can we complete before returning future?
    if(realtime != null) {
      completer.complete(realtime);
      return completer.future;
    }

    // load realtime api
    js.context['gapi']['load']('drive-realtime', new js.Callback.once(() {
      realtime = js.retain(js.context['gapi']['drive']['realtime']);
      completer.complete(realtime);
    }));
    return completer.future;
  }

  /** Authorization object used in GoogleDocProviders
   * If not set using e.e.
   *     GoogleDocProvider.auth = myAuth;
   * then [GoogleDocProvider] will attempt an immediate authentication using GoogleDocProvider.Authenticate
   */
  static GoogleOAuth2 auth;
  /**
   * Establish authorization for GoogleDocProviders
   * The resulting authorization object is stored in GoogleDocProvider.auth
   * The returned future is completed with true if authorization succeeds
   * If a value for immediate is not provided, immediate authentication is attempted,
   *  and pop-up authentication is attempted if immediate fails.
   * If immediate is false, only pop-up authentication is attempted.
   * If immediate it true, only immediate authentication is attempted
   */
  // TODO make private?
  // TODO if not private, document that clientId must be set or allow it to be passed
  static Future<OAuth2> authenticate({bool immediate}) {

    if(clientId == null) {
      return new Future.error(new Exception("GoogleDocProvider.clientId must be set before authenticating"));
    }

    if(auth != null && auth.token != null) {
      return new Future.value(auth);
    }

    // function to install gapi.auth.getToken and continue with createAndLoadFile
    var onTokenLoad = (Token t) {
      // TODO this is not reliable and we may have to switch to js-side authorization
      // overwrite gapi.auth.getToken with a function that
      // returns an object with valid data in access_token
      js.context['gapi']['auth'] = js.map({'getToken':
          new js.Callback.many(() =>
              js.map({
                'access_token': t.data
              }))
      });
    };

    var localAuth = auth;
    if(auth == null) {
      // create auth object
      localAuth = new GoogleOAuth2(
          clientId,
          // TODO what scopes? allow them to be supplied as parameters?
          ['https://www.googleapis.com/auth/drive.install',
           'https://www.googleapis.com/auth/drive.file',
           'openid'],
           // TODO this calls login but doesn't let the exception through
           // so we have to do it with login calls below
           autoLogin: false,
           tokenLoaded: onTokenLoad
      );
      // use separate name for GoogleOAuth to eliminate compiler warnings
      auth = localAuth;
    }
    if(immediate == null) {
      // try silent login
      return localAuth.login(immediate: true).then((ignored) => auth).catchError((obj) {
        // if no immediate auth, show window to get auth
        // let errors here propogate up
        return localAuth.login(immediate: false).then((ignored) => auth);
      });
    } else {
      // try only with immediacy specified by argument
      return localAuth.login(immediate: immediate).then((ignored) => auth);
    }
    return new Future.error(new Exception('Reached unreachable code'));
  }

  Future<String> exportDocument() {

    // use drive.realtime.get to get document export
//    drive.realtime.get(fileId).then((js) => json.stringify(js));

    // TODO workaround for bug in client library
    // http://stackoverflow.com/questions/18001043/why-is-the-response-to-gapi-client-drive-realtime-get-empty
    return HttpRequest.request('https://www.googleapis.com/drive/v2/files/${fileId}/realtime?access_token=${auth.token}',
      method: 'POST')
      .then((HttpRequest req) {
        // TODO error handling
        return req.responseText;
      });
  }
}
