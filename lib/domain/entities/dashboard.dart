// Domain Entity: Dashboard
// Représente un tableau de bord personnalisé de monitoring

enum WidgetType { chart, gauge, table, log, status, custom }
enum DashboardLayout { grid, list, custom }

class DashboardWidget {
  final String id;
  final WidgetType type;
  final String title;
  final String? connectionId;
  final String? topicId;
  final int position;
  final int width;
  final int height;
  final Map<String, dynamic> configuration;

  DashboardWidget({
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

  DashboardWidget copyWith({
    String? id,
    WidgetType? type,
    String? title,
    String? connectionId,
    String? topicId,
    int? position,
    int? width,
    int? height,
    Map<String, dynamic>? configuration,
  }) {
    return DashboardWidget(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      connectionId: connectionId ?? this.connectionId,
      topicId: topicId ?? this.topicId,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      configuration: configuration ?? this.configuration,
    );
  }
}

class Dashboard {
  final String id;
  final String name;
  final String? description;
  final DashboardLayout layout;
  final List<DashboardWidget> widgets;
  final bool isDefault;
  final bool isActive;
  final int refreshIntervalSeconds;
  final Map<String, dynamic> layoutSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Dashboard({
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

  /// Crée une copie avec propriétés modifiées
  Dashboard copyWith({
    String? id,
    String? name,
    String? description,
    DashboardLayout? layout,
    List<DashboardWidget>? widgets,
    bool? isDefault,
    bool? isActive,
    int? refreshIntervalSeconds,
    Map<String, dynamic>? layoutSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Dashboard(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      layout: layout ?? this.layout,
      widgets: widgets ?? this.widgets,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      refreshIntervalSeconds: refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      layoutSettings: layoutSettings ?? this.layoutSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ajoute un widget au tableau de bord
  Dashboard addWidget(DashboardWidget widget) {
    return copyWith(widgets: [...widgets, widget]);
  }

  /// Supprime un widget du tableau de bord
  Dashboard removeWidget(String widgetId) {
    return copyWith(
      widgets: widgets.where((w) => w.id != widgetId).toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dashboard &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Dashboard(id: $id, name: $name, widgets: ${widgets.length})';
}
