// Repository Implementation: DashboardRepositoryImpl
// Implémentation de la gestion des tableaux de bord

import 'dart:convert';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/datasources/local/dashboard_local_datasource.dart';
import 'package:iot_manager/data/models/dashboard_model.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/domain/events/dashboard_events.dart';
import 'package:iot_manager/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource _localDataSource;
  final EventBus _eventBus;

  DashboardRepositoryImpl(this._localDataSource, this._eventBus);

  @override
  Future<Result<List<Dashboard>, Exception>> getAllDashboards() async {
    try {
      final models = await _localDataSource.getAllDashboards();
      final dashboards = models.map(_mapModelToEntity).toList();
      await _eventBus.publish(DashboardsLoadedEvent(dashboards));
      return Result.success(dashboards);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> getDashboardById(String id) async {
    try {
      final model = await _localDataSource.getDashboardById(id);
      final dashboard = _mapModelToEntity(model);
      await _eventBus.publish(DashboardRetrievedEvent(dashboard));
      return Result.success(dashboard);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> getDefaultDashboard() async {
    try {
      final model = await _localDataSource.getDefaultDashboard();
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> getActiveDashboard() async {
    try {
      final model = await _localDataSource.getActiveDashboard();
      return Result.success(_mapModelToEntity(model));
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> createDashboard(Dashboard dashboard) async {
    try {
      final model = _mapEntityToModel(dashboard);
      await _localDataSource.createDashboard(model);
      await _eventBus.publish(DashboardCreatedEvent(dashboard));
      return Result.success(dashboard);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> updateDashboard(Dashboard dashboard) async {
    try {
      // Get previous state
      final previousModel = await _localDataSource.getDashboardById(dashboard.id);
      final previousDashboard = _mapModelToEntity(previousModel);

      final model = _mapEntityToModel(dashboard);
      await _localDataSource.updateDashboard(model);
      
      await _eventBus.publish(DashboardUpdatedEvent(
        dashboard: dashboard,
        previousDashboard: previousDashboard,
      ));
      return Result.success(dashboard);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> deleteDashboard(String id) async {
    try {
      // Get the dashboard before deletion
      final model = await _localDataSource.getDashboardById(id);
      final deletedDashboard = _mapModelToEntity(model);

      await _localDataSource.deleteDashboard(id);
      await _eventBus.publish(DashboardDeletedEvent(
        dashboardId: id,
        deletedDashboard: deletedDashboard,
      ));
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> addWidget(String dashboardId, DashboardWidget widget) async {
    try {
      final dashboard = await getDashboardById(dashboardId);
      if (dashboard.isFailure) {
        return Result.failure(dashboard.error!);
      }
      final updated = dashboard.value!.addWidget(widget);
      await updateDashboard(updated);
      return Result.success(updated);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<Dashboard, Exception>> removeWidget(String dashboardId, String widgetId) async {
    try {
      final dashboard = await getDashboardById(dashboardId);
      if (dashboard.isFailure) {
        return Result.failure(dashboard.error!);
      }
      final updated = dashboard.value!.removeWidget(widgetId);
      await updateDashboard(updated);
      return Result.success(updated);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> setDefaultDashboard(String dashboardId) async {
    try {
      await _localDataSource.setDefaultDashboard(dashboardId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  @override
  Future<Result<void, Exception>> setActiveDashboard(String dashboardId) async {
    try {
      await _localDataSource.setActiveDashboard(dashboardId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e as Exception);
    }
  }

  Dashboard _mapModelToEntity(DashboardModel model) {
    return Dashboard(
      id: model.id,
      name: model.name,
      description: model.description,
      layout: DashboardLayout.values.firstWhere(
        (e) => e.toString().split('.').last == model.layout,
        orElse: () => DashboardLayout.grid,
      ),
      widgets: model.widgets.map((w) {
        return DashboardWidget(
          id: w.id,
          type: WidgetType.values.firstWhere(
            (e) => e.toString().split('.').last == w.type,
            orElse: () => WidgetType.custom,
          ),
          title: w.title,
          connectionId: w.connectionId,
          topicId: w.topicId,
          position: w.position,
          width: w.width,
          height: w.height,
          configuration: Map<String, dynamic>.from(jsonDecode(w.configuration) as Map),
        );
      }).toList(),
      isDefault: model.isDefault,
      isActive: model.isActive,
      refreshIntervalSeconds: model.refreshIntervalSeconds,
      layoutSettings: Map<String, dynamic>.from(jsonDecode(model.layoutSettings) as Map),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  DashboardModel _mapEntityToModel(Dashboard entity) {
    return DashboardModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      layout: entity.layout.toString().split('.').last,
      widgets: entity.widgets.map((w) {
        return DashboardWidgetModel(
          id: w.id,
          dashboardId: entity.id,
          type: w.type.toString().split('.').last,
          title: w.title,
          connectionId: w.connectionId,
          topicId: w.topicId,
          position: w.position,
          width: w.width,
          height: w.height,
          configuration: jsonEncode(w.configuration),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList(),
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      refreshIntervalSeconds: entity.refreshIntervalSeconds,
      layoutSettings: jsonEncode(entity.layoutSettings),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
