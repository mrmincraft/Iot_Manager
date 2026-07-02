import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';

void main() {
  group('Dashboard Entity Tests', () {
    group('Dashboard Creation', () {
      test('creates dashboard with all parameters', () {
        final now = DateTime.now();
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Main Dashboard',
          description: 'Main monitoring dashboard',
          layout: 'grid',
          widgets: ['widget-1', 'widget-2', 'widget-3'],
          refreshInterval: const Duration(seconds: 30),
          isActive: true,
          createdAt: now,
          updatedAt: now,
          metadata: {'theme': 'dark'},
        );

        expect(dashboard.id, 'dash-001');
        expect(dashboard.name, 'Main Dashboard');
        expect(dashboard.layout, 'grid');
        expect(dashboard.widgets.length, 3);
        expect(dashboard.refreshInterval, const Duration(seconds: 30));
      });

      test('validates dashboard ID is not empty', () {
        expect(
          () => Dashboard(
            id: '',
            name: 'Test',
            layout: 'grid',
            widgets: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates dashboard name is not empty', () {
        expect(
          () => Dashboard(
            id: 'dash-001',
            name: '',
            layout: 'grid',
            widgets: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Dashboard Layout', () {
      test('supports grid layout', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Grid Dashboard',
          layout: 'grid',
          widgets: ['w1', 'w2'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.layout, 'grid');
      });

      test('supports list layout', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'List Dashboard',
          layout: 'list',
          widgets: ['w1', 'w2'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.layout, 'list');
      });

      test('supports custom layout', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Custom Dashboard',
          layout: 'custom_layout_123',
          widgets: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.layout, 'custom_layout_123');
      });
    });

    group('Dashboard Widgets', () {
      test('dashboard can have multiple widgets', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Widget Dashboard',
          layout: 'grid',
          widgets: [
            'temp-widget',
            'humidity-widget',
            'pressure-widget',
            'motion-widget',
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.widgets.length, 4);
      });

      test('dashboard can have empty widgets list', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Empty Dashboard',
          layout: 'grid',
          widgets: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.widgets, isEmpty);
      });
    });

    group('Dashboard Refresh Interval', () {
      test('dashboard can have default refresh interval', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Dashboard',
          layout: 'grid',
          widgets: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.refreshInterval, isNull);
      });

      test('dashboard can have custom refresh interval', () {
        final dashboard = Dashboard(
          id: 'dash-001',
          name: 'Dashboard',
          layout: 'grid',
          widgets: [],
          refreshInterval: const Duration(seconds: 60),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dashboard.refreshInterval, const Duration(seconds: 60));
      });
    });

    group('Dashboard copyWith', () {
      test('creates copy with changed values', () {
        final now = DateTime.now();
        final original = Dashboard(
          id: 'dash-001',
          name: 'Original',
          layout: 'grid',
          widgets: ['w1'],
          createdAt: now,
          updatedAt: now,
        );

        final updated = original.copyWith(
          name: 'Updated',
          layout: 'list',
        );

        expect(updated.name, 'Updated');
        expect(updated.layout, 'list');
        expect(original.name, 'Original'); // Original unchanged
      });
    });
  });

  group('LogEntry Entity Tests', () {
    group('LogEntry Creation', () {
      test('creates log entry with all parameters', () {
        final now = DateTime.now();
        final logEntry = LogEntry(
          id: 'log-001',
          level: LogLevel.info,
          message: 'Connection established',
          source: 'mqtt-plugin',
          timestamp: now,
          details: {'connectionId': 'conn-001'},
        );

        expect(logEntry.id, 'log-001');
        expect(logEntry.level, LogLevel.info);
        expect(logEntry.message, 'Connection established');
        expect(logEntry.source, 'mqtt-plugin');
      });

      test('validates log ID is not empty', () {
        expect(
          () => LogEntry(
            id: '',
            level: LogLevel.info,
            message: 'Test',
            source: 'test',
            timestamp: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('validates message is not empty', () {
        expect(
          () => LogEntry(
            id: 'log-001',
            level: LogLevel.info,
            message: '',
            source: 'test',
            timestamp: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('LogLevel Enum', () {
      test('has debug level', () {
        expect(LogLevel.debug, LogLevel.debug);
      });

      test('has info level', () {
        expect(LogLevel.info, LogLevel.info);
      });

      test('has warning level', () {
        expect(LogLevel.warning, LogLevel.warning);
      });

      test('has error level', () {
        expect(LogLevel.error, LogLevel.error);
      });

      test('has critical level', () {
        expect(LogLevel.critical, LogLevel.critical);
      });

      test('all log levels are distinct', () {
        final levels = {
          LogLevel.debug,
          LogLevel.info,
          LogLevel.warning,
          LogLevel.error,
          LogLevel.critical,
        };
        expect(levels.length, 5);
      });
    });

    group('LogEntry Severity', () {
      test('debug level is least severe', () {
        final logs = [
          LogEntry(
            id: 'log-1',
            level: LogLevel.debug,
            message: 'Debug',
            source: 'test',
            timestamp: DateTime.now(),
          ),
          LogEntry(
            id: 'log-2',
            level: LogLevel.info,
            message: 'Info',
            source: 'test',
            timestamp: DateTime.now(),
          ),
        ];

        expect(logs[0].level, LogLevel.debug);
        expect(logs[1].level, LogLevel.info);
      });

      test('critical level is most severe', () {
        final log = LogEntry(
          id: 'log-001',
          level: LogLevel.critical,
          message: 'Critical error',
          source: 'system',
          timestamp: DateTime.now(),
        );

        expect(log.level, LogLevel.critical);
      });
    });

    group('LogEntry Filtering', () {
      test('can filter logs by severity', () {
        final logs = [
          LogEntry(
            id: 'log-1',
            level: LogLevel.debug,
            message: 'Debug',
            source: 'test',
            timestamp: DateTime.now(),
          ),
          LogEntry(
            id: 'log-2',
            level: LogLevel.error,
            message: 'Error',
            source: 'test',
            timestamp: DateTime.now(),
          ),
          LogEntry(
            id: 'log-3',
            level: LogLevel.warning,
            message: 'Warning',
            source: 'test',
            timestamp: DateTime.now(),
          ),
        ];

        final errors = logs.where((l) => l.level == LogLevel.error).toList();
        final warnings = logs.where((l) => l.level == LogLevel.warning).toList();

        expect(errors.length, 1);
        expect(warnings.length, 1);
      });

      test('can filter logs by source', () {
        final logs = [
          LogEntry(
            id: 'log-1',
            level: LogLevel.info,
            message: 'Message 1',
            source: 'mqtt',
            timestamp: DateTime.now(),
          ),
          LogEntry(
            id: 'log-2',
            level: LogLevel.info,
            message: 'Message 2',
            source: 'http',
            timestamp: DateTime.now(),
          ),
          LogEntry(
            id: 'log-3',
            level: LogLevel.info,
            message: 'Message 3',
            source: 'mqtt',
            timestamp: DateTime.now(),
          ),
        ];

        final mqttLogs = logs.where((l) => l.source == 'mqtt').toList();
        expect(mqttLogs.length, 2);
      });
    });

    group('LogEntry Details', () {
      test('log entry can store additional details', () {
        final log = LogEntry(
          id: 'log-001',
          level: LogLevel.error,
          message: 'Connection failed',
          source: 'mqtt',
          timestamp: DateTime.now(),
          details: {
            'connectionId': 'conn-001',
            'reason': 'Timeout',
            'retryCount': 3,
            'duration': 5000,
          },
        );

        expect(log.details!['connectionId'], 'conn-001');
        expect(log.details!['retryCount'], 3);
      });

      test('log entry details can be null', () {
        final log = LogEntry(
          id: 'log-001',
          level: LogLevel.info,
          message: 'General info',
          source: 'system',
          timestamp: DateTime.now(),
        );

        expect(log.details, isNull);
      });
    });

    group('LogEntry Timestamp', () {
      test('log entry records timestamp', () {
        final now = DateTime.now();
        final log = LogEntry(
          id: 'log-001',
          level: LogLevel.info,
          message: 'Test',
          source: 'test',
          timestamp: now,
        );

        expect(log.timestamp, now);
      });

      test('logs can be ordered by timestamp', () {
        final logs = [
          LogEntry(
            id: 'log-3',
            level: LogLevel.info,
            message: 'Third',
            source: 'test',
            timestamp: DateTime(2024, 1, 1, 12, 0, 3),
          ),
          LogEntry(
            id: 'log-1',
            level: LogLevel.info,
            message: 'First',
            source: 'test',
            timestamp: DateTime(2024, 1, 1, 12, 0, 1),
          ),
          LogEntry(
            id: 'log-2',
            level: LogLevel.info,
            message: 'Second',
            source: 'test',
            timestamp: DateTime(2024, 1, 1, 12, 0, 2),
          ),
        ];

        final sorted = logs..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        expect(sorted[0].id, 'log-1');
        expect(sorted[1].id, 'log-2');
        expect(sorted[2].id, 'log-3');
      });
    });
  });

  group('UserSettings Entity Tests', () {
    group('UserSettings Creation', () {
      test('creates user settings with all parameters', () {
        final now = DateTime.now();
        final settings = UserSettings(
          id: 'user-001',
          userId: 'user-123',
          theme: 'dark',
          language: 'en',
          notificationsEnabled: true,
          autoRefreshInterval: const Duration(minutes: 5),
          createdAt: now,
          updatedAt: now,
          preferences: {'timezone': 'UTC'},
        );

        expect(settings.id, 'user-001');
        expect(settings.userId, 'user-123');
        expect(settings.theme, 'dark');
        expect(settings.language, 'en');
        expect(settings.notificationsEnabled, true);
      });

      test('validates settings ID is not empty', () {
        expect(
          () => UserSettings(
            id: '',
            userId: 'user-001',
            theme: 'light',
            language: 'en',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('UserSettings Theme', () {
      test('supports light theme', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.theme, 'light');
      });

      test('supports dark theme', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'dark',
          language: 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.theme, 'dark');
      });

      test('supports auto theme', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'auto',
          language: 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.theme, 'auto');
      });
    });

    group('UserSettings Language', () {
      test('supports multiple languages', () {
        final languages = ['en', 'es', 'fr', 'de', 'ja'];

        for (final lang in languages) {
          final settings = UserSettings(
            id: 'settings-001',
            userId: 'user-001',
            theme: 'light',
            language: lang,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(settings.language, lang);
        }
      });
    });

    group('UserSettings Notifications', () {
      test('notifications can be enabled', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          notificationsEnabled: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.notificationsEnabled, true);
      });

      test('notifications can be disabled', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          notificationsEnabled: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.notificationsEnabled, false);
      });
    });

    group('UserSettings AutoRefresh', () {
      test('auto refresh can be null', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.autoRefreshInterval, isNull);
      });

      test('auto refresh can be set to duration', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          autoRefreshInterval: const Duration(seconds: 30),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.autoRefreshInterval, const Duration(seconds: 30));
      });
    });

    group('UserSettings Preferences', () {
      test('preferences is optional', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.preferences, {});
      });

      test('preferences can store custom settings', () {
        final settings = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          preferences: {
            'timezone': 'Europe/London',
            'dateFormat': 'dd/MM/yyyy',
            'timeFormat': '24h',
            'soundEnabled': true,
            'vibrationEnabled': false,
          },
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(settings.preferences['timezone'], 'Europe/London');
        expect(settings.preferences['timeFormat'], '24h');
      });
    });

    group('UserSettings copyWith', () {
      test('creates copy with changed values', () {
        final now = DateTime.now();
        final original = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          createdAt: now,
          updatedAt: now,
        );

        final updated = original.copyWith(
          theme: 'dark',
          language: 'es',
        );

        expect(updated.theme, 'dark');
        expect(updated.language, 'es');
        expect(original.theme, 'light'); // Original unchanged
      });
    });

    group('UserSettings Equality', () {
      test('settings with same values are equal', () {
        final now = DateTime(2024, 1, 1);

        final settings1 = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          createdAt: now,
          updatedAt: now,
        );

        final settings2 = UserSettings(
          id: 'settings-001',
          userId: 'user-001',
          theme: 'light',
          language: 'en',
          createdAt: now,
          updatedAt: now,
        );

        expect(settings1, settings2);
      });
    });
  });
}
