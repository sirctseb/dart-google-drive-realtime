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

class _LocalEventTarget {

  StreamController<_LocalObjectChangedEvent> _onObjectChanged
    = new StreamController<_LocalObjectChangedEvent>.broadcast(sync: true);
  Stream<_LocalObjectChangedEvent> get onObjectChanged => _onObjectChanged.stream;

  List<_LocalEventTarget> parentEventTargets = [];

  void addParentEventTarget(_LocalEventTarget parent) {
    if(!parentEventTargets.contains(parent)) {
      parentEventTargets.add(parent);
    }
  }

  void removeParentEventTarget(_LocalEventTarget parent) {
    parentEventTargets.remove(parent);
  }

  void dispatchObjectChangedEvent(_LocalObjectChangedEvent event) {
    // make ancestor list
    var ancestors = new List.from(parentEventTargets, growable: true);
    for(int i = 0; i < ancestors.length; i++) {
      var grandparents = ancestors[i].parentEventTargets;
      for(int j = 0; j < grandparents.length; j++) {
        if(!ancestors.contains(grandparents[j])) {
          ancestors.add(grandparents[j]);
        }
      }
    }
    // fire event on this object
    _onObjectChanged.add(event);
    // fire event on ancestors
    for(int i = 0; i < ancestors.length; i++) {
      ancestors[i]._onObjectChanged.add(event);
    }
  }
}
