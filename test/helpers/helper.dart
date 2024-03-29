import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' show join, dirname;

import 'package:apillon_flutter/libs/apillon.dart';
import 'package:apillon_flutter/types/apillon.dart';

DotEnv dotEnv = DotEnv();

ApillonConfig getConfig() {
  // Configure dotenv with the absolute path
  final envPath = join(dirname(Platform.script.toFilePath()), '.env');
  dotEnv.testLoad(fileInput: File(envPath).readAsStringSync());

  return ApillonConfig(
      secret: dotEnv.env['APILLON_API_SECRET'],
      key: dotEnv.env['APILLON_API_KEY'],
      logLevel: LogLevel.VERBOSE);
}

String getBucketUUID() {
  return dotEnv.env['BUCKET_UUID'] ?? "";
}

String getCollectionUUID() {
  return dotEnv.env['COLLECTION_UUID'] ?? "";
}

String getWebsiteUUID() {
  return dotEnv.env['WEBSITE_UUID'] ?? "";
}

String getMintAddress() {
  return dotEnv.env['MINT_ADDRESS'] ?? "";
}

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((v) => v.toString().split('.')[1] == value);
}
