import 'package:dio/dio.dart';
import 'package:al_munir/core/constants/api_constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters, CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters, cancelToken: cancelToken);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> download(String urlPath, savePath, {ProgressCallback? onReceiveProgress, CancelToken? cancelToken}) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception("Connection Timeout. Please check your internet.");
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception("No Internet Connection.");
    } else {
      return Exception("Server Error: ${error.message}");
    }
  }
}
