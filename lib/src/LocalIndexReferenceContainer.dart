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

// Implements index reference management
class LocalIndexReferenceContainer extends LocalModelObject {

  LocalIndexReference registerReference(int index, bool canBeDeleted) {
    // create the reference
    var ref = new LocalIndexReference._(index, canBeDeleted, this);
    // add to list of references
    _indexReferences.add(ref);
    return ref;
  }

  void _shiftReferencesOnDelete(int index, int length) {
    // check for reference shifts
    _indexReferences.forEach((LocalIndexReference ref) {
      // if index is to the right of deletion, shift by deleted length
      if(ref.index >= index + length) {
        ref._shift(ref.index - length);
      } else if(ref.index >= index) {
        if(ref.canBeDeleted) {
          // if within deleted segment and can be deleted, set to -1
          ref._shift(-1);
        } else {
          // otherwise set to index at beginning of deleted segment
          ref._shift(index);
        }
      }
    });
  }
  void _shiftReferencesOnInsert(int index, int length) {
    // check for reference shifts
    _indexReferences.forEach((LocalIndexReference ref) {
      // if index is to the right on insert index, increase reference
      if(ref.index >= index) {
        ref._shift(ref.index + length);
      }
    });
  }

  // The list of index references registered to this object
  List<LocalIndexReference> _indexReferences = [];
}