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
  static bool _globallySetup = false;

  static Logger _logger = new Logger("rdm.DocumentProvider.GoogleDocProvider");

  /// Load the Google Drive document which is provided to the returned Future.
  /// If this is the first time the document has been loaded, initializeModel is called
  /// with Document.model where it can be initialized.
  Future<Document> loadDocument([initializeModel(Model)]) {
    _logger.fine('Loading document');

    // check global setup
    _logger.finer('Check global setup');
    return _globalSetup().then((success) {
      _logger.finer('Checked global setup: $success');

      // TODO make better state for determining if we need to do a file insert
      if(_newTitle != null) {
        _logger.fine('Title specified, need to insert file');
        // insert file
        return drive.files.insert(
          new dc.File.fromJson({'mimetype': 'application/vnd.google-apps.drive-sdk', 'title': _newTitle})
        ).then((dc.File file) {
          _logger.fine('Got newly inserted file object, storing id');
          // store fileId
          this._fileId = file.id;
          _logger.fine('Do realtime load with initializer function: $initializeModel');
          return _doRealtimeLoad(initializeModel);
        });
      } else {
        _logger.fine('No title specified, do realtime load with initializer function: $initializeModel');
        return _doRealtimeLoad(initializeModel);
      }
    });
  }
  Future<Document> _doRealtimeLoad([initializeModel(Model)]) {
    _logger.fine('Doing realtime load with initializer function: $initializeModel');
    var completer = new Completer();
    _logger.finer('Do realtime.load with $fileId');
    // call realtime load
    realtime['load'](fileId,
      // complete future on file loaded
      (p) {
        _logger.finest('File loaded callback called, completing future with loaded document');
        // TODO document has to be retained. test if it can be released after complete call
        // TODO it looks like relaese/retain don't ref count. release invalidates immediately
        completer.complete(_document = new Document._fromProxy(p));
      },
      // pass initializeModel through if supplied
      initializeModel == null ? null : (p) => initializeModel(new Model._fromProxy(p)),
      // throw dart error on error
      (p) => throw new Error._fromProxy(p)
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
    _logger.fine('Creating new provider for doc with title $title');
    _newTitle = title;
  }

  // check authentication, create drive client, load realtime api
  static Future<bool> _globalSetup() {
    // complete if already setup
    if(_globallySetup) return new Future.value(true);

    _logger.finer('Doing global setup: authenticate first');
    return authenticate().then((auth) {
      _logger.finer('Global setup: authenticated, load drive');
      _loadDrive();
      _logger.finer('Global setup: loaded drive, load realtime api');
      return _loadRealtimeApi();
    }).then((realtime) {
      _logger.finer('Global setup: realtime loaded, returning success');
      _globallySetup = true;
      return true;
    });
  }

  // drive client object, set on authorization
  static dcbrowser.Drive drive;
  /// Create a drive api object
  static void _loadDrive() {
    _logger.fine('Loading drive if not already loaded');
    if(drive != null) return;
    _logger.finer('Drive not yet loaded, creating client');
    // create drive client object
    drive = new dcbrowser.Drive(auth);
    // allow it to make authorized requests (TODO I guess. I got it from the examples)
    drive.makeAuthRequests = true;
    _logger.finer('Drive client created: $drive');
  }

  // true if the realtime api is loaded
  static js.Proxy realtime;
  /// Load the realtime api
  static Future<js.Proxy> _loadRealtimeApi() {
    _logger.fine('Loading realtime api');
    var completer = new Completer();

    if(realtime != null) {
      _logger.fine('Realtime already loaded, completing with object');
      completer.complete(realtime);
      return completer.future;
    }

    // load realtime api
    _logger.fine('Call gapi.load("drive-realtime"...)');
    js.context['gapi']['load']('drive-realtime', () {
      _logger.fine('Got gapi.load callback, retaining realtime object and completing');
      realtime = js.context['gapi']['drive']['realtime'];
      completer.complete(realtime);
    });
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
    _logger.fine('Authenticating with immediate: $immediate');

    if(clientId == null) {
      _logger.warning('GoogleDocProvider.clientId not set, unable to authenticate');
      return new Future.error(new Exception("GoogleDocProvider.clientId must be set before authenticating"));
    }

    if(auth != null && auth.token != null) {
      _logger.fine('Already authenticated with token: ${auth.token}, returning existing auth object');
      return new Future.value(auth);
    }

    // function to install gapi.auth.getToken and continue with createAndLoadFile
    var onTokenLoad = (Token t) {
      _logger.fine('Got onTokenLoad callback, storing on js side');
      // TODO this is not reliable and we may have to switch to js-side authorization
      // overwrite gapi.auth.getToken with a function that
      // returns an object with valid data in access_token
      js.context['gapi']['auth'] = js.map({'getToken':
          () => js.map({'access_token': t.data})
      });
    };

    var localAuth = auth;
    if(auth == null) {
      _logger.fine('Auth object not yet set, creating GoogleOAuth2');
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
      _logger.fine('Auth object $auth created and stored in GoogleDocProvider.auth');
    }
    if(immediate == null) {
      _logger.fine('immediate not set, try silent login first');
      // try silent login
      return localAuth.login(immediate: true).then((ignored) => auth).catchError((obj) {
        _logger.fine('Silent login failed, try popup login', obj);
        // if no immediate auth, show window to get auth
        // let errors here propogate up
        return localAuth.login(immediate: false).then((ignored) => auth);
      });
    } else {
      _logger.fine('Try login with immediate: $immediate');
      // try only with immediacy specified by argument
      return localAuth.login(immediate: immediate).then((ignored) => auth);
    }
    return new Future.error(new Exception('Reached unreachable code'));
  }

  Future<String> exportDocument() {
    _logger.fine('Exporting document');

    // use drive.realtime.get to get document export
//    drive.realtime.get(fileId).then((js) => json.stringify(js));

    // TODO workaround for bug in client library
    // http://stackoverflow.com/questions/18001043/why-is-the-response-to-gapi-client-drive-realtime-get-empty
    _logger.finer('Using HttpRequest.request workaround for realtime.get bug');
    return HttpRequest.request('https://www.googleapis.com/drive/v2/files/${fileId}/realtime?access_token=${auth.token}',
      method: 'POST')
      .then((HttpRequest req) {
        _logger.finest('Got exported document text: ${req.responseText}');
        // TODO error handling
        return req.responseText;
      });
  }

  void registerType(Type type, String name, List fields) {
    // make sure js drive stuff is loaded
    _globalSetup().then((bool success) {
      // store the dart type, js type, and fields
      _RealtimeCustomObject._registeredTypes[name] = {
                                // TODO is this the best way to just create a js function?
                               'js-type': new js.FunctionProxy.withThis((p) {}),
                               'fields': fields};
      CustomObject._registeredTypes[name] = {'dart-type': type};
      // do the js-side registration
      realtimeCustom.registerType(_RealtimeCustomObject._registeredTypes[name]["js-type"], name);
      // add fields
      for(var field in fields) {
        _RealtimeCustomObject._registeredTypes[name]['js-type']['prototype'][field] = realtimeCustom['collaborativeField'](field);
      }
    });
  }

  static bool _isCustomObject(dynamic object) {
    return object is CustomObject && object._isRealtimeCustomObject;
  }
}
