// Domain Repository Interface: DashboardRepository
// Interface pour la gestion des tableaux de bord

import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';

abstract class DashboardRepository {
  /// Récupère tous les tableaux de bord
  Future<Result<List<Dashboard>, Exception>> getAllDashboards();

  /// Récupère un tableau de bord par ID
  Future<Result<Dashboard, Exception>> getDashboardById(String id);

  /// Récupère le tableau de bord par défaut
  Future<Result<Dashboard, Exception>> getDefaultDashboard();

  /// Récupère le tableau de bord actif
  Future<Result<Dashboard, Exception>> getActiveDashboard();

  /// Crée un nouveau tableau de bord
  Future<Result<Dashboard, Exception>> createDashboard(Dashboard dashboard);

  /// Met à jour un tableau de bord
  Future<Result<Dashboard, Exception>> updateDashboard(Dashboard dashboard);

  /// Supprime un tableau de bord
  Future<Result<void, Exception>> deleteDashboard(String id);

  /// Ajoute un widget au tableau de bord
  Future<Result<Dashboard, Exception>> addWidget(String dashboardId, DashboardWidget widget);

  /// Supprime un widget du tableau de bord
  Future<Result<Dashboard, Exception>> removeWidget(String dashboardId, String widgetId);

  /// Définit un tableau de bord comme par défaut
  Future<Result<void, Exception>> setDefaultDashboard(String dashboardId);

  /// Définit un tableau de bord comme actif
  Future<Result<void, Exception>> setActiveDashboard(String dashboardId);
}
