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

library local_realtime_data_model;

import 'dart:async';
import 'dart:collection';

import 'package:google_drive_realtime/google_drive_realtime.dart' as rt;
import 'package:js/js.dart' as js;
import 'package:meta/meta.dart';

part 'LocalEvent.dart';
part 'LocalIndexReference.dart';
part 'LocalIndexReferenceContainer.dart';
part 'LocalModel.dart';
part 'LocalModelList.dart';
part 'LocalModelMap.dart';
part 'LocalModelObject.dart';
part 'LocalModelString.dart';
part 'LocalObjectChangedEvent.dart';
part 'LocalReferenceShiftedEvent.dart';
part 'LocalTextDeletedEvent.dart';
part 'LocalTextInsertedEvent.dart';
part 'LocalUndoRedoStateChangedEvent.dart';
part 'LocalValueChangedEvent.dart';
part 'LocalValuesAddedEvent.dart';
part 'LocalValuesRemovedEvent.dart';
part 'LocalValuesSetEvent.dart';
part 'ModelEventType.dart';
part 'UndoHistory.dart';