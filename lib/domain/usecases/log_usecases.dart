import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';
import 'package:iot_manager/domain/repositories/log_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL LOG ENTRIES
// ============================================================

/// Get All Log Entries Use Case
class GetAllLogEntriesUseCase extends UseCase<List<LogEntry>, NoParams> {
  final LogRepository _logRepository;

  GetAllLogEntriesUseCase(this._logRepository);

  @override
  Future<Result<List<LogEntry>>> call(NoParams params) async {
    return _logRepository.getAllLogEntries();
  }
}

// ============================================================
// GET LOG ENTRY BY ID
// ============================================================

class GetLogEntryByIdParams {
  final String id;
  GetLogEntryByIdParams({required this.id});
}

/// Get Log Entry By ID Use Case
class GetLogEntryByIdUseCase extends UseCase<LogEntry, GetLogEntryByIdParams> {
  final LogRepository _logRepository;

  GetLogEntryByIdUseCase(this._logRepository);

  @override
  Future<Result<LogEntry>> call(GetLogEntryByIdParams params) async {
    return _logRepository.getLogEntryById(params.id);
  }
}

// ============================================================
// CREATE LOG ENTRY
// ============================================================

class CreateLogEntryParams {
  final LogEntry logEntry;
  CreateLogEntryParams({required this.logEntry});
}

/// Create Log Entry Use Case
class CreateLogEntryUseCase extends UseCase<LogEntry, CreateLogEntryParams> {
  final LogRepository _logRepository;

  CreateLogEntryUseCase(this._logRepository);

  @override
  Future<Result<LogEntry>> call(CreateLogEntryParams params) async {
    return _logRepository.createLogEntry(params.logEntry);
  }
}

// ============================================================
// UPDATE LOG ENTRY
// ============================================================

class UpdateLogEntryParams {
  final LogEntry logEntry;
  UpdateLogEntryParams({required this.logEntry});
}

/// Update Log Entry Use Case
class UpdateLogEntryUseCase extends UseCase<LogEntry, UpdateLogEntryParams> {
  final LogRepository _logRepository;

  UpdateLogEntryUseCase(this._logRepository);

  @override
  Future<Result<LogEntry>> call(UpdateLogEntryParams params) async {
    return _logRepository.updateLogEntry(params.logEntry);
  }
}

// ============================================================
// DELETE LOG ENTRY
// ============================================================

class DeleteLogEntryParams {
  final String id;
  DeleteLogEntryParams({required this.id});
}

/// Delete Log Entry Use Case
class DeleteLogEntryUseCase extends UseCase<void, DeleteLogEntryParams> {
  final LogRepository _logRepository;

  DeleteLogEntryUseCase(this._logRepository);

  @override
  Future<Result<void>> call(DeleteLogEntryParams params) async {
    return _logRepository.deleteLogEntry(params.id);
  }
}
