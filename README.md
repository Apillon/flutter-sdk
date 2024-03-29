<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Requirements

DART SDK: '>=3.2.2 <4.0.0'
Apillon API key and secret

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

To be able to use Apillon package, you must register and account at [Apillon.io], create a project and generate an API key with appropriate permissions.

## Usage

```dart
getBuckets() async {
  Storage s = Storage(ApillonConfig(
      secret: {secret},
      key: {key}));
  final buckets = await s.listBuckets(IApillonPagination());
}
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
