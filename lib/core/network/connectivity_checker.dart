/// Connection type enumeration
enum ConnectionType {
  none,
  mobile,
  wifi,
  ethernet,
  unknown,
}

/// Connectivity status callback
typedef ConnectivityStatusCallback = void Function(bool isConnected);

/// Connectivity change callback
typedef ConnectivityChangeCallback = void Function(ConnectionType type);

/// Network connectivity checker
/// 
/// Responsibilities:
/// - Monitor network connectivity
/// - Detect connection type (WiFi, mobile, etc.)
/// - Publish connectivity events
/// - Trigger offline/online actions
abstract class ConnectivityChecker {
  /// Check if device is currently connected to internet
  Future<bool> hasInternetConnection();

  /// Get current connection type
  Future<ConnectionType> getConnectionType();

  /// Listen for connectivity changes
  void onConnectivityChanged(ConnectivityChangeCallback callback);

  /// Listen for online/offline events
  void onConnectivityStatusChanged(ConnectivityStatusCallback callback);

  /// Start monitoring connectivity
  void startMonitoring();

  /// Stop monitoring connectivity
  void stopMonitoring();

  /// Get current status
  bool get isConnected;

  /// Get current connection type
  ConnectionType get currentConnectionType;
}

/// Connectivity Checker Implementation
class ConnectivityCheckerImpl implements ConnectivityChecker {
  bool _isConnected = true;
  ConnectionType _currentConnectionType = ConnectionType.unknown;

  ConnectivityChangeCallback? _connectivityChangeCallback;
  ConnectivityStatusCallback? _connectivityStatusCallback;

  bool _isMonitoring = false;

  @override
  Future<bool> hasInternetConnection() async {
    try {
      // Placeholder: In real implementation, would use connectivity_plus package
      // or perform actual connectivity checks (ping, DNS lookup, HTTP request)
      return _isConnected;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ConnectionType> getConnectionType() async {
    try {
      // Placeholder: In real implementation, would use connectivity_plus package
      return _currentConnectionType;
    } catch (e) {
      return ConnectionType.unknown;
    }
  }

  @override
  void onConnectivityChanged(ConnectivityChangeCallback callback) {
    _connectivityChangeCallback = callback;
  }

  @override
  void onConnectivityStatusChanged(ConnectivityStatusCallback callback) {
    _connectivityStatusCallback = callback;
  }

  @override
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;

    // Placeholder: In real implementation, would start listening to platform connectivity changes
    // and periodically check connection status
  }

  @override
  void stopMonitoring() {
    _isMonitoring = false;
    // Placeholder: In real implementation, would stop listening
  }

  @override
  bool get isConnected => _isConnected;

  @override
  ConnectionType get currentConnectionType => _currentConnectionType;

  /// Simulate connectivity change (for testing)
  void _simulateConnectivityChange(ConnectionType type) {
    final wasConnected = _isConnected;
    _currentConnectionType = type;
    _isConnected = type != ConnectionType.none;

    if (wasConnected != _isConnected) {
      _connectivityStatusCallback?.call(_isConnected);
    }

    _connectivityChangeCallback?.call(type);
  }

  /// Simulate going offline
  void simulateOffline() {
    _simulateConnectivityChange(ConnectionType.none);
  }

  /// Simulate going online
  void simulateOnline(ConnectionType type) {
    _simulateConnectivityChange(type);
  }
}
