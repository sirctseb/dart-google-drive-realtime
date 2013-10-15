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

// TODO I think this should not actually extend LocalEvent
class _LocalDocumentSaveStateChangedEvent extends _LocalEvent implements DocumentSaveStateChangedEvent {

  bool get bubbles => null; // TODO implement this getter

  final bool isPending;

  final bool isSaving;

  final String type = _ModelEventType.DOCUMENT_SAVE_STATE_CHANGED.value;

  // TODO not private because doc providers need to create them
  // TODO these don't need to be private in general because local_rdm is not public anyway
  _LocalDocumentSaveStateChangedEvent(this.isPending, this.isSaving, target) : super._(target);
}
