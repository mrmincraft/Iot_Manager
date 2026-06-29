import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/domain/repositories/dashboard_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL DASHBOARDS
// ============================================================

/// Get All Dashboards Use Case
class GetAllDashboardsUseCase extends UseCase<List<Dashboard>, NoParams> {
  final DashboardRepository _dashboardRepository;

  GetAllDashboardsUseCase(this._dashboardRepository);

  @override
  Future<Result<List<Dashboard>>> call(NoParams params) async {
    return _dashboardRepository.getAllDashboards();
  }
}

// ============================================================
// GET DASHBOARD BY ID
// ============================================================

class GetDashboardByIdParams {
  final String id;
  GetDashboardByIdParams({required this.id});
}

/// Get Dashboard By ID Use Case
class GetDashboardByIdUseCase extends UseCase<Dashboard, GetDashboardByIdParams> {
  final DashboardRepository _dashboardRepository;

  GetDashboardByIdUseCase(this._dashboardRepository);

  @override
  Future<Result<Dashboard>> call(GetDashboardByIdParams params) async {
    return _dashboardRepository.getDashboardById(params.id);
  }
}

// ============================================================
// CREATE DASHBOARD
// ============================================================

class CreateDashboardParams {
  final Dashboard dashboard;
  CreateDashboardParams({required this.dashboard});
}

/// Create Dashboard Use Case
class CreateDashboardUseCase extends UseCase<Dashboard, CreateDashboardParams> {
  final DashboardRepository _dashboardRepository;

  CreateDashboardUseCase(this._dashboardRepository);

  @override
  Future<Result<Dashboard>> call(CreateDashboardParams params) async {
    return _dashboardRepository.createDashboard(params.dashboard);
  }
}

// ============================================================
// UPDATE DASHBOARD
// ============================================================

class UpdateDashboardParams {
  final Dashboard dashboard;
  UpdateDashboardParams({required this.dashboard});
}

/// Update Dashboard Use Case
class UpdateDashboardUseCase extends UseCase<Dashboard, UpdateDashboardParams> {
  final DashboardRepository _dashboardRepository;

  UpdateDashboardUseCase(this._dashboardRepository);

  @override
  Future<Result<Dashboard>> call(UpdateDashboardParams params) async {
    return _dashboardRepository.updateDashboard(params.dashboard);
  }
}

// ============================================================
// DELETE DASHBOARD
// ============================================================

class DeleteDashboardParams {
  final String id;
  DeleteDashboardParams({required this.id});
}

/// Delete Dashboard Use Case
class DeleteDashboardUseCase extends UseCase<void, DeleteDashboardParams> {
  final DashboardRepository _dashboardRepository;

  DeleteDashboardUseCase(this._dashboardRepository);

  @override
  Future<Result<void>> call(DeleteDashboardParams params) async {
    return _dashboardRepository.deleteDashboard(params.id);
  }
}
