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
    return globalSetup().then((success) {
      _logger.finer('Checked global setup: $success');

      if(_fileId == null) {
        _logger.fine('no fileId yet, need to insert file');
        // insert file
        return driveApi.files.insert(
          new drive.File.fromJson({'mimetype': 'application/vnd.google-apps.drive-sdk', 'title': _newTitle})
        ).then((drive.File file) {
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
    realtime['load'].apply([fileId,
      // complete future on file loaded
      (p) {
        _logger.finest('File loaded callback called, completing future with loaded document');
        completer.complete(_document = new Document._fromProxy(p));
      },
      // pass initializeModel through if supplied
      initializeModel == null ? null : (p) => initializeModel(new Model._fromProxy(p)),
      // throw dart error on error
      (p) => throw new Error._fromProxy(p)]
    );
    return completer.future;
  }

  /// The client ID of the application. Must be set before creating a [GoogleDocProvider]
  static auth.ClientId identifier;
  static void setClientId(String id) {
    identifier = new auth.ClientId(id, null);
  }

  // TODO what scopes? allow them to be supplied as parameters?
  static final scopes = [drive.DriveApi.DriveFileScope];
  // TODO old scopes used:
  /*final scopes = ['https://www.googleapis.com/auth/drive.install',
                  'https://www.googleapis.com/auth/drive.file',
                  'openid'];*/

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
  static Future<bool> globalSetup() {
    // complete if already setup
    if(_globallySetup) return new Future.value(true);

    _logger.finer('Doing global setup: authenticate first');
    return authenticate().then((authClient) {
      _logger.finer('Global setup: authenticated, load drive');
      _loadDrive(authClient);
      _logger.finer('Global setup: loaded drive, load realtime api');
      return _loadRealtimeApi();
    }).then((realtime) {
      _logger.finer('Global setup: realtime loaded, returning success');
      _globallySetup = true;
      return true;
    });
  }

  // drive client object, set on authorization
  static auth.AutoRefreshingAuthClient authClient;
  static drive.DriveApi driveApi;
  /// Create a drive api object
  static void _loadDrive(auth.AutoRefreshingAuthClient client) {
    // store client
    authClient = client;
    _logger.fine('Loading drive if not already loaded');
    if(driveApi != null) return;
    _logger.finer('Drive not yet loaded, creating client');
    // create drive client object
    driveApi = new drive.DriveApi(client);
    _logger.finer('Drive client created: $driveApi');
  }

  // true if the realtime api is loaded
  static js.JsObject realtime;
  /// Load the realtime api
  static Future<js.JsObject> _loadRealtimeApi() {
    _logger.fine('Loading realtime api');
    var completer = new Completer();

    if(realtime != null) {
      _logger.fine('Realtime already loaded, completing with object');
      completer.complete(realtime);
      return completer.future;
    }

    // load realtime api
    _logger.fine('Call gapi.load("drive-realtime"...)');
    js.context['gapi']['load'].apply(['drive-realtime', () {
      _logger.fine('Got gapi.load callback, retaining realtime object and completing');
      realtime = js.context['gapi']['drive']['realtime'];
      completer.complete(realtime);
    }]);
    return completer.future;
  }


  static auth.BrowserOAuth2Flow _flow;
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
  static Future<auth.AutoRefreshingAuthClient> authenticate({bool immediate: true}) {
    _logger.fine('Authenticating with immediate: $immediate');

    if(identifier == null) {
      _logger.warning('GoogleDocProvider.clientId not set, unable to authenticate');
      return new Future.error(new Exception("GoogleDocProvider.clientId must be set before authenticating"));
    }

    if (_flow == null) {
      return auth.createImplicitBrowserFlow(identifier, scopes)
            .then((auth.BrowserOAuth2Flow flow) {
            // store flow
            _flow = flow;
            return flow.clientViaUserConsent(immediate: immediate);
      });
    } else {
      return _flow.clientViaUserConsent(immediate: immediate);
    }
  }

  Future<Map> exportDocument() {
    _logger.fine('Exporting document');

    // use drive.realtime.get to get document export
//    drive.realtime.get(fileId).then((js) => json.stringify(js));
    /*return driveApi.realtime.get(fileId).then((response) {
      return json.parse(response);
    });*/

    // TODO workaround for bug in client library
    // http://stackoverflow.com/questions/18001043/why-is-the-response-to-gapi-client-drive-realtime-get-empty
    _logger.finer('Using HttpRequest.request workaround for realtime.get bug');
    return HttpRequest.request('https://www.googleapis.com/drive/v2/files/${fileId}/realtime',
      method: 'GET',
      requestHeaders: {'Authorization': 'Bearer ${authClient.credentials.accessToken.data}'})
      .then((HttpRequest req) {
        _logger.finest('Got exported document text: ${req.responseText}');
        // TODO error handling
        return JSON.decode(req.responseText);
      });
  }

  static void debug() {
    realtime['debug'].apply([]);
  }

  static void enableTestMode() {
    realtime['enableTestMode'].apply([]);
  }

  static Document loadFromJson(String json, [opt_errorFn]) {
    return new Document._fromProxy(realtime['loadFromJson'].apply([json, opt_errorFn]));
  }
}
