/// Command Entity
/// 
/// Represents a command sent to a device
class Command {
  final String id;
  final String deviceId;
  final String commandType;
  final Map<String, dynamic> parameters;
  final String status; // 'pending', 'sent', 'executed', 'failed'
  final String? response;
  final DateTime sentAt;
  final DateTime? executedAt;
  final String? error;
  
  const Command({
    required this.id,
    required this.deviceId,
    required this.commandType,
    required this.parameters,
    required this.status,
    this.response,
    required this.sentAt,
    this.executedAt,
    this.error,
  });
  
  Command copyWith({
    String? id,
    String? deviceId,
    String? commandType,
    Map<String, dynamic>? parameters,
    String? status,
    String? response,
    DateTime? sentAt,
    DateTime? executedAt,
    String? error,
  }) {
    return Command(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      commandType: commandType ?? this.commandType,
      parameters: parameters ?? this.parameters,
      status: status ?? this.status,
      response: response ?? this.response,
      sentAt: sentAt ?? this.sentAt,
      executedAt: executedAt ?? this.executedAt,
      error: error ?? this.error,
    );
  }
}
