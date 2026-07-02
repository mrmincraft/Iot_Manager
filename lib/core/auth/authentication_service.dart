import 'package:iot_manager/core/network/http_client_service.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';

/// User authentication credentials
class AuthCredentials {
  final String username;
  final String email;
  final String password;

  AuthCredentials({
    required this.username,
    required this.email,
    required this.password,
  });
}

/// Authentication token
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isExpiringSoon =>
      DateTime.now().add(const Duration(hours: 1)).isAfter(expiresAt);
}

/// Authenticated user
class AuthUser {
  final String id;
  final String username;
  final String email;
  final List<String> roles;
  final Map<String, dynamic> metadata;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    this.metadata = const {},
  });

  bool hasRole(String role) => roles.contains(role);

  bool hasPermission(String permission) {
    // Check if user has permission (could be based on role)
    return true;
  }
}

/// Authentication service
abstract class AuthenticationService {
  /// Login with credentials
  Future<Result<AuthToken, NetworkException>> login(AuthCredentials credentials);

  /// Register new user
  Future<Result<AuthUser, NetworkException>> register(AuthCredentials credentials);

  /// Refresh authentication token
  Future<Result<AuthToken, NetworkException>> refreshToken();

  /// Logout current user
  Future<Result<void, NetworkException>> logout();

  /// Get current authenticated user
  AuthUser? getCurrentUser();

  /// Get current authentication token
  AuthToken? getCurrentToken();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Verify token validity
  Future<bool> verifyToken(String token);
}

/// Authentication Service Implementation
class AuthenticationServiceImpl implements AuthenticationService {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/auth';

  AuthUser? _currentUser;
  AuthToken? _currentToken;

  AuthenticationServiceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<AuthToken, NetworkException>> login(
    AuthCredentials credentials,
  ) async {
    try {
      final result = await _httpClient.post<Map<String, dynamic>>(
        '$_baseEndpoint/login',
        body: {
          'username': credentials.username,
          'password': credentials.password,
        },
      );

      if (result.isSuccess) {
        final data = result.value!;
        final token = AuthToken(
          accessToken: data['accessToken'] ?? '',
          refreshToken: data['refreshToken'],
          expiresAt: DateTime.parse(data['expiresAt'] ?? DateTime.now().toString()),
        );

        _currentToken = token;
        _httpClient.setAuthToken(token.accessToken);

        // Fetch user info
        await _fetchCurrentUser();

        return Result.success(token);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<AuthUser, NetworkException>> register(
    AuthCredentials credentials,
  ) async {
    try {
      final result = await _httpClient.post<Map<String, dynamic>>(
        '$_baseEndpoint/register',
        body: {
          'username': credentials.username,
          'email': credentials.email,
          'password': credentials.password,
        },
      );

      if (result.isSuccess) {
        final data = result.value!;
        final user = AuthUser(
          id: data['id'] ?? '',
          username: data['username'] ?? '',
          email: data['email'] ?? '',
          roles: List<String>.from(data['roles'] ?? []),
        );

        _currentUser = user;

        return Result.success(user);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<AuthToken, NetworkException>> refreshToken() async {
    if (_currentToken?.refreshToken == null) {
      return Result.failure(
        UnauthorizedException(
          message: 'No refresh token available',
        ),
      );
    }

    try {
      final result = await _httpClient.post<Map<String, dynamic>>(
        '$_baseEndpoint/refresh',
        body: {
          'refreshToken': _currentToken!.refreshToken,
        },
      );

      if (result.isSuccess) {
        final data = result.value!;
        final newToken = AuthToken(
          accessToken: data['accessToken'] ?? '',
          refreshToken: data['refreshToken'],
          expiresAt: DateTime.parse(data['expiresAt'] ?? DateTime.now().toString()),
        );

        _currentToken = newToken;
        _httpClient.setAuthToken(newToken.accessToken);

        return Result.success(newToken);
      } else {
        return Result.failure(result.error!);
      }
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> logout() async {
    try {
      await _httpClient.post<void>('$_baseEndpoint/logout');

      _currentUser = null;
      _currentToken = null;
      _httpClient.clearAuthToken();

      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  AuthUser? getCurrentUser() => _currentUser;

  @override
  AuthToken? getCurrentToken() => _currentToken;

  @override
  bool get isAuthenticated => _currentToken != null && !_currentToken!.isExpired;

  @override
  Future<bool> verifyToken(String token) async {
    try {
      final result = await _httpClient.post<bool>(
        '$_baseEndpoint/verify',
        body: {'token': token},
      );

      return result.isSuccess && (result.value ?? false);
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      // Note: Offline-first system - user info is stored locally
      // This method is a placeholder for future remote sync functionality
      // Currently, user info remains local in secure storage only
    } catch (e) {
      // Handle error silently - offline mode continues without remote user data
    }
  }
}
