Dart Realtime Data Model
based on [Dart Google Drive Realtime](https://github.com/a14n/dart-google-drive-realtime)
==========================

This project is a library that constrains the Dart Google Drive Realtime API and provides a local implementation so that applications can write to a single API whether the backing data is a Google Document or a local object.
It is based on [Dart Google Drive Realtime](https://github.com/a14n/dart-google-drive-realtime).
It uses [JS Interop library](https://github.com/dart-lang/js-interop) and its scoped approch to prevent memory leaks. You can have a look at [Js Interop documentation](http://dart-lang.github.com/js-interop/docs/js.html) for more informations.

## Usage ##
To use this library in your code :

* add a dependency in your `pubspec.yaml` :

```yaml
dependencies:
  realtime_data_model: "0.0.0"
```

* add import in your `dart` code :

```dart
import 'package:realtime_data_model/realtime_data_model.dart';
```

* Follow the steps described at [Create a Realtime Application](https://developers.google.com/drive/realtime/application) or begin using the library locally with:

```dart
start(realtimeOptions, local: true)
```

The library is currently unstable and does not support custom objects or databinding.

## License ##
Apache 2.0
