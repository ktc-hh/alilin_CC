import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pin.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Fetches pins from the free Picsum Photos API (no API key needed).
/// Docs: https://picsum.photos/
class PinApi {
  static const _baseUrl = 'https://picsum.photos/v2/list';

  Future<List<Pin>> fetchPins({int page = 1, int limit = 20}) async {
    final uri = Uri.parse('$_baseUrl?page=$page&limit=$limit');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException(
          'The server had a problem (code ${response.statusCode}). '
          'Please try again.',
        );
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => Pin.fromApi(item as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The request took too long. Check your connection.');
    } on FormatException {
      throw ApiException('We received unexpected data from the server.');
    } catch (_) {
      throw ApiException('No internet connection. Please check your network.');
    }
  }
}
