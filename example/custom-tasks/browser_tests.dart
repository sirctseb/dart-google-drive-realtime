import 'dart:html';
import 'dart:async';

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:realtime_data_model/realtime_data_model.dart' as rt;
import 'package:realtime_data_model/realtime_data_model_custom.dart' as rtc;

class Task extends rt.CollaborativeObject {
  static const NAME = 'Task';

  /**
   * Register type as described in https://developers.google.com/drive/realtime/build-model#registering_and_creating_custom_objects
   * This method must be call only one time before the document is load.
   */
  static void registerType() {
    js.context.Task = new js.Callback.many((){});
    rtc.registerType(js.context.Task, NAME);
    js.context.Task.prototype.title = rtc.collaborativeField('title');
    js.context.Task.prototype.done = rtc.collaborativeField('done');
  }

  static Task cast(js.Proxy proxy) => proxy == null ? null : new Task.fromProxy(proxy);

  /// create new collaborative object from model
  Task(rt.Model model) : this.fromProxy(model.create(NAME).$unsafe);
  Task.fromProxy(js.Proxy proxy) : super.fromProxy(proxy) {
    done = false;
  }

  String get title => $unsafe.title;
  bool get done => $unsafe.done;
  set title(String title) => $unsafe.title = title;
  set done(bool done) => $unsafe.done = done;
}

initializeModel(js.Proxy modelProxy) {
  var model = rt.Model.cast(modelProxy);
  var tasks = model.createList();
  model.root['tasks'] = tasks;
}

/**
 * This function is called when the Realtime file has been loaded. It should
 * be used to initialize any user interface components and event handlers
 * depending on the Realtime model. In this case, create a text control binder
 * and bind it to our string model that we created in initializeModel.
 * @param doc {gapi.drive.realtime.Document} the Realtime document.
 */
onFileLoaded(docProxy) {
  final doc = rt.Document.cast(docProxy);
  js.retain(doc);
  final rt.CollaborativeList<Task> tasks = rt.CollaborativeList.castListOfSerializables(doc.model.root['tasks'], Task.cast);
  js.retain(tasks);

  // collaborators listener
  doc.onCollaboratorJoined.listen((rt.CollaboratorJoinedEvent e){
    print("user joined : ${e.collaborator.displayName}");
  });
  doc.onCollaboratorLeft.listen((rt.CollaboratorLeftEvent e){
    print("user left : ${e.collaborator.displayName}");
  });

  final ulTasks = document.getElementById('tasks') as UListElement;
  final task = document.getElementById('task') as TextInputElement;
  final add = document.getElementById('add') as ButtonElement;

  final updateTasksList = (){
    ulTasks.children.clear();
    for(int i = 0; i < tasks.length; i++) {
      ulTasks.children.add(new LIElement()..text = tasks[i].title);
    }
  };

  document.getElementById('add').onClick.listen((_){
    tasks.push(new Task(doc.model)
      ..title = task.value
    );
    task.value = "";
    task.focus();
  });

  // update input on changes
  tasks.onObjectChanged.listen((rt.ObjectChangedEvent e){
    updateTasksList();
  });

  // Enabling UI Elements.
  task.disabled = false;
  add.disabled = false;

  // init list
  updateTasksList();
}

/**
 * Options for the Realtime loader.
 */
get realtimeOptions => js.map({
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
   'initializeModel': new js.Callback.once(initializeModel),

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
   'onFileLoaded': new js.Callback.many(onFileLoaded)
});


main() {
  var realtimeLoader = new js.Proxy(js.context.rtclient.RealtimeLoader, realtimeOptions);
  realtimeLoader.start(new js.Callback.once((){
    Task.registerType();
  }));
}
