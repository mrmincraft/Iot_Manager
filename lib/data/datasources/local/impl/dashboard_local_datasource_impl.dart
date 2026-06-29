import 'package:sqflite/sqflite.dart';
import '../../models/dashboard_model.dart';

/// LocalDataSource pour les Dashboards
class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final Database _database;
  
  DashboardLocalDataSourceImpl(this._database);
  
  @override
  Future<List<DashboardModel>> getAllDashboards() async {
    try {
      final maps = await _database.query('dashboards');
      return maps.map((map) => DashboardModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all dashboards: $e');
    }
  }
  
  @override
  Future<DashboardModel> getDashboardById(String id) async {
    try {
      final maps = await _database.query(
        'dashboards',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Dashboard with id $id not found');
      }
      
      return DashboardModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching dashboard by id: $e');
    }
  }
  
  @override
  Future<void> createDashboard(DashboardModel dashboard) async {
    try {
      await _database.insert(
        'dashboards',
        dashboard.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating dashboard: $e');
    }
  }
  
  @override
  Future<void> updateDashboard(DashboardModel dashboard) async {
    try {
      final rowsAffected = await _database.update(
        'dashboards',
        dashboard.toMap(),
        where: 'id = ?',
        whereArgs: [dashboard.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Dashboard with id ${dashboard.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating dashboard: $e');
    }
  }
  
  @override
  Future<void> deleteDashboard(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'dashboards',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Dashboard with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting dashboard: $e');
    }
  }
  
  @override
  Future<DashboardModel?> getDefaultDashboard() async {
    try {
      final maps = await _database.query(
        'dashboards',
        where: 'isDefault = ?',
        whereArgs: [1],
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      return DashboardModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching default dashboard: $e');
    }
  }
  
  @override
  Future<List<DashboardModel>> getActiveDashboards() async {
    try {
      final maps = await _database.query(
        'dashboards',
        where: 'isActive = ?',
        whereArgs: [1],
      );
      return maps.map((map) => DashboardModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching active dashboards: $e');
    }
  }
}
