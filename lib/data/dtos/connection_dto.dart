// DTO: ConnectionDTO
// Data Transfer Object pour Connection

class ConnectionDTO {
  final String id;
  final String name;
  final String protocolId;
  final String host;
  final int port;
  final String status;
  final bool useTLS;
  final String? certificateId;
  final String? username;
  final String? password;
  final Map<String, String> customSettings;
  final int reconnectAttempts;
  final int reconnectIntervalSeconds;
  final bool autoReconnect;
  final String? lastError;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final int connectionDurationSeconds;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConnectionDTO({
    required this.id,
    required this.name,
    required this.protocolId,
    required this.host,
    required this.port,
    required this.status,
    required this.useTLS,
    this.certificateId,
    this.username,
    this.password,
    required this.customSettings,
    required this.reconnectAttempts,
    required this.reconnectIntervalSeconds,
    required this.autoReconnect,
    this.lastError,
    this.lastConnectedAt,
    this.lastDisconnectedAt,
    required this.connectionDurationSeconds,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConnectionDTO.fromJson(Map<String, dynamic> json) {
    return ConnectionDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      protocolId: json['protocolId'] as String,
      host: json['host'] as String,
      port: json['port'] as int,
      status: json['status'] as String,
      useTLS: json['useTLS'] as bool,
      certificateId: json['certificateId'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      customSettings: Map<String, String>.from(json['customSettings'] as Map? ?? {}),
      reconnectAttempts: json['reconnectAttempts'] as int,
      reconnectIntervalSeconds: json['reconnectIntervalSeconds'] as int,
      autoReconnect: json['autoReconnect'] as bool,
      lastError: json['lastError'] as String?,
      lastConnectedAt: json['lastConnectedAt'] != null ? DateTime.parse(json['lastConnectedAt'] as String) : null,
      lastDisconnectedAt: json['lastDisconnectedAt'] != null ? DateTime.parse(json['lastDisconnectedAt'] as String) : null,
      connectionDurationSeconds: json['connectionDurationSeconds'] as int,
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protocolId': protocolId,
      'host': host,
      'port': port,
      'status': status,
      'useTLS': useTLS,
      'certificateId': certificateId,
      'username': username,
      'password': password,
      'customSettings': customSettings,
      'reconnectAttempts': reconnectAttempts,
      'reconnectIntervalSeconds': reconnectIntervalSeconds,
      'autoReconnect': autoReconnect,
      'lastError': lastError,
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
      'lastDisconnectedAt': lastDisconnectedAt?.toIso8601String(),
      'connectionDurationSeconds': connectionDurationSeconds,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ConnectionDTO(id: $id, name: $name, status: $status)';
}
