part of realtime_data_model;

class CustomObject extends CollaborativeObject {
  // information on the custom types registered
  static Map _registeredTypes = {};

  // TODO rename
  static js.Proxy _proxyToCreateFrom = null;

  CustomObject(String name) : super._fromProxy(_proxyToCreateFrom == null ? new js.Proxy(_registeredTypes[name]["js-type"]) : _proxyToCreateFrom) {
    if(_proxyToCreateFrom != null) _proxyToCreateFrom = null;
  }
  static CustomObject _createRegisteredType(String name, {fromProxy}) {
    _proxyToCreateFrom = fromProxy;
    return reflectClass(_registeredTypes[name]['dart-type']).newInstance(new Symbol(""), []).reflectee;
  }

  /// Register a custom object type
  static void registerType(Type type, String name, List fields) {
    // prepare js-side storage
    // TODO this is necessary to we can get a Proxy for the same JsObject we use here
    if(!jss.context.hasProperty('registered-types')) {
      jss.context['registered-types'] = {};
    }

    // create the js-side function
    _registeredTypes[name] = {'dart-type': type,
                             'js-type': new jss.JsObject(js.context['Function']),
                             'fields': fields};
    jss.context['registered-types'] = _registeredTypes[name]['js-type'];
    // do the js-side registration
    realtimeCustom.registerType(_registeredTypes[name]["js-type"], name);
  }

  SubscribeStreamProvider<ObjectChangedEvent> _onObjectChanged;
  SubscribeStreamProvider<ValueChangedEvent> _onValueChanged;

  Stream<ObjectChangedEvent> get onObjectChanged => _onObjectChanged.stream;
  Stream<ValueChangedEvent> get onValueChanged => _onValueChanged.stream;
}