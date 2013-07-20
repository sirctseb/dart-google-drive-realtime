import 'dart:html';
import 'dart:async';

import 'package:js/js.dart' as js;
import 'package:js/js_wrapping.dart' as jsw;
import 'package:realtime_data_model/realtime_data_model.dart' as rt;
import 'package:realtime_data_model/realtime_data_model_custom.dart' as rtc;

class Book extends rt.CollaborativeObject {
  static const NAME = 'Book';
  static void registerType() {
    js.context.Book = new js.Callback.many((){});
    rtc.registerType(js.context.Book, NAME);
    js.context.Book.prototype.title = rtc.collaborativeField('title');
    js.context.Book.prototype.author = rtc.collaborativeField('author');
    js.context.Book.prototype.isbn = rtc.collaborativeField('isbn');
    js.context.Book.prototype.isCheckedOut = rtc.collaborativeField('isCheckedOut');
    js.context.Book.prototype.reviews = rtc.collaborativeField('reviews');
  }
  static Book cast(js.Proxy proxy) => proxy == null ? null : new Book.fromProxy(proxy);

  Book.fromProxy(js.Proxy proxy) : super.fromProxy(proxy);

  String get title => $unsafe.title;
  String get author => $unsafe.author;
  String get isbn => $unsafe.isbn;
  bool get isCheckedOut => $unsafe.isCheckedOut;
  String get reviews => $unsafe.reviews;
  set title(String title) => $unsafe.title = title;
  set author(String author) => $unsafe.author = author;
  set isbn(String isbn) => $unsafe.isbn = isbn;
  set isCheckedOut(bool isCheckedOut) => $unsafe.isCheckedOut = isCheckedOut;
  set reviews(String reviews) => $unsafe.reviews = reviews;
}

initializeModel(js.Proxy modelProxy) {
  var model = rt.Model.cast(modelProxy);
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
onFileLoaded(docProxy) {
  var doc = rt.Document.cast(docProxy);
  var book = Book.cast(doc.model.root['book']);
  js.retain(book);

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
    Book.registerType();
  }));
}
