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

abstract class _LocalEvent extends _LocalRetainable implements BaseModelEvent {
  /// Local events have no js Proxy object
  final js.Proxy $unsafe = null;

  /// Local events are always isLocal
  final bool isLocal = true;

  /// Local events have no session
  final String sessionId = null;

  /// Local events have no js Proxy object
  dynamic toJs() => null;

  /// Local events have no user
  final String userId = null;

  // the object that generated the event
  final _LocalModelObject _target;

  _LocalEvent._(this._target);
}