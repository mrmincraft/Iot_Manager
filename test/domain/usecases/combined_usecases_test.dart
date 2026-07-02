import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/topic.dart';
import 'package:iot_manager/domain/entities/message.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';
import 'package:iot_manager/domain/repositories/topic_repository.dart';
import 'package:iot_manager/domain/repositories/message_repository.dart';
import 'package:iot_manager/domain/repositories/dashboard_repository.dart';
import 'package:iot_manager/domain/repositories/log_repository.dart';
import 'package:iot_manager/domain/repositories/user_settings_repository.dart';
import 'package:iot_manager/domain/usecases/topic_usecases.dart';
import 'package:iot_manager/domain/usecases/message_usecases.dart';
import 'package:iot_manager/domain/usecases/dashboard_usecases.dart';
import 'package:iot_manager/domain/usecases/log_usecases.dart';
import 'package:iot_manager/domain/usecases/user_settings_usecases.dart';

// Mock Repositories
class MockTopicRepository extends Mock implements TopicRepository {}
class MockMessageRepository extends Mock implements MessageRepository {}
class MockDashboardRepository extends Mock implements DashboardRepository {}
class MockLogRepository extends Mock implements LogRepository {}
class MockUserSettingsRepository extends Mock implements UserSettingsRepository {}

void main() {
  group('Topic UseCases Tests', () {
    late MockTopicRepository mockRepository;

    setUp(() {
      mockRepository = MockTopicRepository();
    });

    test('GetAllTopicsUseCase returns topics', () async {
      final topics = [
        Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'sensors/temp',
          qos: MessageQoS.atLeastOnce,
        ),
        Topic(
          id: 'topic-002',
          connectionId: 'conn-001',
          name: 'sensors/humidity',
          qos: MessageQoS.atLeastOnce,
        ),
      ];

      when(mockRepository.getAllTopics())
          .thenAnswer((_) async => Result.success(topics));

      final useCase = GetAllTopicsUseCase(mockRepository);
      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.value!.length, 2);
    });

    test('GetSubscribedTopicsUseCase returns subscribed topics', () async {
      final topics = [
        Topic(
          id: 'topic-001',
          connectionId: 'conn-001',
          name: 'subscribed/topic',
          qos: MessageQoS.atLeastOnce,
          isSubscribed: true,
        ),
      ];

      when(mockRepository.getSubscribedTopics())
          .thenAnswer((_) async => Result.success(topics));

      final useCase = GetSubscribedTopicsUseCase(mockRepository);
      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.value!.length, 1);
    });

    test('CreateTopicUseCase creates topic', () async {
      final topic = Topic(
        id: 'topic-001',
        connectionId: 'conn-001',
        name: 'new/topic',
        qos: MessageQoS.atMostOnce,
      );

      when(mockRepository.createTopic(topic))
          .thenAnswer((_) async => Result.success(topic));

      final useCase = CreateTopicUseCase(mockRepository);
      final result = await useCase.call(topic);

      expect(result.isSuccess, true);
      verify(mockRepository.createTopic(topic)).called(1);
    });

    test('DeleteTopicUseCase deletes topic', () async {
      when(mockRepository.deleteTopic('topic-001'))
          .thenAnswer((_) async => Result.success(null));

      final useCase = DeleteTopicUseCase(mockRepository);
      final result = await useCase.call('topic-001');

      expect(result.isSuccess, true);
    });
  });

  group('Message UseCases Tests', () {
    late MockMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockMessageRepository();
    });

    test('GetAllMessagesUseCase returns messages', () async {
      final now = DateTime.now();
      final messages = [
        Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Message 1',
          timestamp: now,
          receivedAt: now,
        ),
      ];

      when(mockRepository.getAllMessages())
          .thenAnswer((_) async => Result.success(messages));

      final useCase = GetAllMessagesUseCase(mockRepository);
      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.value!.length, 1);
    });

    test('CreateMessageUseCase creates message', () async {
      final now = DateTime.now();
      final message = Message(
        id: 'msg-001',
        topicId: 'topic-001',
        connectionId: 'conn-001',
        direction: MessageDirection.outgoing,
        type: MessageType.text,
        payload: 'Test message',
        timestamp: now,
        receivedAt: now,
      );

      when(mockRepository.createMessage(message))
          .thenAnswer((_) async => Result.success(message));

      final useCase = CreateMessageUseCase(mockRepository);
      final result = await useCase.call(message);

      expect(result.isSuccess, true);
      expect(result.value!.payload, 'Test message');
    });

    test('DeleteOldMessagesUseCase deletes old messages', () async {
      when(mockRepository.deleteOldMessages(30))
          .thenAnswer((_) async => Result.success(null));

      final useCase = DeleteOldMessagesUseCase(mockRepository);
      final result = await useCase.call(30);

      expect(result.isSuccess, true);
    });

    test('GetMessagesByConnectionUseCase returns connection messages', () async {
      final now = DateTime.now();
      final messages = [
        Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Message',
          timestamp: now,
          receivedAt: now,
        ),
      ];

      when(mockRepository.getMessagesByConnection('conn-001'))
          .thenAnswer((_) async => Result.success(messages));

      final useCase = GetMessagesByConnectionUseCase(mockRepository);
      final result = await useCase.call('conn-001');

      expect(result.isSuccess, true);
    });

    test('GetMessagesByTopicUseCase returns topic messages', () async {
      final now = DateTime.now();
      final messages = [
        Message(
          id: 'msg-001',
          topicId: 'topic-001',
          connectionId: 'conn-001',
          direction: MessageDirection.incoming,
          type: MessageType.text,
          payload: 'Message',
          timestamp: now,
          receivedAt: now,
        ),
      ];

      when(mockRepository.getMessagesByTopic('topic-001'))
          .thenAnswer((_) async => Result.success(messages));

      final useCase = GetMessagesByTopicUseCase(mockRepository);
      final result = await useCase.call('topic-001');

      expect(result.isSuccess, true);
    });
  });

  group('Dashboard UseCases Tests', () {
    late MockDashboardRepository mockRepository;

    setUp(() {
      mockRepository = MockDashboardRepository();
    });

    test('GetAllDashboardsUseCase returns dashboards', () async {
      final now = DateTime.now();
      final dashboards = [
        Dashboard(
          id: 'dash-001',
          name: 'Dashboard 1',
          layout: 'grid',
          widgets: ['w1', 'w2'],
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(mockRepository.getAllDashboards())
          .thenAnswer((_) async => Result.success(dashboards));

      final useCase = GetAllDashboardsUseCase(mockRepository);
      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.value!.length, 1);
    });

    test('CreateDashboardUseCase creates dashboard', () async {
      final now = DateTime.now();
      final dashboard = Dashboard(
        id: 'dash-001',
        name: 'New Dashboard',
        layout: 'grid',
        widgets: [],
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.createDashboard(dashboard))
          .thenAnswer((_) async => Result.success(dashboard));

      final useCase = CreateDashboardUseCase(mockRepository);
      final result = await useCase.call(dashboard);

      expect(result.isSuccess, true);
      verify(mockRepository.createDashboard(dashboard)).called(1);
    });

    test('UpdateDashboardUseCase updates dashboard', () async {
      final now = DateTime.now();
      final updated = Dashboard(
        id: 'dash-001',
        name: 'Updated Dashboard',
        layout: 'list',
        widgets: ['w1'],
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.updateDashboard(updated))
          .thenAnswer((_) async => Result.success(updated));

      final useCase = UpdateDashboardUseCase(mockRepository);
      final result = await useCase.call(updated);

      expect(result.isSuccess, true);
      expect(result.value!.name, 'Updated Dashboard');
    });

    test('DeleteDashboardUseCase deletes dashboard', () async {
      when(mockRepository.deleteDashboard('dash-001'))
          .thenAnswer((_) async => Result.success(null));

      final useCase = DeleteDashboardUseCase(mockRepository);
      final result = await useCase.call('dash-001');

      expect(result.isSuccess, true);
    });

    test('GetDashboardByIdUseCase returns dashboard', () async {
      final now = DateTime.now();
      final dashboard = Dashboard(
        id: 'dash-001',
        name: 'Dashboard',
        layout: 'grid',
        widgets: [],
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.getDashboardById('dash-001'))
          .thenAnswer((_) async => Result.success(dashboard));

      final useCase = GetDashboardByIdUseCase(mockRepository);
      final result = await useCase.call('dash-001');

      expect(result.isSuccess, true);
    });
  });

  group('LogEntry UseCases Tests', () {
    late MockLogRepository mockRepository;

    setUp(() {
      mockRepository = MockLogRepository();
    });

    test('GetAllLogsUseCase returns logs', () async {
      final logs = [
        LogEntry(
          id: 'log-001',
          level: LogLevel.info,
          message: 'Test log',
          source: 'test',
          timestamp: DateTime.now(),
        ),
      ];

      when(mockRepository.getAllLogs())
          .thenAnswer((_) async => Result.success(logs));

      final useCase = GetAllLogsUseCase(mockRepository);
      final result = await useCase.call();

      expect(result.isSuccess, true);
      expect(result.value!.length, 1);
    });

    test('CreateLogUseCase creates log entry', () async {
      final log = LogEntry(
        id: 'log-001',
        level: LogLevel.error,
        message: 'Error occurred',
        source: 'system',
        timestamp: DateTime.now(),
      );

      when(mockRepository.createLog(log))
          .thenAnswer((_) async => Result.success(log));

      final useCase = CreateLogUseCase(mockRepository);
      final result = await useCase.call(log);

      expect(result.isSuccess, true);
      expect(result.value!.level, LogLevel.error);
    });

    test('GetLogsByLevelUseCase filters by level', () async {
      final logs = [
        LogEntry(
          id: 'log-001',
          level: LogLevel.error,
          message: 'Error 1',
          source: 'test',
          timestamp: DateTime.now(),
        ),
      ];

      when(mockRepository.getLogsByLevel(LogLevel.error))
          .thenAnswer((_) async => Result.success(logs));

      final useCase = GetLogsByLevelUseCase(mockRepository);
      final result = await useCase.call(LogLevel.error);

      expect(result.isSuccess, true);
      expect(result.value!.length, 1);
    });

    test('ClearOldLogsUseCase clears old logs', () async {
      when(mockRepository.clearOldLogs(7))
          .thenAnswer((_) async => Result.success(null));

      final useCase = ClearOldLogsUseCase(mockRepository);
      final result = await useCase.call(7);

      expect(result.isSuccess, true);
    });

    test('GetLogsBySourceUseCase filters by source', () async {
      final logs = [
        LogEntry(
          id: 'log-001',
          level: LogLevel.info,
          message: 'MQTT log',
          source: 'mqtt',
          timestamp: DateTime.now(),
        ),
      ];

      when(mockRepository.getLogsBySource('mqtt'))
          .thenAnswer((_) async => Result.success(logs));

      final useCase = GetLogsBySourceUseCase(mockRepository);
      final result = await useCase.call('mqtt');

      expect(result.isSuccess, true);
    });
  });

  group('UserSettings UseCases Tests', () {
    late MockUserSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockUserSettingsRepository();
    });

    test('GetUserSettingsUseCase returns settings', () async {
      final now = DateTime.now();
      final settings = UserSettings(
        id: 'settings-001',
        userId: 'user-001',
        theme: 'dark',
        language: 'en',
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.getUserSettings('user-001'))
          .thenAnswer((_) async => Result.success(settings));

      final useCase = GetUserSettingsUseCase(mockRepository);
      final result = await useCase.call('user-001');

      expect(result.isSuccess, true);
      expect(result.value!.theme, 'dark');
    });

    test('UpdateUserSettingsUseCase updates settings', () async {
      final now = DateTime.now();
      final updated = UserSettings(
        id: 'settings-001',
        userId: 'user-001',
        theme: 'light',
        language: 'es',
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.updateUserSettings(updated))
          .thenAnswer((_) async => Result.success(updated));

      final useCase = UpdateUserSettingsUseCase(mockRepository);
      final result = await useCase.call(updated);

      expect(result.isSuccess, true);
      expect(result.value!.theme, 'light');
      expect(result.value!.language, 'es');
    });

    test('ResetUserSettingsUseCase resets to defaults', () async {
      final now = DateTime.now();
      final reset = UserSettings(
        id: 'settings-001',
        userId: 'user-001',
        theme: 'light',
        language: 'en',
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.resetUserSettings('user-001'))
          .thenAnswer((_) async => Result.success(reset));

      final useCase = ResetUserSettingsUseCase(mockRepository);
      final result = await useCase.call('user-001');

      expect(result.isSuccess, true);
      expect(result.value!.theme, 'light');
    });
  });
}
