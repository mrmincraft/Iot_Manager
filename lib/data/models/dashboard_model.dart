// SQLite Model: DashboardModel
// Modèle de données pour la table dashboards et dashboard_widgets en SQLite

class DashboardWidgetModel {
  final String id;
  final String dashboardId;
  final String type;
  final String title;
  final String? connectionId;
  final String? topicId;
  final int position;
  final int width;
  final int height;
  final String configuration; // JSON string
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardWidgetModel({
    required this.id,
    required this.dashboardId,
    required this.type,
    required this.title,
    this.connectionId,
    this.topicId,
    required this.position,
    required this.width,
    required this.height,
    required this.configuration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardWidgetModel.fromMap(Map<String, dynamic> map) {
    return DashboardWidgetModel(
      id: map['id'] as String,
      dashboardId: map['dashboardId'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      connectionId: map['connectionId'] as String?,
      topicId: map['topicId'] as String?,
      position: map['position'] as int,
      width: map['width'] as int,
      height: map['height'] as int,
      configuration: map['configuration'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dashboardId': dashboardId,
      'type': type,
      'title': title,
      'connectionId': connectionId,
      'topicId': topicId,
      'position': position,
      'width': width,
      'height': height,
      'configuration': configuration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class DashboardModel {
  final String id;
  final String name;
  final String? description;
  final String layout;
  final List<DashboardWidgetModel> widgets;
  final bool isDefault;
  final bool isActive;
  final int refreshIntervalSeconds;
  final String layoutSettings; // JSON string
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardModel({
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

  factory DashboardModel.fromMap(Map<String, dynamic> map) {
    return DashboardModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      layout: map['layout'] as String,
      widgets: [], // Chargé séparément depuis la BD
      isDefault: (map['isDefault'] as int) == 1,
      isActive: (map['isActive'] as int) == 1,
      refreshIntervalSeconds: map['refreshIntervalSeconds'] as int,
      layoutSettings: map['layoutSettings'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'layout': layout,
      'isDefault': isDefault ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'refreshIntervalSeconds': refreshIntervalSeconds,
      'layoutSettings': layoutSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'DashboardModel(id: $id, name: $name, widgets: ${widgets.length})';
}
