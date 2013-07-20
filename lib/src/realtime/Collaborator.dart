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

class Collaborator extends Retainable {
  static Collaborator _cast(js.Proxy proxy) => proxy == null ? null : new Collaborator._fromProxy(proxy);

  Collaborator._fromProxy(js.Proxy proxy) : super._fromProxy(proxy);

  String get color => $unsafe['color'];
  String get displayName => $unsafe['displayName'];
  bool get isAnonymous => $unsafe['isAnonymous'];
  bool get isMe => $unsafe['isMe'];
  String get photoUrl => $unsafe['photoUrl'];
  String get sessionId => $unsafe['sessionId'];
  String get userId => $unsafe['userId'];
}
