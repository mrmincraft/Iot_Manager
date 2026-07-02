/// Configuration for backend API endpoints and MQTT broker
/// 
/// Supports multiple environments (development, staging, production)
abstract class ApiConfig {
  /// API Base URL
  String get baseUrl;
  
  /// MQTT Broker URL
  String get mqttBrokerUrl;
  
  /// MQTT Broker Port
  int get mqttBrokerPort;
  
  /// WebSocket URL for real-time events
  String get websocketUrl;
  
  /// Request timeout in seconds
  int get requestTimeoutSeconds;
  
  /// Connection retry count
  int get maxRetries;
  
  /// Environment name
  String get environment;
}

/// Development environment configuration
class DevelopmentApiConfig implements ApiConfig {
  @override
  String get baseUrl => 'http://localhost:8080/api/v1';
  
  @override
  String get mqttBrokerUrl => 'localhost';
  
  @override
  int get mqttBrokerPort => 1883;
  
  @override
  String get websocketUrl => 'ws://localhost:8080/ws';
  
  @override
  int get requestTimeoutSeconds => 30;
  
  @override
  int get maxRetries => 3;
  
  @override
  String get environment => 'development';
}

/// Staging environment configuration
class StagingApiConfig implements ApiConfig {
  @override
  String get baseUrl => 'https://staging-api.iotmanager.com/api/v1';
  
  @override
  String get mqttBrokerUrl => 'staging-mqtt.iotmanager.com';
  
  @override
  int get mqttBrokerPort => 8883;
  
  @override
  String get websocketUrl => 'wss://staging-api.iotmanager.com/ws';
  
  @override
  int get requestTimeoutSeconds => 30;
  
  @override
  int get maxRetries => 3;
  
  @override
  String get environment => 'staging';
}

/// Production environment configuration
class ProductionApiConfig implements ApiConfig {
  @override
  String get baseUrl => 'https://api.iotmanager.com/api/v1';
  
  @override
  String get mqttBrokerUrl => 'mqtt.iotmanager.com';
  
  @override
  int get mqttBrokerPort => 8883;
  
  @override
  String get websocketUrl => 'wss://api.iotmanager.com/ws';
  
  @override
  int get requestTimeoutSeconds => 30;
  
  @override
  int get maxRetries => 5;
  
  @override
  String get environment => 'production';
}

/// Factory to create API config based on environment
class ApiConfigFactory {
  static ApiConfig create(String environment) {
    switch (environment.toLowerCase()) {
      case 'development':
        return DevelopmentApiConfig();
      case 'staging':
        return StagingApiConfig();
      case 'production':
        return ProductionApiConfig();
      default:
        return DevelopmentApiConfig();
    }
  }
}
