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

part of local_realtime_data_model;

class LocalModelString extends LocalIndexReferenceContainer implements rdm.RealtimeString {

  // TODO need local events
  StreamController<LocalTextInsertedEvent> _onTextInserted
    = new StreamController<LocalTextInsertedEvent>.broadcast(sync: true);
  StreamController<LocalTextDeletedEvent> _onTextDeleted
    = new StreamController<LocalTextDeletedEvent>.broadcast(sync: true);

  int get length => _string.length;

  void append(String text) {
    // add event to stream
    var insertEvent = new LocalTextInsertedEvent._(_string.length, text, this);
    _emitEventsAndChanged([_onTextInserted], [insertEvent]);
  }
  String get text => _string;
  void insertString(int index, String text) {
    var insertEvent = new LocalTextInsertedEvent._(index, text, this);
    _emitEventsAndChanged([_onTextInserted], [insertEvent]);
  }
  void removeRange(int startIndex, int endIndex) {
    // get removed text for event
    var removed = _string.substring(startIndex, endIndex);
    // add event to stream
    var deleteEvent = new LocalTextDeletedEvent._(startIndex, removed, this);
    _emitEventsAndChanged([_onTextDeleted], [deleteEvent]);
  }
  void set text(String text) {
    // trivial edit decomposition algorithm
    // add event to stream
    var deleteEvent = new LocalTextDeletedEvent._(0, _string, this);
    var insertEvent = new LocalTextInsertedEvent._(0, text, this);
    _emitEventsAndChanged([_onTextDeleted, _onTextInserted], [deleteEvent, insertEvent]);
  }

  Stream<LocalTextInsertedEvent> get onTextInserted => _onTextInserted.stream;
  Stream<LocalTextDeletedEvent> get onTextDeleted => _onTextDeleted.stream;

  LocalModelString([String initialValue]) {
    // initialize
    if(initialValue != null) {
      // don't emit events
      _string = initialValue;
    }

    _eventStreamControllers[ModelEventType.TEXT_DELETED.value] = _onTextDeleted;
    _eventStreamControllers[ModelEventType.TEXT_INSERTED.value] = _onTextInserted;
  }

  void _executeEvent(LocalUndoableEvent event_in) {
    // handle insert and delete events
    // TODO deal with type warnings
    if(event_in.type == ModelEventType.TEXT_DELETED.value) {
      var event = event_in as LocalTextDeletedEvent;
      // update string
      _string = "${_string.substring(0, event.index)}${_string.substring(event.index + event.text.length)}";
      // update references
      _shiftReferencesOnDelete(event.index, event.text.length);
    } else if(event_in.type == ModelEventType.TEXT_INSERTED.value) {
      var event = event_in as LocalTextInsertedEvent;
      // update string
      _string = "${_string.substring(0, event.index)}${event.text}${_string.substring(event.index)}";
      // update references
      _shiftReferencesOnInsert(event.index, event.text.length);
    } else {
      super._executeEvent(event_in);
    }
  }

  // current string value
  String _string = "";
}
