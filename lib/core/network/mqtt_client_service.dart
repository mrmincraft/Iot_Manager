import 'package:iot_manager/core/network/api_config.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';

/// MQTT Connection state
enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  failed,
}

/// MQTT QoS (Quality of Service)
enum MqttQoS {
  atMostOnce,  // 0
  atLeastOnce, // 1
  exactlyOnce, // 2
}

/// MQTT Connection result callback
typedef MqttConnectionCallback = void Function(MqttConnectionState state);

/// MQTT Message received callback
typedef MqttMessageCallback = void Function(String topic, List<int> payload);

/// MQTT Client Service for MQTT protocol communication
/// 
/// Responsibilities:
/// - Connect to MQTT broker
/// - Subscribe/unsubscribe to topics
/// - Publish messages to topics
/// - Handle connection state
/// - Manage QoS levels
/// - Handle reconnection
abstract class MqttClientService {
  /// Connect to MQTT broker
  Future<Result<void, NetworkException>> connect({
    String? username,
    String? password,
    String? clientId,
  });

  /// Disconnect from MQTT broker
  Future<Result<void, NetworkException>> disconnect();

  /// Subscribe to topic
  Future<Result<void, NetworkException>> subscribe(
    String topic, {
    MqttQoS qos = MqttQoS.atLeastOnce,
  });

  /// Unsubscribe from topic
  Future<Result<void, NetworkException>> unsubscribe(String topic);

  /// Publish message to topic
  Future<Result<void, NetworkException>> publish(
    String topic,
    List<int> payload, {
    MqttQoS qos = MqttQoS.atLeastOnce,
    bool retain = false,
  });

  /// Get current connection state
  MqttConnectionState get connectionState;

  /// Register connection state callback
  void onConnectionStateChanged(MqttConnectionCallback callback);

  /// Register message received callback
  void onMessageReceived(MqttMessageCallback callback);

  /// Is currently connected
  bool get isConnected;

  /// Reconnect to broker
  Future<Result<void, NetworkException>> reconnect();
}

/// MQTT Client Service Implementation
class MqttClientServiceImpl implements MqttClientService {
  final ApiConfig _apiConfig;
  
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  MqttConnectionCallback? _connectionCallback;
  MqttMessageCallback? _messageCallback;
  
  final List<String> _subscribedTopics = [];
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  MqttClientServiceImpl({required ApiConfig apiConfig})
      : _apiConfig = apiConfig;

  @override
  Future<Result<void, NetworkException>> connect({
    String? username,
    String? password,
    String? clientId,
  }) async {
    try {
      _updateConnectionState(MqttConnectionState.connecting);

      // Placeholder: In real implementation, use mqtt_client package
      // client.connect(username, password);
      
      _updateConnectionState(MqttConnectionState.connected);
      _reconnectAttempts = 0;
      
      return Result.success(null);
    } catch (e) {
      _updateConnectionState(MqttConnectionState.failed);
      return Result.failure(
        MqttException(
          message: 'Failed to connect: $e',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<void, NetworkException>> disconnect() async {
    try {
      _updateConnectionState(MqttConnectionState.disconnecting);
      
      // Placeholder: In real implementation, use mqtt_client package
      // client.disconnect();
      
      _updateConnectionState(MqttConnectionState.disconnected);
      _subscribedTopics.clear();
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        MqttException(
          message: 'Failed to disconnect: $e',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<void, NetworkException>> subscribe(
    String topic, {
    MqttQoS qos = MqttQoS.atLeastOnce,
  }) async {
    if (!_isConnected) {
      return Result.failure(
        MqttException(
          message: 'Not connected to broker',
          code: 'NOT_CONNECTED',
        ),
      );
    }

    try {
      // Placeholder: In real implementation, use mqtt_client package
      // client.subscribe(topic, _mqttQosToInt(qos));
      
      _subscribedTopics.add(topic);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        MqttSubscriptionException(
          topic: topic,
          message: 'Failed to subscribe: $e',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<void, NetworkException>> unsubscribe(String topic) async {
    if (!_isConnected) {
      return Result.failure(
        MqttException(
          message: 'Not connected to broker',
          code: 'NOT_CONNECTED',
        ),
      );
    }

    try {
      // Placeholder: In real implementation, use mqtt_client package
      // client.unsubscribe(topic);
      
      _subscribedTopics.remove(topic);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        MqttSubscriptionException(
          topic: topic,
          message: 'Failed to unsubscribe: $e',
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<Result<void, NetworkException>> publish(
    String topic,
    List<int> payload, {
    MqttQoS qos = MqttQoS.atLeastOnce,
    bool retain = false,
  }) async {
    if (!_isConnected) {
      return Result.failure(
        MqttException(
          message: 'Not connected to broker',
          code: 'NOT_CONNECTED',
        ),
      );
    }

    try {
      // Placeholder: In real implementation, use mqtt_client package
      // final builder = MqttClientPayloadBuilder();
      // builder.addBuffer(payload);
      // client.publishMessage(topic, _mqttQosToInt(qos), builder.payload!, retain: retain);
      
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        MqttPublishException(
          topic: topic,
          payload: String.fromCharCodes(payload),
          message: 'Failed to publish: $e',
          originalError: e,
        ),
      );
    }
  }

  @override
  MqttConnectionState get connectionState => _connectionState;

  @override
  bool get isConnected => _connectionState == MqttConnectionState.connected;

  bool get _isConnected => isConnected;

  @override
  void onConnectionStateChanged(MqttConnectionCallback callback) {
    _connectionCallback = callback;
  }

  @override
  void onMessageReceived(MqttMessageCallback callback) {
    _messageCallback = callback;
  }

  @override
  Future<Result<void, NetworkException>> reconnect() async {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return Result.failure(
        MqttException(
          message: 'Max reconnect attempts reached',
          code: 'MAX_RECONNECT_ATTEMPTS',
        ),
      );
    }

    _reconnectAttempts++;

    // Exponential backoff
    await Future.delayed(
      Duration(seconds: (2 ^ _reconnectAttempts).toInt().clamp(1, 60)),
    );

    return connect();
  }

  void _updateConnectionState(MqttConnectionState newState) {
    _connectionState = newState;
    _connectionCallback?.call(newState);
  }

  int _mqttQosToInt(MqttQoS qos) {
    switch (qos) {
      case MqttQoS.atMostOnce:
        return 0;
      case MqttQoS.atLeastOnce:
        return 1;
      case MqttQoS.exactlyOnce:
        return 2;
    }
  }
}
