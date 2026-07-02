import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/events/domain_events.dart';

/// Sync status for an entity type
enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  partialSuccess,
}

/// Sync conflict resolution strategy
enum ConflictResolution {
  preferLocal,
  preferRemote,
  newest,
  merge,
}

/// Data synchronization manager for local-remote sync
/// 
/// Responsibilities:
/// - Sync local data with remote backend
/// - Manage sync state for each entity type
/// - Handle conflicts between local and remote
/// - Implement retry logic
/// - Publish sync events
abstract class SyncManager {
  /// Sync all data with backend
  Future<Result<void, NetworkException>> syncAll();

  /// Sync specific entity type
  Future<Result<void, NetworkException>> syncEntity(String entityType);

  /// Get sync status for entity type
  SyncStatus getSyncStatus(String entityType);

  /// Get last sync time for entity type
  DateTime? getLastSyncTime(String entityType);

  /// Enable/disable auto sync
  void setAutoSyncEnabled(bool enabled);

  /// Get auto sync interval
  Duration get autoSyncInterval;

  /// Set auto sync interval
  void setAutoSyncInterval(Duration interval);

  /// Cancel ongoing sync
  void cancelSync();

  /// Force full resync (not incremental)
  Future<Result<void, NetworkException>> forceFullSync();
}

/// Sync Manager Implementation
class SyncManagerImpl implements SyncManager {
  final EventBus _eventBus;
  final ConflictResolution _conflictStrategy;

  final Map<String, SyncStatus> _syncStatus = {};
  final Map<String, DateTime> _lastSyncTime = {};
  
  bool _autoSyncEnabled = true;
  Duration _autoSyncInterval = const Duration(minutes: 5);
  bool _syncInProgress = false;

  SyncManagerImpl({
    required EventBus eventBus,
    ConflictResolution conflictStrategy = ConflictResolution.preferRemote,
  })  : _eventBus = eventBus,
        _conflictStrategy = conflictStrategy {
    _initializeSyncStatuses();
  }

  void _initializeSyncStatuses() {
    const entities = [
      'protocol',
      'certificate',
      'connection',
      'topic',
      'message',
      'user_settings',
      'dashboard',
      'log',
    ];

    for (final entity in entities) {
      _syncStatus[entity] = SyncStatus.idle;
    }
  }

  @override
  Future<Result<void, NetworkException>> syncAll() async {
    if (_syncInProgress) {
      return Result.failure(
        NetworkException(
          message: 'Sync already in progress',
          code: 'SYNC_IN_PROGRESS',
        ),
      );
    }

    _syncInProgress = true;
    final errors = <String, NetworkException>[];

    try {
      final entities = _syncStatus.keys.toList();

      for (final entity in entities) {
        _updateSyncStatus(entity, SyncStatus.syncing);

        final result = await syncEntity(entity);

        if (result.isFailure) {
          errors.add(result.error!);
          _updateSyncStatus(entity, SyncStatus.failed);
        } else {
          _updateSyncStatus(entity, SyncStatus.success);
          _lastSyncTime[entity] = DateTime.now();
        }
      }

      if (errors.isEmpty) {
        _publishSyncEvent('SyncCompleted', 'All data synced successfully');
        return Result.success(null);
      } else {
        _updateSyncStatus('all', SyncStatus.partialSuccess);
        _publishSyncEvent('SyncPartiallyFailed', '${errors.length} entities failed to sync');
        return Result.success(null); // Partial success
      }
    } on NetworkException catch (e) {
      _updateSyncStatus('all', SyncStatus.failed);
      _publishSyncEvent('SyncFailed', 'Sync failed: ${e.message}');
      return Result.failure(e);
    } finally {
      _syncInProgress = false;
    }
  }

  @override
  Future<Result<void, NetworkException>> syncEntity(String entityType) async {
    try {
      // Placeholder: In real implementation, would:
      // 1. Get local data
      // 2. Get remote data
      // 3. Compare timestamps/versions
      // 4. Handle conflicts based on strategy
      // 5. Merge data
      // 6. Update local database
      // 7. Update remote if needed

      _updateSyncStatus(entityType, SyncStatus.syncing);

      // Simulate sync operation
      await Future.delayed(const Duration(milliseconds: 500));

      _updateSyncStatus(entityType, SyncStatus.success);
      _lastSyncTime[entityType] = DateTime.now();

      _publishSyncEvent('EntitySynced', '$entityType synced successfully');
      return Result.success(null);
    } catch (e) {
      _updateSyncStatus(entityType, SyncStatus.failed);
      return Result.failure(
        NetworkException(
          message: 'Failed to sync $entityType: $e',
          code: 'SYNC_FAILED',
          originalError: e,
        ),
      );
    }
  }

  @override
  SyncStatus getSyncStatus(String entityType) {
    return _syncStatus[entityType] ?? SyncStatus.idle;
  }

  @override
  DateTime? getLastSyncTime(String entityType) {
    return _lastSyncTime[entityType];
  }

  @override
  void setAutoSyncEnabled(bool enabled) {
    _autoSyncEnabled = enabled;

    if (enabled) {
      _publishSyncEvent('AutoSyncEnabled', 'Auto sync enabled');
    } else {
      _publishSyncEvent('AutoSyncDisabled', 'Auto sync disabled');
    }
  }

  @override
  Duration get autoSyncInterval => _autoSyncInterval;

  @override
  void setAutoSyncInterval(Duration interval) {
    if (interval.inSeconds < 30) {
      throw ArgumentError('Sync interval must be at least 30 seconds');
    }
    _autoSyncInterval = interval;
    _publishSyncEvent('SyncIntervalChanged', 'Sync interval set to ${interval.inSeconds}s');
  }

  @override
  void cancelSync() {
    _syncInProgress = false;
    _publishSyncEvent('SyncCancelled', 'Sync operation cancelled');
  }

  @override
  Future<Result<void, NetworkException>> forceFullSync() async {
    // Reset all sync statuses
    for (final key in _syncStatus.keys) {
      _syncStatus[key] = SyncStatus.idle;
    }
    _lastSyncTime.clear();

    _publishSyncEvent('FullSyncInitiated', 'Full resync initiated');

    return syncAll();
  }

  void _updateSyncStatus(String entityType, SyncStatus status) {
    _syncStatus[entityType] = status;
  }

  void _publishSyncEvent(String eventType, String message) {
    // Would publish to EventBus in real implementation
    // For now, just log
    print('[SyncManager] $eventType: $message');
  }

  bool get isSyncing => _syncInProgress;

  bool get isAutoSyncEnabled => _autoSyncEnabled;
}
