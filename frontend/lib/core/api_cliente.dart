import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? '',
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
      headers: {'Accept': 'application/json'},
    ),
  );
}