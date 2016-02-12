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

// TODO put strategies in different file
/// A class to determine when document changes should be saved to persistent storage
abstract class BatchStrategy {
  /// Create a [BatchStrategy] for a model
  BatchStrategy(Model model) {
    model.root.onObjectChanged.listen(modelChanged);
  }

  /**
   * Called when the model receives a change event.
   */
  void modelChanged(ObjectChangedEvent event);

  /**
   * Causes an item to be added to saveStream, indicating that document changes should be
   * saved to persistent storage.
   */
  void save() => _saveStreamController.add(true);

  /**
   * A stream that emits true when document changes should be saved to persistent storage
   */
  // TODO strategy needs to know if save is in progress so it can delay, or needs to be told
  // TODO that a save failed because one was already in progress. we could make it a callback
  // TODO instead of a stream to achieve the latter.
  // TODO for the former we could pass the document to constructor instead of the model
  // TODO and strategy can check for save state
  Stream<bool> get saveStream => _saveStreamController.stream;
  StreamController<bool> _saveStreamController = new StreamController<bool>();
}

/// A strategy class to save immediately on every modification
class ImmediateStrategy extends BatchStrategy {
  ImmediateStrategy(Model model) : super(model);
  // save on every change
  void modelChanged(e) => save();
}

/// A strategy class that waits for a given duration after the last modification to save
class DelayStrategy extends BatchStrategy {
  /// The duration of time to wait after the last modification
  Duration duration;

  bool _modelChangedDuringSave = false;

  /// Create a strategy with a given delay duration
  DelayStrategy(Model model, this.duration) : super(model);

  /// Save after a given amount of time has passed since the last modification
  void modelChanged(ObjectChangedEvent event) {
    if (_sinceLastModification == null) {
      _sinceLastModification = new Timer(duration, _onSaveTimer);
    } else {
      _modelChangedDuringSave = true;
    }
  }

  void _onSaveTimer() {
    if (_modelChangedDuringSave) {
      _modelChangedDuringSave = false;
      // start a new save timer
      _sinceLastModification = new Timer(duration, _onSaveTimer);
    } else {
      _sinceLastModification = null;
      save();
    }
  }

  // the timer that counts since the last modification
  Timer _sinceLastModification;
}

/// Like DocumentSaveStateChangedEvent but with isPending, when changes have
/// been made to the document but not sent to the server
class PersistentDocumentSaveStateChangedEvent
    implements DocumentSaveStateChangedEvent {
  final bool isPending;
  final bool isSaving;
  final Document target;
  final String type;

  PersistentDocumentSaveStateChangedEvent(
      this.isPending, this.isSaving, this.target, this.type);

  // define js-backed fields for the analyzer
  js.JsObject $unsafe;
  toJs() => null;
}

/// A class to provide non Google Drive documents with persistence
abstract class PersistentDocumentProvider extends RemoteDocumentProvider {
  /// The strategy to determine when document changes should be saved
  BatchStrategy get batchStrategy => _batchStrategy;
  BatchStrategy _batchStrategy;
  StreamSubscription _batchSubscription;
  // TODO should let strategies construct without a model so clients can set strategies more easily
  void set batchStrategy(BatchStrategy bs) {
    // cancel save stream subscription on old strategy
    if (_batchSubscription != null) {
      _batchSubscription.cancel();
    }
    // TODO actually tell old strategy to stop listening to changes
    // listen to save stream on new strategy
    _batchSubscription = bs.saveStream.listen(_saveDocument);
  }

  /// Create a [Document] which is provided to the returned [Future]
  Future<Document> loadDocument([initializeModel(Model)]) {
    // get document from peristent storage
    return getDocument().then((retrievedDoc) {
      // ensure realtime api is loaded and us in-memory document
      return GoogleDocProvider.loadRealtimeApi().then((realtime) {
        _document = GoogleDocProvider.loadFromJson(retrievedDoc, (error) {
          throw new Error._fromProxy(error);
        });
        _document.model.root.onObjectChanged.listen((event) {
          _isPending = true;
          _document._onDocumentSaveStateChanged.add(
              new PersistentDocumentSaveStateChangedEvent(isPending, isSaving,
                  _document, EventType.DOCUMENT_SAVE_STATE_CHANGED));
        });
        batchStrategy =
            new DelayStrategy(_document.model, const Duration(seconds: 10));
        return _document;
      });
    });
  }

  /**
   * If true, the document has changes that have not been sent to the server
   **/
  bool get isPending => _isPending;
  bool _isPending = false;

  /**
   * If true, the document is in the process of saving.
   * Mutations have been sent to the server, but we have not yet received an ack. If false, nothing is in the process of being sent.
   */
  bool get isSaving => _isSaving;
  bool _isSaving = false;

  void _saveDocument(bool save) {
    // if already saving, return false
    if (_isSaving) return;
    _isSaving = true;
    _isPending = false;
    // send state changed event. don't have to make separate check because _isSaving had to be false
    _document._onDocumentSaveStateChanged.add(
        new PersistentDocumentSaveStateChangedEvent(isPending, isSaving,
            _document, EventType.DOCUMENT_SAVE_STATE_CHANGED));
    saveDocument().then((bool saved) {
      if (!saved) {
        // TODO save error?
      } else {
        // TODO this should always be true. what if it's not?
        var lastIsSaving = isSaving;
        _isSaving = false;
        if (lastIsSaving != isSaving) {
          _document._onDocumentSaveStateChanged.add(
              new PersistentDocumentSaveStateChangedEvent(isPending, isSaving,
                  _document, EventType.DOCUMENT_SAVE_STATE_CHANGED));
        }
      }
    });
  }

  Future<Map> exportDocument() {
    return new Future.value(JSON.decode(_document.model.toJson()));
  }

  /**
   * Save current document state to persistent storage.
   */
  Future<bool> saveDocument();
}
