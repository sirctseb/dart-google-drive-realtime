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

  /// Create a strategy with a given delay duration
  DelayStrategy(Model model, this.duration) : super(model);

  /// Save after a given amount of time has passed since the last modification
  void modelChanged(ObjectChangedEvent event) {
    // TODO a better model for this whole thing might be to have a repeating timer
    // TODO that checks if enough time has passed since last event instead of creating new timers every event

    // if there is already a timer running, cancel it
    if(_sinceLastModification != null) {
      _sinceLastModification.cancel();
    }

    // start a timer for the modification
    _sinceLastModification = new Timer(duration, () {
      save();
    });
  }
  // the timer that counts since the last modification
  Timer _sinceLastModification;
}

/// A class to provide non Google Drive documents with persistence
abstract class PersistentDocumentProvider {
  /// The [Document] provided by this provider. Null until after the futur returned by loadDocument completes
  Document get document => _document;
  // TODO we could do final if we are willing to have an uninitialized document on the provider before it acutally loads
  Document _document;

  /// The strategy to determine when document changes should be saved
  BatchStrategy get batchStrategy => _batchStrategy;
  BatchStrategy _batchStrategy;
  StreamSubscription _batchSubscription;
  // TODO should let strategies construct without a model so clients can set strategies more easily
  void set batchStrategy(BatchStrategy bs) {
    // cancel save stream subscription on old strategy
    if(_batchSubscription != null) {
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
      // TODO only do initializeModel if document has never been loaded (where is this recorded)?
      var model = new LocalModel(initializeModel);
      // TODO put data from retrievedDoc into model
      // TODO do data load in function passed as initializeModel so we don't get events for them
      // listen for changes on model
      model.root.onObjectChanged.listen(_onDocumentChange);
      // create batch strategy
      batchStrategy = new DelayStrategy(model, const Duration(seconds: 1));
      // create and return a document with the model
      return _document = new LocalDocument(model);
    });
  }

  /**
   * If true, the client has mutations that have not yet been sent to the server.
   * If false, all mutations have been sent to the server, but some may not yet have been acked.
   */
  bool get isPending => _isPending;
  bool _isPending = false;

  /**
   * If true, the document is in the process of saving.
   * Mutations have been sent to the server, but we have not yet received an ack. If false, nothing is in the process of being sent.
   */
  bool get isSaving => _isSaving;
  bool _isSaving = false;

  // handles document change events and calls saveDocument based on buffering strategy
  // TODO save state changed events
  void _onDocumentChange(ObjectChangedEvent e) {
    bool lastIsPending = isPending;
    _isPending = true;
    // if pending has changed, send change event
    if(lastIsPending != _isPending) {
      _document._onDocumentSaveStateChanged.add(new LocalDocumentSaveStateChangedEvent(isPending, isSaving, document));
    }
  }

  void _saveDocument(bool save) {
    // if already saving, return false
    if(_isSaving) return;
    _isPending = false;
    _isSaving = true;
    // send state changed event. don't have to make separate check because _isSaving had to be false
    _document._onDocumentSaveStateChanged.add(new LocalDocumentSaveStateChangedEvent(isPending, isSaving, document));
    saveDocument().then((bool saved) {
      if(!saved) {
        // TODO save error?
      } else {
        // TODO this should always be true. what if it's not?
        var lastIsSaving = isSaving;
        _isSaving = false;
        if(lastIsSaving != isSaving) {
          _document._onDocumentSaveStateChanged.add(new LocalDocumentSaveStateChangedEvent(isPending, isSaving, document));
        }
      }
    });
  }

  /**
   *  Load a document from persistent storage.
   *  Called by PersistentDocumentProvider.loadDocument to retrieve the document data.
   */
  // TODO what format does this return?
  Future<dynamic> getDocument();

  /**
   * Save current document state to persistent storage.
   */
  Future<bool> saveDocument();
}
