// ignore_for_file: duplicate_ignore
import './../types/apillon.dart';
import './apillon-api.dart';
import './apillon-logger.dart';

class ApillonConfig {
  /// Your API key, generated through the Apillon dashboard
  /// @default env.APILLON_API_KEY
  String? key;

  /// Your API secret, generated through the Apillon dashboard
  /// @default env.APILLON_API_SECRET
  String? secret;

  /// The API URL to use for executing the queries and actions.
  /// @default https://api.apillon.io
  String? apiUrl;

  /// The level of logger output to use for the Apillon logger.
  /// @default ERROR
  LogLevel? logLevel;

  /// Used for CLI - indicates whether to output verbose logs
  /// @default false
  bool? debug;

  ApillonConfig({
    this.key,
    this.secret,
    this.apiUrl,
    this.logLevel = LogLevel.ERROR,
    this.debug = false,
  });
}

class ApillonModule {
  ApillonModule(ApillonConfig? config) {
    ApillonApi.initialize(config);
    ApillonLogger.initialize(
      (config?.debug ?? false)
          ? LogLevel.VERBOSE
          : (config?.logLevel ?? LogLevel.ERROR),
    );
  }
}

abstract class ApillonModel {
  /// API url prefix for this class.
  String? apiPrefix;

  /// Unique identifier of the model.
  String uuid;

  /// The object's creation date
  String? createTime;

  /// The date when the object was last updated
  String? updateTime;

  ApillonModel(this.uuid);

  Map<String, dynamic> toMap() {
    return {
      "apiPrefix": apiPrefix,
      "uuid": uuid,
      "createTime": createTime,
      "updateTime": updateTime,
    };
  }

  /// Populates class properties via data object.
  /// @param data Data object.
  dynamic populate(dynamic data) {
    if (data != null) {
      (data as Map<String, dynamic>).forEach((key, value) {
        switch (key) {
          case "createTime":
            createTime ??= value;
            return;
          case "updateTime":
            updateTime ??= value;
            return;
        }
      });
    }
  }
}
