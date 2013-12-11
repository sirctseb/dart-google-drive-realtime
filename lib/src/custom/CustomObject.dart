part of realtime_data_model;

// TODO extending Container instead of Object for _translator
class CustomObject extends CollaborativeContainer {
  // information on the custom types registered
  static Map _registeredTypes = {};

  // TODO rename
  static js.Proxy _proxyToCreateFrom = null;

  CustomObject(String name) : super._fromProxy(_proxyToCreateFrom == null ? new js.Proxy(_registeredTypes[name]["js-type"]) : _proxyToCreateFrom) {
    if(_proxyToCreateFrom != null) _proxyToCreateFrom = null;
  }
  factory CustomObject._fromProxy(js.Proxy proxy) {
    _proxyToCreateFrom = proxy;
    return reflectClass(_registeredTypes[_findTypeName(proxy)]['dart-type']).newInstance(new Symbol(""), []).reflectee;
  }
  static String _findTypeName(js.Proxy proxy) {
    // search through registered types to find name of custom type
    for(var name in _registeredTypes.keys) {
      // TODO this won't work for types that aren't created locally
      if(_registeredTypes[name]['js-type'] == proxy.constructor) {
        return name;
      }
    }
    return null;
  }

  /// Register a custom object type
  static void registerType(Type type, String name, List fields) {
    // make sure js drive stuff is loaded
    // TODO refactor this
    GoogleDocProvider._globalSetup().then((bool success) {
      // store the dart type, js type, and fields
      _registeredTypes[name] = {'dart-type': type,
                                // TODO is this the best way to just create a js function?
                               'js-type': new js.FunctionProxy.withThis((p) {}),
                               'fields': fields};
      // do the js-side registration
      realtimeCustom.registerType(_registeredTypes[name]["js-type"], name);
      // add fields
      for(var field in fields) {
        _registeredTypes[name]['js-type']['prototype'][field] = realtimeCustom['collaborativeField'](field);
      }
    });
  }

  // TODO these could go in Container also probably
  dynamic _toJs(e) => _translator == null ? e : _translator.toJs(e);
  V _fromJs(dynamic value) => _translator == null ? value :
      _translator.fromJs(value);

  dynamic getField(String field) => $unsafe[field];
  void setField(String field, dynamic value) {
    print('setting custom object field $field to $value');
    $unsafe.title = _toJs(value);
  }
}