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

library realtime_data_model;

import 'dart:html';
import 'dart:async';
import 'dart:collection';
import 'dart:js' as jss;
import 'dart:mirrors';

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:google_oauth2_client/google_oauth2_browser.dart';
import 'package:google_drive_v2_api/drive_v2_api_browser.dart' as dcbrowser;
import 'package:google_drive_v2_api/drive_v2_api_client.dart' as dc;

import 'src/utils.dart';

part 'src/docprovider/DocumentProvider.dart';
part 'src/docprovider/GoogleDocProvider.dart';
part 'src/docprovider/LocalDocumentProvider.dart';
part 'src/docprovider/PersistentDocProvider.dart';
part 'src/docprovider/RemoteDocumentProvider.dart';
part 'src/realtime/BaseModelEvent.dart';
part 'src/realtime/CollaborativeContainer.dart';
part 'src/realtime/CollaborativeList.dart';
part 'src/realtime/CollaborativeMap.dart';
part 'src/realtime/CollaborativeObject.dart';
part 'src/realtime/CollaborativeString.dart';
part 'src/realtime/Collaborator.dart';
part 'src/realtime/CollaboratorJoinedEvent.dart';
part 'src/realtime/CollaboratorLeftEvent.dart';
part 'src/realtime/Document.dart';
part 'src/realtime/DocumentClosedError.dart';
part 'src/realtime/DocumentSaveStateChangedEvent.dart';
part 'src/realtime/Error.dart';
part 'src/realtime/EventTarget.dart';
part 'src/realtime/EventType.dart';
part 'src/realtime/IndexReference.dart';
part 'src/realtime/Model.dart';
part 'src/realtime/ObjectChangedEvent.dart';
part 'src/realtime/ReferenceShiftedEvent.dart';
part 'src/realtime/TextDeletedEvent.dart';
part 'src/realtime/TextInsertedEvent.dart';
part 'src/realtime/TypePromoter.dart';
part 'src/realtime/UndoRedoStateChangedEvent.dart';
part 'src/realtime/ValueChangedEvent.dart';
part 'src/realtime/ValuesAddedEvent.dart';
part 'src/realtime/ValuesRemovedEvent.dart';
part 'src/realtime/ValuesSetEvent.dart';
part 'src/realtime/error_type.dart';

// local files
part 'src/local/LocalDocument.dart';
part 'src/local/LocalDocumentSaveStateChangedEvent.dart';
part 'src/local/LocalEvent.dart';
part 'src/local/LocalEventTarget.dart';
part 'src/local/LocalIndexReference.dart';
part 'src/local/LocalIndexReferenceContainer.dart';
part 'src/local/LocalModel.dart';
part 'src/local/LocalModelList.dart';
part 'src/local/LocalModelMap.dart';
part 'src/local/LocalModelObject.dart';
part 'src/local/LocalModelString.dart';
part 'src/local/LocalObjectChangedEvent.dart';
part 'src/local/LocalReferenceShiftedEvent.dart';
part 'src/local/LocalTextDeletedEvent.dart';
part 'src/local/LocalTextInsertedEvent.dart';
part 'src/local/LocalUndoRedoStateChangedEvent.dart';
part 'src/local/LocalValueChangedEvent.dart';
part 'src/local/LocalValuesAddedEvent.dart';
part 'src/local/LocalValuesRemovedEvent.dart';
part 'src/local/LocalValuesSetEvent.dart';
part 'src/local/UndoHistory.dart';

part 'realtime_data_model_custom.dart';
part 'src/custom/CustomObject.dart';
part 'src/custom/LocalCustomObject.dart';
part 'src/custom/RealtimeCustomObject.dart';

// js.Proxy for "gapi.drive.realtime"
final realtime = js.context['gapi']['drive']['realtime'];
