import 'apillon-logger.dart';

class ApillonApiError implements Exception {
  final String message;

  ApillonApiError(this.message);
}

class ApillonRequestError implements Exception {
  final String message;

  ApillonRequestError(this.message);
}

class ApillonNetworkError implements Exception {
  final String message;

  ApillonNetworkError(this.message);
}

/// Convert value to boolean if defined, else return undefined.
/// @param value value converted
bool? toBoolean(String? value) {
  if (value == null) {
    return null;
  }
  return value == 'true' || value == '1' || value.isNotEmpty;
}

/// Convert value to integer if defined, else return undefined.
/// @param value value converted
int? toInteger(String? value) {
  if (value == null) {
    return null;
  }
  return int.tryParse(value);
}

/// Construct full URL from base URL and query parameters object.
/// @param url url without query parameters
/// @param parameters query parameters
String constructUrlWithQueryParams(
    String url, Map<String, dynamic>? parameters) {
  if (parameters == null) {
    return url;
  }
  final cleanParams = Map<String, dynamic>.from(parameters)
    ..removeWhere((key, value) => value == null || value == '');
  final queryParams = Uri(
      queryParameters: cleanParams
          .map((key, value) => MapEntry(key, value.toString()))).query;
  return queryParams.isNotEmpty ? '$url?$queryParams' : url;
}

/// Exception handler for requests sent by CLI service.
/// @param e exception
void exceptionHandler(dynamic e) {
  if (e is ApillonApiError) {
    ApillonLogger.e('Apillon API error:\n${e.message}');
  } else if (e is ApillonNetworkError) {
    ApillonLogger.e('Error: ${e.message}');
  } else {
    ApillonLogger.e(e);
  }
}
