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

class LocalCollaborator implements Collaborator {
  final String color;
  final String displayName;
  final bool isAnonymous;
  final bool isMe;
  final String photoUrl;
  final String sessionId;
  final String userId;

  final js.JsObject $unsafe = null;
  dynamic toJs() => null;


  LocalCollaborator(String this.color, String this.displayName,
      bool this.isAnonymous, bool this.isMe, String this.photoUrl,
      String this.sessionId, String this.userId);
}