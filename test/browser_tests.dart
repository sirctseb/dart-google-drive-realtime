import 'dart:html';
import 'dart:async';

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:realtime_data_model/realtime_data_model.dart' as rt;
import 'package:realtime_data_model/realtime_data_model_custom.dart' as rtc;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

initializeModel(rt.Model model) {
  model.root['text'] = model.createString('Hello Realtime World!');
  model.root['list'] = model.createList();
  model.root['map'] = model.createMap();
}

onFileLoaded(rt.Document doc) {
  js.retain(doc);

  useHtmlConfiguration();

  group('Undo', () {
    test("start undo state", () {
      expect(doc.model.canUndo, false);
      expect(doc.model.canRedo, false);
    });
    test('undo state after change', () {
      doc.model.root['text'].text = 'redid';
      expect(doc.model.canUndo, true);
      expect(doc.model.canRedo, false);
    });
    test('undo state after undo', () {
      doc.model.undo();
      expect(doc.model.canUndo, false);
      expect(doc.model.canRedo, true);
    });
    test('string state after undo', () {
      expect(doc.model.root['text'].text, 'Hello Realtime World!');
    });
    test('string state after redo and event/model state matching', () {
      StreamSubscription ssUndo;
      ssUndo = doc.model.onUndoRedoStateChanged.listen(expectAsync1((event) {
        // test that event properties match model
        expect(doc.model.canUndo, event.canUndo);
        expect(doc.model.canRedo, event.canRedo);
        // test that undo/redo state is what we expect
        expect(doc.model.canUndo, true);
        expect(doc.model.canRedo, false);
        ssUndo.cancel();
      }));
      doc.model.redo();
      expect(doc.model.root['text'].text, 'redid');
      doc.model.undo();
    });
  });

  group('CollaborativeString', () {
    var string = doc.model.root['text'];
    js.retain(string);
    setUp((){
      string.text = 'unittest';
    });
    test('get length', () {
      expect(string.length, 8);
    });
    test('append(String text)', () {
      string.append(' append');
      expect(string.text, 'unittest append');
    });
    test('get text', () {
      expect(string.text, 'unittest');
    });
    test('insertString(int index, String text)', () {
      string.insertString(4, ' append ');
      expect(string.text, 'unit append test');
    });
    test('removeRange(int startIndex, int endIndex)', () {
      string.removeRange(4, 6);
      expect(string.text, 'unitst');
    });
    test('set text(String text)', () {
      string.text = 'newValue';
      expect(string.text, 'newValue');
    });
    test('onTextInserted', () {
      StreamSubscription ssInsert;
      StreamSubscription ssDelete;
      ssInsert = string.onTextInserted.listen(expectAsync1((rt.TextInsertedEvent e) {
        expect(e.index, 4);
        expect(e.text, ' append ');
        ssInsert.cancel();
        ssDelete.cancel();
      }));
      ssDelete = string.onTextDeleted.listen(expectAsync1((rt.TextDeletedEvent e) {
        fail("delete should not be call");
      }, count: 0));
      string.insertString(4, ' append ');
    });
    test('onTextDeleted', () {
      StreamSubscription ssInsert;
      StreamSubscription ssDelete;
      ssInsert = string.onTextInserted.listen(expectAsync1((rt.TextInsertedEvent e) {
        fail("insert should not be call");
      }, count: 0));
      ssDelete = string.onTextDeleted.listen(expectAsync1((rt.TextDeletedEvent e) {
        expect(e.index, 4);
        expect(e.text, 'te');
        ssInsert.cancel();
        ssDelete.cancel();
      }));
      string.removeRange(4, 6);
    });
  });

  group('CollaborativeList', () {
    var list = doc.model.root['list'];
    js.retain(list);
    setUp((){
      list.clear();
      list.push('s1');
    });
    test('get length', () {
      expect(list.length, 1);
    });
    test('operator [](int index)', () {
      expect(list[0], 's1');
      expect(() => list[-1], throws);
      expect(() => list[1], throws);
    });
    test('operator []=(int index, E value)', () {
      list[0] = 'new s1';
      expect(list[0], 'new s1');
    });
    test('clear()', () {
      list.clear();
      expect(list.length, 0);
    });
    test('insert(int index, E value)', () {
      list.insert(0, 's0');
      expect(list.length, 2);
      expect(list[0], 's0');
      expect(list[1], 's1');
    });
    test('push(E value)', () {
      expect(list.push('s2'), 2);
      expect(list.length, 2);
      expect(list[0], 's1');
      expect(list[1], 's2');
    });
    test('remove(int index)', () {
      list.remove(0);
      expect(list.length, 0);
    });
    test('onValuesAdded', () {
      StreamSubscription ss;
      ss = list.onValuesAdded.listen(expectAsync1((rt.ValuesAddedEvent e) {
        expect(e.index, 1);
        expect(e.values, ['s2']);
        ss.cancel();
      }));
      list.push('s2');
    });
    test('onValuesRemoved', () {
      StreamSubscription ss;
      ss = list.onValuesRemoved.listen(expectAsync1((rt.ValuesRemovedEvent e) {
        expect(e.index, 0);
        expect(e.values, ['s1']);
        ss.cancel();
      }));
      list.clear();
    });
    test('onValuesSet', () {
      StreamSubscription ss;
      ss = list.onValuesSet.listen(expectAsync1((rt.ValuesSetEvent e) {
        expect(e.index, 0);
        expect(e.oldValues, ['s1']);
        expect(e.newValues, ['s2']);
        ss.cancel();
      }));
      list[0] = 's2';
    });
  });
  group('CollaborativeMap', () {
    var map = doc.model.root['map'];
    js.retain(map);
    setUp(() {
      map.clear();
      map['key1'] = 4;
    });
    test('operator [](String key)', () {
      expect(map['key1'], 4);
      expect(map.length, 1);
    });
    test('operator []=(String key, E value)', () {
      map['key2'] = 5;
      expect(map['key2'], 5);
    });
    test('remove', () {
      map.remove('key1');
      expect(map.length, 0);
      expect(map['key1'], null);
    });
    test('clear', () {
      map.clear();
      expect(map.length, 0);
    });
    test('addAll', () {
      map.addAll({
        'key2': 5,
        'key3': 6
      });
      expect(map.length, 3);
      expect(map['key2'], 5);
      expect(map['key3'], 6);
    });
    test('onValueChanged', () {
      StreamSubscription ssChanged;
      ssChanged = map.onValueChanged.listen(expectAsync1((rt.ValueChangedEvent e) {
        expect(e.property, 'key1');
        expect(e.newValue, 5);
        expect(e.oldValue, 4);
        ssChanged.cancel();
      }));
      map['key1'] = 5;
    });
    test('onValueChanged add', () {
      StreamSubscription ssAdd;
      ssAdd = map.onValueChanged.listen(expectAsync1((rt.ValueChangedEvent e) {
        expect(e.property, 'prop');
        expect(e.newValue, 'newVal');
        expect(e.oldValue, null);
        ssAdd.cancel();
      }));
      map['prop'] = 'newVal';
    });
    test('onValueChanged remove', () {
      StreamSubscription ssRemove;
      ssRemove = map.onValueChanged.listen(expectAsync1((rt.ValueChangedEvent e) {
        expect(e.property, 'key1');
        expect(e.oldValue, 4);
        expect(e.newValue, null);
        ssRemove.cancel();
      }));
      map.remove('key1');
    });
    test('onValueChanged clear', () {
      map['key2'] = 'val2';
      StreamSubscription ssClear;
      ssClear = map.onValueChanged.listen(expectAsync1((rt.ValueChangedEvent e) {
        expect(e.newValue, null);
      }, count: 2));
      map.clear();
      ssClear.cancel();
    });
    test('map length on null assignment', () {
      // TODO this is different than native maps. but that is a rt problem, not rdm.
      expect(map.length, 1);
      map['key1'] = null;
      expect(map.length, 0);
    });
  });
  group('RealtimeIndexReference', () {
    rt.CollaborativeString string = doc.model.root['text'];
    rt.CollaborativeList list = doc.model.root['list'];
    js.retain(string);
    js.retain(list);
    // TODO are references ever removed?
    test('RealtimeString Reference Value', () {
      string.text = "aaaaaaaaaa";
      rt.IndexReference ref = string.registerReference(5, false);
      expect(ref.index, 5);
      string.insertString(2, "x");
      expect(ref.index, 6);
      doc.model.undo();
      expect(ref.index, 5);
      string.insertString(8, "x");
      expect(ref.index, 5);
      string.removeRange(0, 2);
      expect(ref.index, 3);
      string.removeRange(2, 4);
      expect(ref.index, 2);
    });
    test('RealtimeString Delete Reference', () {
      rt.IndexReference ref = string.registerReference(5, true);
      expect(ref.index, 5);
      string.removeRange(4, 6);
      expect(ref.index, -1);
    });
    test('RealtimeList Reference Value', () {
      list.clear();
      list.pushAll([1,2,3,4,5,6,7,8,9,10,11,12]);
      rt.IndexReference ref = list.registerReference(5, false);
      expect(ref.index, 5);
      list.insert(2, 9);
      expect(ref.index, 6);
      doc.model.undo();
      expect(ref.index, 5);
      list.insert(8, 9);
      expect(ref.index, 5);
      list.removeRange(0, 2);
      expect(ref.index, 3);
      list.removeRange(2, 4);
      expect(ref.index, 2);
    });
    test('RealtimeList Delete Reference', () {
      rt.IndexReference ref = list.registerReference(5, true);
      expect(ref.index, 5);
      list.removeRange(4, 6);
      expect(ref.index, -1);
    });
    test('RealtimeString Reference Events', () {
      string.text = "aaaaaaaaaa";
      rt.IndexReference ref = string.registerReference(5, true);
      StreamSubscription ssRef;
      ssRef = ref.onReferenceShifted.listen(expectAsync1((rt.ReferenceShiftedEvent event) {
        expect(event.oldIndex, 5);
        expect(event.newIndex, 7);
        expect(ref.index, 7);
      }));
      string.insertString(0, "xx");
    });
  });
}

/**
 * Options for the Realtime loader.
 */
get realtimeOptions => {
   /**
  * Client ID from the APIs Console.
  */
  'clientId': 'INSERT YOUR CLIENT ID HERE',

   /**
  * The ID of the button to click to authorize. Must be a DOM element ID.
  */
   'authButtonElementId': 'authorizeButton',

   /**
  * Function to be called when a Realtime model is first created.
  */
   'initializeModel': initializeModel,

   /**
  * Autocreate files right after auth automatically.
  */
   'autoCreate': true,

   /**
  * Autocreate files right after auth automatically.
  */
   'defaultTitle': "New Realtime Quickstart File",

   /**
  * Function to be called every time a Realtime file is loaded.
  */
   'onFileLoaded': onFileLoaded
};


main() {
  rt.start(realtimeOptions);
}
