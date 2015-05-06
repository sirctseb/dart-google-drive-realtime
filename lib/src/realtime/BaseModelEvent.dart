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

// TypedProxy taken from:

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//part of js.wrapping;

/// base class to wrap a [Proxy] in a strong typed object.
class TypedProxy {
  js.JsObject $unsafe;

  TypedProxy.fromProxy(this.$unsafe);

  @override dynamic toJs() => $unsafe;
}

class BaseModelEvent extends TypedProxy {
  BaseModelEvent._fromProxy(js.JsObject proxy) : super.fromProxy(proxy);

  bool get bubbles => $unsafe['bubbles'];
  List<String> get compoundOperationNames => ($unsafe['compoundOperationNames'] as js.JsArray).toList();
  bool get isLocal => $unsafe['isLocal'];
  bool get isRedo => $unsafe['isRedo'];
  bool get isUndo => $unsafe['isUndo'];
  String get sessionId => $unsafe['sessionId'];
  String get type => $unsafe['type'];
  String get userId => $unsafe['userId'];
  CollaborativeObject get target => CollaborativeObjectTranslator._fromJs($unsafe['target']);
  void stopPropagation() => $unsafe.callMethod('stopPropagation');
}
