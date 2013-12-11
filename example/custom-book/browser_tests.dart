import 'dart:html';

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:realtime_data_model/realtime_data_model.dart' as rt;
//import 'package:realtime_data_model/realtime_data_model_custom.dart' as rtc;

class Book extends rt.CustomObject {
  static const NAME = 'Book';
  Book() : super(NAME);

  String get title => getField('title');
  String get author => getField('author');
  String get isbon => getField('isbn');
  bool get isCheckedOut => getField('isCheckedOut');
  String get reviews => getField('reviews');
  set title(String title) => setField('title', title);
  set author(String author) => setField('author', author);
  set isbn(String isbn) => setField('isbn', isbn);
  set isCheckedOut(bool isCheckedOut) => setField('isCheckedOut', isCheckedOut);
  set reviews(String reviews) => setField('reviews', reviews);
}

initializeModel(model) {
  var book = model.create(Book.NAME);
  model.root['book'] = book;
}

/**
 * This function is called when the Realtime file has been loaded. It should
 * be used to initialize any user interface components and event handlers
 * depending on the Realtime model. In this case, create a text control binder
 * and bind it to our string model that we created in initializeModel.
 * @param doc {gapi.drive.realtime.Document} the Realtime document.
 */
onFileLoaded(doc) {
  Book book = doc.model.root['book'];

  // collaborators listener
  doc.onCollaboratorJoined.listen((rt.CollaboratorJoinedEvent e){
    print("user joined : ${e.collaborator.displayName}");
  });
  doc.onCollaboratorLeft.listen((rt.CollaboratorLeftEvent e){
    print("user left : ${e.collaborator.displayName}");
  });

  // listener on keyup
  final title = document.getElementById('title') as TextInputElement;
  title.value = book.title != null ? book.title : "";
  title.onKeyUp.listen((e) {
    book.title = title.value;
  });

  // update input on changes
  book.onObjectChanged.listen((rt.ObjectChangedEvent e){
    print("object changes : ${e}");
    title.value = book.title;
  });
  book.onValueChanged.listen((rt.ValueChangedEvent e){
    print("value changes : ${e}");
  });

  // Enabling UI Elements.
  title.disabled = false;
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
});


main() {
  // set clientId
  rt.GoogleDocProvider.clientId = 'INSERT YOUR CLIENT ID HERE';

  var docProvider = new rt.GoogleDocProvider.newDoc('rdm test doc');
//  var docProvider = new rt.LocalDocumentProvider();

  rt.CustomObject.registerType(Book, "Book", ["title", "author", "isbn", "isCheckedOut", "reviews"]);

  docProvider.loadDocument(initializeModel).then(onFileLoaded);

  //var realtimeLoader = new js.Proxy(js.context.rtclient.RealtimeLoader, realtimeOptions);
//  realtimeLoader.start((){
    //Book.registerType();
//  });
}
