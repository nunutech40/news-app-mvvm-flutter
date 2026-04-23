import 'package:dio/dio.dart';
import 'package:news_app_mvvm/core/error/exceptions.dart';

import 'package:news_app_mvvm/core/constants/api_constants.dart';
import 'package:news_app_mvvm/core/network/auth_interceptor.dart';
import 'package:news_app_mvvm/core/network/token_provider.dart';
import 'package:news_app_mvvm/core/viewmodels/global_alert_viewmodel.dart';

class ApiClient {
  late final Dio dio;
  final GlobalAlertViewModel? globalAlertViewModel;

  ApiClient({
    required TokenProvider tokenProvider,
    this.globalAlertViewModel,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _addInterceptors(tokenProvider);
  }

  /// Test constructor — accepts a pre-configured Dio instance.
  ApiClient.withDio(
    this.dio, {
    required TokenProvider tokenProvider,
    this.globalAlertViewModel,
  }) {
    _addInterceptors(tokenProvider);
  }

  void _addInterceptors(TokenProvider tokenProvider) {
    dio.interceptors.addAll([
      AuthInterceptor(
        tokenProvider: tokenProvider,
        dio: dio,
      ),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    ]);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  Exception _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        globalAlertViewModel?.showNetworkError(isTimeout: true);
        return const NetworkException(message: 'Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        globalAlertViewModel?.showNetworkError(isTimeout: false);
        return const NetworkException(message: 'No internet connection.');
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'] as String;
        } else {
          message = 'Server error ($statusCode)';
        }
        break;
      default:
        message = e.message ?? 'Something went wrong';
    }

    return ServerException(message: message, statusCode: statusCode);
  }
}
