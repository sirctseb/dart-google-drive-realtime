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

part of google_drive_realtime;

class EventTarget extends jsw.TypedProxy {
  static EventTarget cast(js.Proxy proxy) => proxy == null ? null : new EventTarget.fromProxy(proxy);

  EventTarget.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);

  void _addEventListener(EventType type, dynamic/*Function|Object*/ handler, [bool capture]) => $unsafe.addEventListener(type, handler, capture);
  void _removeEventListener(EventType type, dynamic/*Function|Object*/ handler, [bool capture]) => $unsafe.removeEventListener(type, handler, capture);

  SubscribeStreamProvider _getStreamProviderFor(EventType eventType, [transformEvent(e)]) {
    js.Callback handler;
    return new SubscribeStreamProvider(
        subscribe: (EventSink eventSink) {
          handler = new js.Callback.many((e) {
            eventSink.add(transformEvent == null ? e : transformEvent(e));
          });
          if(js.context["handlers"] == null) js.context.handlers = js.map({});
          js.context['handlers'][handler.hashCode.toString()] = handler;
          _addEventListener(eventType, js.context['handlers'][handler.hashCode.toString()]);
        },
        unsubscribe: (EventSink eventSink) {
          _removeEventListener(eventType, js.context['handlers'][handler.hashCode.toString()]);
          handler.dispose();
        }
    );
  }
}
