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

// translator to promote to collaborative types
class CollaborativeContainerTranslator<E> extends jsw.Translator<E> {
  static dynamic _fromJs(dynamic object) {
    return _promoteProxy(object);
  }
  static dynamic _toJs(dynamic object) {
    if(object is CollaborativeObject) return object;
    if(object is List) return js.array(object);
    if(object is Map) return js.map(object);
    return object;
  }

  CollaborativeContainerTranslator() : super(_fromJs, _toJs);
}

class CollaborativeContainer<V> extends CollaborativeObject {
  CollaborativeContainer._fromProxy(js.Proxy proxy) : super._fromProxy(proxy);

  static final jsw.Translator _realtimeTranslator = new CollaborativeContainerTranslator();
  final jsw.Translator<V> _translator = _realtimeTranslator;
}