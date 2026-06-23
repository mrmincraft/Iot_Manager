// Local DataSource Interface: DashboardLocalDataSource
// Interface pour les opérations de base de données sur les tableaux de bord

import 'package:iot_manager/data/models/dashboard_model.dart';

abstract class DashboardLocalDataSource {
  Future<List<DashboardModel>> getAllDashboards();
  Future<DashboardModel> getDashboardById(String id);
  Future<DashboardModel> getDefaultDashboard();
  Future<DashboardModel> getActiveDashboard();
  Future<void> createDashboard(DashboardModel dashboard);
  Future<void> updateDashboard(DashboardModel dashboard);
  Future<void> deleteDashboard(String id);
  Future<void> setDefaultDashboard(String dashboardId);
  Future<void> setActiveDashboard(String dashboardId);
}
