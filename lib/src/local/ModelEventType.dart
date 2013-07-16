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

/// Mirror of rt.EventType that doesn't require js lookup
class ModelEventType {
  
  static final COLLABORATOR_JOINED = new ModelEventType._(_realtime['EventType']['COLLABORATOR_JOINED']);
  static final COLLABORATOR_LEFT = new ModelEventType._(_realtime['EventType']['COLLABORATOR_LEFT']);
  static final DOCUMENT_SAVE_STATE_CHANGED = new ModelEventType._(_realtime['EventType']['DOCUMENT_SAVE_STATE_CHANGED']);
  static final OBJECT_CHANGED = new ModelEventType._(_realtime['EventType']['OBJECT_CHANGED']);
  static final REFERENCE_SHIFTED = new ModelEventType._(_realtime['EventType']['REFERENCE_SHIFTED']);
  static final TEXT_DELETED = new ModelEventType._(_realtime['EventType']['TEXT_DELETED']);
  static final TEXT_INSERTED = new ModelEventType._(_realtime['EventType']['TEXT_INSERTED']);
  static final UNDO_REDO_STATE_CHANGED = new ModelEventType._(_realtime['EventType']['UNDO_REDO_STATE_CHANGED']);
  static final VALUES_ADDED = new ModelEventType._(_realtime['EventType']['VALUES_ADDED']);
  static final VALUES_REMOVED = new ModelEventType._(_realtime['EventType']['VALUES_REMOVED']);
  static final VALUES_SET = new ModelEventType._(_realtime['EventType']['VALUES_SET']);
  static final VALUE_CHANGED = new ModelEventType._(_realtime['EventType']['VALUE_CHANGED']);

  static final _INSTANCES = [COLLABORATOR_JOINED, COLLABORATOR_LEFT, DOCUMENT_SAVE_STATE_CHANGED, OBJECT_CHANGED, REFERENCE_SHIFTED, TEXT_DELETED, TEXT_INSERTED, UNDO_REDO_STATE_CHANGED, VALUES_ADDED, VALUES_REMOVED, VALUES_SET, VALUE_CHANGED];

  ModelEventType._(String this.value);
  final String value;

  // map to values used in realtime js api
  static const _realtime = const {
    'EventType': const {
      'COLLABORATOR_JOINED': 'collaborator_joined',
      'COLLABORATOR_LEFT': 'collaborator_left',
      'DOCUMENT_SAVE_STATE_CHANGED': 'document_save_state_changed',
      'OBJECT_CHANGED': 'object_changed',
      'REFERENCE_SHIFTED': 'reference_shifted',
      'TEXT_DELETED': 'text_deleted',
      'TEXT_INSERTED': 'text_inserted',
      'UNDO_REDO_STATE_CHANGED': 'undo_redo_state_changed',
      'VALUES_ADDED': 'values_added',
      'VALUES_REMOVED': 'values_removed',
      'VALUES_SET': 'values_set',
      'VALUE_CHANGED': 'value_changed'
    }
  };
}