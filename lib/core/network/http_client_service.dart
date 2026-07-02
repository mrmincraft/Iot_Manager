import 'package:iot_manager/core/network/api_config.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';

/// HTTP Client Service for making API requests
/// 
/// Responsibilities:
/// - Handle HTTP GET, POST, PUT, DELETE, PATCH requests
/// - Manage authentication headers
/// - Handle request/response serialization
/// - Implement retry logic with exponential backoff
/// - Convert HTTP errors to domain exceptions
abstract class HttpClientService {
  /// GET request
  Future<Result<T, NetworkException>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  /// POST request
  Future<Result<T, NetworkException>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });

  /// PUT request
  Future<Result<T, NetworkException>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });

  /// PATCH request
  Future<Result<T, NetworkException>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  });

  /// DELETE request
  Future<Result<T, NetworkException>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  /// Set authentication token
  void setAuthToken(String token);

  /// Clear authentication token
  void clearAuthToken();

  /// Get current authentication token
  String? getAuthToken();
}

/// HTTP Client Service Implementation
class HttpClientServiceImpl implements HttpClientService {
  final ApiConfig _apiConfig;
  String? _authToken;

  HttpClientServiceImpl({required ApiConfig apiConfig})
      : _apiConfig = apiConfig;

  @override
  Future<Result<T, NetworkException>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest<T>(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<Result<T, NetworkException>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest<T>(
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<Result<T, NetworkException>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest<T>(
      method: 'PUT',
      endpoint: endpoint,
      headers: headers,
      body: body,
    );
  }

  @override
  Future<Result<T, NetworkException>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest<T>(
      method: 'PATCH',
      endpoint: endpoint,
      headers: headers,
      body: body,
    );
  }

  @override
  Future<Result<T, NetworkException>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest<T>(
      method: 'DELETE',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<Result<T, NetworkException>> _executeRequest<T>({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    int retryCount = 0;
    
    while (retryCount <= _apiConfig.maxRetries) {
      try {
        // Build full URL
        final url = _buildUrl(endpoint, queryParameters);
        
        // Merge headers with auth
        final requestHeaders = _buildHeaders(headers);
        
        // Simulate HTTP request (would use http package in real implementation)
        // This is a placeholder for the actual HTTP client library
        final response = await _makeHttpRequest<T>(
          method: method,
          url: url,
          headers: requestHeaders,
          body: body,
        );

        return response;
      } on NetworkException catch (e) {
        retryCount++;
        
        // Determine if retryable
        if (retryCount > _apiConfig.maxRetries || !_isRetryable(e)) {
          return Result.failure(e);
        }
        
        // Exponential backoff
        await Future.delayed(
          Duration(seconds: (2 ^ retryCount).toInt()),
        );
      } catch (e) {
        return Result.failure(
          NetworkException(
            message: 'Unexpected error: $e',
            code: 'UNKNOWN_ERROR',
            originalError: e,
          ),
        );
      }
    }

    return Result.failure(
      NetworkException(
        message: 'Max retries exceeded',
        code: 'MAX_RETRIES_EXCEEDED',
      ),
    );
  }

  String _buildUrl(String endpoint, Map<String, dynamic>? queryParameters) {
    final url = '${_apiConfig.baseUrl}$endpoint';
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return '$url?$queryString';
    }
    
    return url;
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Future<Result<T, NetworkException>> _makeHttpRequest<T>({
    required String method,
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) async {
    // Placeholder: In real implementation, use http.Client or dio
    // This would make actual HTTP requests
    
    // For now, return a placeholder success
    return Result.success(null as T);
  }

  bool _isRetryable(NetworkException exception) {
    // Retry on timeout or no internet
    if (exception is NetworkTimeoutException ||
        exception is NoInternetException) {
      return true;
    }
    
    // Retry on server errors (5xx)
    if (exception is ServerException) {
      return exception.statusCode >= 500;
    }
    
    return false;
  }

  @override
  void setAuthToken(String token) {
    _authToken = token;
  }

  @override
  void clearAuthToken() {
    _authToken = null;
  }

  @override
  String? getAuthToken() => _authToken;
}
