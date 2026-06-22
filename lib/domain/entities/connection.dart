/// Connection Entity
/// 
/// Represents a connection session between app and device
class Connection {
  final String id;
  final String deviceId;
  final String status; // 'connected', 'disconnected', 'connecting', 'error'
  final int signalStrength; // 0-100
  final DateTime connectedAt;
  final DateTime? disconnectedAt;
  final String? lastError;
  
  const Connection({
    required this.id,
    required this.deviceId,
    required this.status,
    required this.signalStrength,
    required this.connectedAt,
    this.disconnectedAt,
    this.lastError,
  });
  
  Connection copyWith({
    String? id,
    String? deviceId,
    String? status,
    int? signalStrength,
    DateTime? connectedAt,
    DateTime? disconnectedAt,
    String? lastError,
  }) {
    return Connection(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      signalStrength: signalStrength ?? this.signalStrength,
      connectedAt: connectedAt ?? this.connectedAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
      lastError: lastError ?? this.lastError,
    );
  }
}
