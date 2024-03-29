// ignore_for_file: file_names, avoid_print

import 'package:intl/intl.dart';
import '../types/apillon.dart';

class ApillonLogger {
  static LogLevel _logLevel = LogLevel.NONE;

  static void initialize([LogLevel? logLevel]) {
    _logLevel = logLevel ?? LogLevel.NONE;
  }

  static void log(dynamic message, [LogLevel logLevel = LogLevel.VERBOSE]) {
    if (_logLevel.index >= logLevel.index) {
      if (message is Object) {
        print(message);
      } else {
        print(message);
      }
    }
  }

  static void e(dynamic message) {
    log(message, LogLevel.ERROR);
  }
  // static void w(dynamic message) {
  //   log(message, LogLevel.);
  // }

  static void logWithTime(dynamic message,
      [LogLevel logLevel = LogLevel.VERBOSE]) {
    if (_logLevel.index >= logLevel.index) {
      final formattedTime =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());
      if (message is Object) {
        print('$formattedTime: $message');
      } else {
        print('$formattedTime: $message');
      }
    }
  }
}
