import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truklynk/utils/helper_functions.dart';

enum HttpMethod { get, post, put, delete }

extension HttpMethodExtension on HttpMethod {
  String get value {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }
}

class ApiService {
  // Base URL for the API (update as needed)
  // final String baseUrl = 'http://4.240.119.91:8084/api/goodone/';
  final String baseUrl = 'http://192.168.1.40:8084/api/goodone/';

  // Function to make HTTP requests
  Future<Map<String, dynamic>> makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    info("url $url");
    // Validate HTTP method
    if (!['GET', 'POST', 'PUT', 'DELETE'].contains(method.toUpperCase())) {
      return {'success': false, 'error': 'Invalid HTTP method'};
    }

    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response =
              await http.get(mapToQueryParams(url, body), headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers:
                headers ?? {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers:
                headers ?? {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          return {'success': false, 'error': 'Invalid HTTP method'};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        return jsonDecode(response.body);
      } else {
        // Server error
        return {
          'success': false,
          'error': 'Failed with status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network or other errors
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  Uri mapToQueryParams(Uri url, Map<String, dynamic>? data) {
    final uriWithParams = data != null
        ? url.replace(
            queryParameters: data.map((key, value) => MapEntry(
                  Uri.encodeComponent(key),
                  Uri.encodeComponent(value.toString()),
                )),
          )
        : url;
    return uriWithParams;
  }
}
