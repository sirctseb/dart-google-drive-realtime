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

class EventTarget extends TypedProxy {
  EventTarget._fromProxy(js.JsObject proxy) : super.fromProxy(proxy);

  // TODO don't think JsObject provides auto-recovery of undefined methods
  void _addEventListener(EventType type, dynamic/*Function|Object*/ handler, [bool capture]) => $unsafe.callMethod('addEventListener', [type.value, handler, capture]);
  void _removeEventListener(EventType type, dynamic/*Function|Object*/ handler, [bool capture]) => $unsafe.callMethod('removeEventListener', [type.value, handler, capture]);

  // TODO do not know if hackForJsInterop95 is still necessary
  SubscribeStreamProvider _getStreamProviderFor(EventType eventType, [transformEvent(e)]) {
    Function handler;
    js.JsFunction jsFunction;
    return new SubscribeStreamProvider(
        subscribe: (EventSink eventSink) {
          handler = (e) {
            eventSink.add(transformEvent == null ? e : transformEvent(e));
          };
          js.context['hackForJsInterop95'] = handler;
          jsFunction = js.context['hackForJsInterop95'];
          js.context.deleteProperty('hackForJsInterop95');
//          _addEventListener(eventType, handler);
          _addEventListener(eventType, jsFunction);
        },
        unsubscribe: (EventSink eventSink) {
//          _removeEventListener(eventType, handler);
          _removeEventListener(eventType, jsFunction);
        }
    );
  }
}
