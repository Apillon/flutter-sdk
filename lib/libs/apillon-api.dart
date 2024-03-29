// ignore_for_file: file_names
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../types/apillon.dart';
import './apillon.dart';
import './apillon-logger.dart';
import './common.dart';

class IApillonResponse<T> {
  final String id;
  final int status;
  final T data;

  IApillonResponse(
      {required this.id, required this.status, required this.data});

  factory IApillonResponse.fromJson(Map<String, dynamic> json) {
    return IApillonResponse(
      id: json['id'] as String,
      status: json['status'] as int,
      data: json['data'] as T,
    );
  }
}

validateResponse(http.Response response) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApillonApiError(response.body);
  }
  return true;
}

class ApillonApi {
  static final http.Client _client = http.Client();
  static Map<String, String> headers = {'content-type': 'application/json'};
  static String apiUrl = "";

  static void initialize(ApillonConfig? apiConfig) {
    final config = ApillonConfig(
      key: apiConfig?.key ?? Platform.environment['APILLON_API_KEY'],
      secret: apiConfig?.secret ?? Platform.environment['APILLON_API_SECRET'],
      apiUrl: apiConfig?.apiUrl ?? 'https://api.apillon.io',
      logLevel: apiConfig?.logLevel ?? LogLevel.NONE,
    );

    headers = {'content-type': 'application/json'};
    if (config.key != null &&
        config.key != "" &&
        config.secret != null &&
        config.secret != "") {
      headers['authorization'] = 'Basic ${base64Encode(utf8.encode(
        '${config.key}:${config.secret}',
      ))}';
    }
    apiUrl = config.apiUrl!;
  }

  static Future<T> get<T>(String url,
      {Function(Map<String, dynamic>)? mapper}) async {
    try {
      final response =
          await _client.get(Uri.parse(apiUrl + url), headers: headers);
      validateResponse(response);
      final jsonResponse = IApillonResponse.fromJson(jsonDecode(response.body));
      if (mapper != null) {
        return mapper(jsonResponse.data);
      }
      return jsonResponse.data;
    } on SocketException {
      throw ApillonNetworkError('No Internet connection');
    } on HttpException catch (e) {
      ApillonLogger.log(e.message, LogLevel.ERROR);
      throw ApillonRequestError(e.message);
    } on FormatException catch (e) {
      ApillonLogger.log(e.message, LogLevel.ERROR);
      throw ApillonRequestError(e.message);
    }
  }

  static Future<T> post<T>(String url, dynamic body,
      {Function(Map<String, dynamic>)? mapper}) async {
    try {
      final response = await _client.post(Uri.parse(apiUrl + url),
          headers: headers, body: body != null ? jsonEncode(body) : null);
      validateResponse(response);
      final jsonResponse = IApillonResponse.fromJson(jsonDecode(response.body));
      if (mapper != null) {
        return mapper(jsonResponse.data);
      }
      return jsonResponse.data;
    } on SocketException {
      throw ApillonNetworkError('No Internet connection');
    } on HttpException catch (e) {
      ApillonLogger.log(e.message, LogLevel.ERROR);
      throw ApillonRequestError(e.message);
    } on FormatException catch (e) {
      ApillonLogger.log(e.message, LogLevel.ERROR);
      throw ApillonRequestError(e.message);
    }
  }

  static Future<T> delete<T>(String url,
      {Function(Map<String, dynamic>)? mapper}) async {
    try {
      final response =
          await _client.delete(Uri.parse(apiUrl + url), headers: headers);
      validateResponse(response);
      final jsonResponse = IApillonResponse.fromJson(jsonDecode(response.body));
      if (mapper != null) {
        return mapper(jsonResponse.data);
      }
      return jsonResponse.data;
    } on SocketException {
      throw ApillonNetworkError('No Internet connection');
    } on HttpException catch (e) {
      ApillonLogger.log(e.message, LogLevel.ERROR);
      throw ApillonRequestError(e.message);
    } on FormatException catch (e) {
      ApillonLogger.log(e.message, LogLevel.ERROR);
      throw ApillonRequestError(e.message);
    }
  }
}
