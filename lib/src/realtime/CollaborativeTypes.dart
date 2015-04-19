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

class CollaborativeTypes extends IsEnum<String> {
  static final COLLABORATIVE_MAP = new CollaborativeTypes._(realtime['CollaborativeTypes']['COLLABORATIVE_MAP']);
  static final COLLABORATIVE_LIST = new CollaborativeTypes._(realtime['CollaborativeTypes']['COLLABORATIVE_LIST']);
  static final COLLABORATIVE_STRING = new CollaborativeTypes._(realtime['CollaborativeTypes']['COLLABORATIVE_STRING']);
  static final INDEX_REFERENCE = new CollaborativeTypes._(realtime['CollaborativeTypes']['INDEX_REFERENCE']);

  static final _INSTANCES = [COLLABORATIVE_MAP, COLLABORATIVE_LIST, COLLABORATIVE_STRING, INDEX_REFERENCE];

  static CollaborativeTypes find(Object o) => findIn(_INSTANCES, o);

  CollaborativeTypes._(String value) : super(value);

  bool operator ==(Object other) => value == (other is CollaborativeTypes ? other.value : other);
}