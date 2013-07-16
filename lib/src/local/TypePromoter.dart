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

/// Promote proxied objects to collaborative objects if they are that type
// TODO migrate to using js.instanceof
dynamic promoteProxy(dynamic object) {
  String type;

  if(object is js.Proxy) {
    var realtimeNamespace = js.context['gapi']['drive']['realtime'];
    if(js.instanceof(object, realtimeNamespace['CollaborativeMap'])) {
      return RealtimeMap.cast(object, RealtimeModel._typedTranslator);
    } else if(js.instanceof(object, realtimeNamespace['CollaborativeList'])) {
      return RealtimeList.cast(object, RealtimeModel._typedTranslator);
    } else if(js.instanceof(object, realtimeNamespace['CollaborativeString'])) {
      return RealtimeString.cast(object);
    } else if(js.instanceof(object, js.context['Array'])
               || js.instanceof(object, js.context['Object'])) {
      return json.parse(js.context['JSON']['stringify'](object));
    }
  }
  // string, bool, numbers all get the correct type automatically
  return object;
}