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

// to add retain and release methods to unify interface with local side
class Retainable extends jsw.TypedProxy {
  Retainable._fromProxy(js.Proxy proxy) : super.fromProxy(proxy);

  void retain() {
    js.retain($unsafe);
  }
  void release() {
    js.release($unsafe);
  }
}