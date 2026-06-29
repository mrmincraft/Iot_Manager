import 'package:sqflite/sqflite.dart';
import '../../models/certificate_model.dart';

/// LocalDataSource pour les Certificats
class CertificateLocalDataSourceImpl implements CertificateLocalDataSource {
  final Database _database;
  
  CertificateLocalDataSourceImpl(this._database);
  
  @override
  Future<List<CertificateModel>> getAllCertificates() async {
    try {
      final maps = await _database.query('certificates');
      return maps.map((map) => CertificateModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching all certificates: $e');
    }
  }
  
  @override
  Future<CertificateModel> getCertificateById(String id) async {
    try {
      final maps = await _database.query(
        'certificates',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isEmpty) {
        throw Exception('Certificate with id $id not found');
      }
      
      return CertificateModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error fetching certificate by id: $e');
    }
  }
  
  @override
  Future<void> createCertificate(CertificateModel certificate) async {
    try {
      await _database.insert(
        'certificates',
        certificate.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception('Error creating certificate: $e');
    }
  }
  
  @override
  Future<void> updateCertificate(CertificateModel certificate) async {
    try {
      final rowsAffected = await _database.update(
        'certificates',
        certificate.toMap(),
        where: 'id = ?',
        whereArgs: [certificate.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Certificate with id ${certificate.id} not found');
      }
    } catch (e) {
      throw Exception('Error updating certificate: $e');
    }
  }
  
  @override
  Future<void> deleteCertificate(String id) async {
    try {
      final rowsAffected = await _database.delete(
        'certificates',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Certificate with id $id not found');
      }
    } catch (e) {
      throw Exception('Error deleting certificate: $e');
    }
  }
  
  @override
  Future<List<CertificateModel>> getCertificatesByType(String type) async {
    try {
      final maps = await _database.query(
        'certificates',
        where: 'type = ?',
        whereArgs: [type],
      );
      return maps.map((map) => CertificateModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching certificates by type: $e');
    }
  }
  
  @override
  Future<List<CertificateModel>> getValidCertificates() async {
    try {
      final maps = await _database.query(
        'certificates',
        where: 'isValid = ?',
        whereArgs: [1],
      );
      return maps.map((map) => CertificateModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error fetching valid certificates: $e');
    }
  }
}
