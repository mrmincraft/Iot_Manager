// DTO: DashboardDTO
// Data Transfer Object pour Dashboard

class DashboardWidgetDTO {
  final String id;
  final String type;
  final String title;
  final String? connectionId;
  final String? topicId;
  final int position;
  final int width;
  final int height;
  final Map<String, dynamic> configuration;

  DashboardWidgetDTO({
    required this.id,
    required this.type,
    required this.title,
    this.connectionId,
    this.topicId,
    required this.position,
    required this.width,
    required this.height,
    required this.configuration,
  });

  factory DashboardWidgetDTO.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetDTO(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      connectionId: json['connectionId'] as String?,
      topicId: json['topicId'] as String?,
      position: json['position'] as int,
      width: json['width'] as int,
      height: json['height'] as int,
      configuration: Map<String, dynamic>.from(json['configuration'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'connectionId': connectionId,
      'topicId': topicId,
      'position': position,
      'width': width,
      'height': height,
      'configuration': configuration,
    };
  }
}

class DashboardDTO {
  final String id;
  final String name;
  final String? description;
  final String layout;
  final List<DashboardWidgetDTO> widgets;
  final bool isDefault;
  final bool isActive;
  final int refreshIntervalSeconds;
  final Map<String, dynamic> layoutSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardDTO({
    required this.id,
    required this.name,
    this.description,
    required this.layout,
    required this.widgets,
    required this.isDefault,
    required this.isActive,
    required this.refreshIntervalSeconds,
    required this.layoutSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardDTO.fromJson(Map<String, dynamic> json) {
    return DashboardDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      layout: json['layout'] as String,
      widgets: (json['widgets'] as List?)
              ?.map((e) => DashboardWidgetDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isDefault: json['isDefault'] as bool,
      isActive: json['isActive'] as bool,
      refreshIntervalSeconds: json['refreshIntervalSeconds'] as int,
      layoutSettings: Map<String, dynamic>.from(json['layoutSettings'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'layout': layout,
      'widgets': widgets.map((w) => w.toJson()).toList(),
      'isDefault': isDefault,
      'isActive': isActive,
      'refreshIntervalSeconds': refreshIntervalSeconds,
      'layoutSettings': layoutSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'DashboardDTO(id: $id, name: $name, widgets: ${widgets.length})';
}
