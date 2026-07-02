/// Network-specific exceptions and error handling

/// Base network exception
class NetworkException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  NetworkException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'NetworkException: $message (Code: $code)';
}

/// Connection timeout exception
class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException({
    String message = 'Request timeout',
    String? code = 'TIMEOUT',
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// No internet connection exception
class NoInternetException extends NetworkException {
  NoInternetException({
    String message = 'No internet connection',
    String? code = 'NO_INTERNET',
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// Server error exception (5xx)
class ServerException extends NetworkException {
  final int statusCode;

  ServerException({
    required this.statusCode,
    String message = 'Server error',
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code ?? 'SERVER_ERROR_$statusCode',
    originalError: originalError,
  );
}

/// Client error exception (4xx)
class ClientException extends NetworkException {
  final int statusCode;

  ClientException({
    required this.statusCode,
    String message = 'Client error',
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code ?? 'CLIENT_ERROR_$statusCode',
    originalError: originalError,
  );
}

/// Unauthorized exception (401)
class UnauthorizedException extends ClientException {
  UnauthorizedException({
    String message = 'Unauthorized',
    String? code = 'UNAUTHORIZED',
    dynamic originalError,
  }) : super(
    statusCode: 401,
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// Forbidden exception (403)
class ForbiddenException extends ClientException {
  ForbiddenException({
    String message = 'Forbidden',
    String? code = 'FORBIDDEN',
    dynamic originalError,
  }) : super(
    statusCode: 403,
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// Not found exception (404)
class NotFoundException extends ClientException {
  NotFoundException({
    String message = 'Resource not found',
    String? code = 'NOT_FOUND',
    dynamic originalError,
  }) : super(
    statusCode: 404,
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// Bad request exception (400)
class BadRequestException extends ClientException {
  BadRequestException({
    String message = 'Bad request',
    String? code = 'BAD_REQUEST',
    dynamic originalError,
  }) : super(
    statusCode: 400,
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// Conflict exception (409)
class ConflictException extends ClientException {
  ConflictException({
    String message = 'Resource conflict',
    String? code = 'CONFLICT',
    dynamic originalError,
  }) : super(
    statusCode: 409,
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// MQTT connection exception
class MqttException extends NetworkException {
  MqttException({
    String message = 'MQTT connection error',
    String? code = 'MQTT_ERROR',
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// MQTT subscription exception
class MqttSubscriptionException extends MqttException {
  final String topic;

  MqttSubscriptionException({
    required this.topic,
    String message = 'MQTT subscription error',
    String? code = 'MQTT_SUBSCRIBE_ERROR',
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );
}

/// MQTT publish exception
class MqttPublishException extends MqttException {
  final String topic;
  final String payload;

  MqttPublishException({
    required this.topic,
    required this.payload,
    String message = 'MQTT publish error',
    String? code = 'MQTT_PUBLISH_ERROR',
    dynamic originalError,
  }) : super(
    message: message,
    code: code,
    originalError: originalError,
  );
}
