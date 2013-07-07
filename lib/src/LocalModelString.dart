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

class LocalModelString extends LocalModelObject implements rt.CollaborativeString {

  // TODO need local events
  StreamController<LocalTextInsertedEvent> _onTextInserted
    = new StreamController<LocalTextInsertedEvent>.broadcast(sync: true);
  StreamController<LocalTextDeletedEvent> _onTextDeleted
    = new StreamController<LocalTextDeletedEvent>.broadcast(sync: true);

  int get length => _string.length;

  void append(String text) {
    _string = "${_string}$text";
    // add event to stream
    // TODO check index value computation
    _onTextInserted.add(new LocalTextInsertedEvent._(_string.length - text.length, text));
  }
  String get text => _string;
  void insertString(int index, String text) {
    // TODO make sure end is exclusive in substring
    _string = "${_string.substring(0, index)}$text${_string.substring(index)}";
    _onTextInserted.add(new LocalTextInsertedEvent._(index, text));
  }
  // TODO implement references
  IndexReference registerReference(int index, bool canBeDeleted) => null;
  void removeRange(int startIndex, int endIndex) {
    // get removed text for event
    var removed = _string.substring(startIndex, endIndex);
    // TODO make sure end is exclusive in substring
    // TODO test edge case where endIndex is last index. I think this will crash
    _string = "${_string.substring(0, startIndex)}${_string.substring(endIndex)}";
    // add event to stream
    _onTextDeleted.add(new LocalTextDeletedEvent._(startIndex, removed));
  }
  void set text(String text) {
    // TODO compute edit
    // TODO event
    _string = text;
  }

  // TODO need local events
  Stream<LocalTextInsertedEvent> get onTextInserted => _onTextInserted.stream;
  Stream<LocalTextDeletedEvent> get onTextDeleted => _onTextDeleted.stream;
  
  // current string value
  String _string;
}
