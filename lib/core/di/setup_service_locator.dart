/// Dependency Injection Setup
/// 
/// Configures all services, repositories, usecases, and viewmodels
/// for the IoT Manager application.
/// 
/// Registration Order:
/// 1. Core Layer: Database, EventBus, Services
/// 2. Data Layer: LocalDataSources, Repositories
/// 3. Domain Layer: UseCases
/// 4. Presentation Layer: ViewModels

import 'package:get_it/get_it.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/database_service.dart';
import 'package:iot_manager/data/datasources/local/certificate_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/command_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/connection_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/dashboard_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/device_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/log_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/message_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/protocol_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/topic_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/user_settings_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/impl/certificate_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/connection_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/dashboard_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/log_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/message_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/protocol_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/topic_local_datasource_impl.dart';
import 'package:iot_manager/data/datasources/local/impl/user_settings_local_datasource_impl.dart';
import 'package:iot_manager/data/repositories/impl/certificate_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/dashboard_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/log_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/message_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/protocol_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/topic_repository_impl.dart';
import 'package:iot_manager/data/repositories/impl/user_settings_repository_impl.dart';
import 'package:iot_manager/domain/repositories/certificate_repository.dart';
import 'package:iot_manager/domain/repositories/command_repository.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/repositories/dashboard_repository.dart';
import 'package:iot_manager/domain/repositories/device_repository.dart';
import 'package:iot_manager/domain/repositories/log_repository.dart';
import 'package:iot_manager/domain/repositories/message_repository.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/repositories/topic_repository.dart';
import 'package:iot_manager/domain/repositories/user_settings_repository.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';
import 'package:iot_manager/domain/usecases/certificate_usecases.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';
import 'package:iot_manager/domain/usecases/topic_usecases.dart';
import 'package:iot_manager/domain/usecases/message_usecases.dart';
import 'package:iot_manager/domain/usecases/user_settings_usecases.dart';
import 'package:iot_manager/domain/usecases/dashboard_usecases.dart';
import 'package:iot_manager/domain/usecases/log_usecases.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

final getIt = GetIt.instance;

/// Setup all dependencies for the application
/// 
/// This function should be called in main.dart before runApp()
/// 
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await setupServiceLocator();
///   runApp(const MyApp());
/// }
/// ```
Future<void> setupServiceLocator() async {
  // ============================================================
  // CORE LAYER: Base services and external dependencies
  // ============================================================
  
  // Database Service (Singleton)
  final databaseService = DatabaseService();
  final database = await databaseService.database;
  getIt.registerSingleton<DatabaseService>(databaseService);
  
  // EventBus (Singleton)
  // NOTE: EventBusImpl needs to be created - placeholder for interface
  // getIt.registerSingleton<EventBus>(EventBusImpl());
  
  // ============================================================
  // DATA LAYER: LocalDataSources (Singletons)
  // ============================================================
  
  // Protocol LocalDataSource
  getIt.registerSingleton<ProtocolLocalDataSource>(
    ProtocolLocalDataSourceImpl(database),
  );
  
  // Certificate LocalDataSource
  getIt.registerSingleton<CertificateLocalDataSource>(
    CertificateLocalDataSourceImpl(database),
  );
  
  // Connection LocalDataSource
  getIt.registerSingleton<ConnectionLocalDataSource>(
    ConnectionLocalDataSourceImpl(database),
  );
  
  // Topic LocalDataSource
  getIt.registerSingleton<TopicLocalDataSource>(
    TopicLocalDataSourceImpl(database),
  );
  
  // Message LocalDataSource
  getIt.registerSingleton<MessageLocalDataSource>(
    MessageLocalDataSourceImpl(database),
  );
  
  // User Settings LocalDataSource
  getIt.registerSingleton<UserSettingsLocalDataSource>(
    UserSettingsLocalDataSourceImpl(database),
  );
  
  // Dashboard LocalDataSource
  getIt.registerSingleton<DashboardLocalDataSource>(
    DashboardLocalDataSourceImpl(database),
  );
  
  // Log LocalDataSource
  getIt.registerSingleton<LogLocalDataSource>(
    LogLocalDataSourceImpl(database),
  );
  
  // ============================================================
  // DATA LAYER: Repositories (Singletons)
  // ============================================================
  
  // Protocol Repository
  getIt.registerSingleton<ProtocolRepository>(
    ProtocolRepositoryImpl(
      getIt<ProtocolLocalDataSource>(),
    ),
  );
  
  // Certificate Repository
  getIt.registerSingleton<CertificateRepository>(
    CertificateRepositoryImpl(
      getIt<CertificateLocalDataSource>(),
    ),
  );
  
  // Connection Repository
  getIt.registerSingleton<ConnectionRepository>(
    ConnectionRepositoryImpl(
      getIt<ConnectionLocalDataSource>(),
    ),
  );
  
  // Topic Repository
  getIt.registerSingleton<TopicRepository>(
    TopicRepositoryImpl(
      getIt<TopicLocalDataSource>(),
    ),
  );
  
  // Message Repository
  getIt.registerSingleton<MessageRepository>(
    MessageRepositoryImpl(
      getIt<MessageLocalDataSource>(),
    ),
  );
  
  // User Settings Repository
  getIt.registerSingleton<UserSettingsRepository>(
    UserSettingsRepositoryImpl(
      getIt<UserSettingsLocalDataSource>(),
    ),
  );
  
  // Dashboard Repository
  getIt.registerSingleton<DashboardRepository>(
    DashboardRepositoryImpl(
      getIt<DashboardLocalDataSource>(),
    ),
  );
  
  // Log Repository
  getIt.registerSingleton<LogRepository>(
    LogRepositoryImpl(
      getIt<LogLocalDataSource>(),
    ),
  );
  
  // NOTE: Command and Device repositories not yet implemented
  // getIt.registerSingleton<CommandRepository>(...);
  // getIt.registerSingleton<DeviceRepository>(...);
  
  // ============================================================
  // DOMAIN LAYER: UseCases (Factories)
  // ============================================================
  
  // === Protocol UseCases ===
  getIt.registerFactory<GetAllProtocolsUseCase>(
    () => GetAllProtocolsUseCase(getIt<ProtocolRepository>()),
  );
  getIt.registerFactory<GetProtocolByIdUseCase>(
    () => GetProtocolByIdUseCase(getIt<ProtocolRepository>()),
  );
  getIt.registerFactory<CreateProtocolUseCase>(
    () => CreateProtocolUseCase(getIt<ProtocolRepository>()),
  );
  getIt.registerFactory<UpdateProtocolUseCase>(
    () => UpdateProtocolUseCase(getIt<ProtocolRepository>()),
  );
  getIt.registerFactory<DeleteProtocolUseCase>(
    () => DeleteProtocolUseCase(getIt<ProtocolRepository>()),
  );
  getIt.registerFactory<GetProtocolsByTypeUseCase>(
    () => GetProtocolsByTypeUseCase(getIt<ProtocolRepository>()),
  );
  
  // === Certificate UseCases ===
  getIt.registerFactory<GetAllCertificatesUseCase>(
    () => GetAllCertificatesUseCase(getIt<CertificateRepository>()),
  );
  getIt.registerFactory<GetCertificateByIdUseCase>(
    () => GetCertificateByIdUseCase(getIt<CertificateRepository>()),
  );
  getIt.registerFactory<CreateCertificateUseCase>(
    () => CreateCertificateUseCase(getIt<CertificateRepository>()),
  );
  getIt.registerFactory<UpdateCertificateUseCase>(
    () => UpdateCertificateUseCase(getIt<CertificateRepository>()),
  );
  getIt.registerFactory<DeleteCertificateUseCase>(
    () => DeleteCertificateUseCase(getIt<CertificateRepository>()),
  );
  
  // === Connection UseCases ===
  getIt.registerFactory<GetAllConnectionsUseCase>(
    () => GetAllConnectionsUseCase(getIt<ConnectionRepository>()),
  );
  getIt.registerFactory<GetConnectionByIdUseCase>(
    () => GetConnectionByIdUseCase(getIt<ConnectionRepository>()),
  );
  getIt.registerFactory<CreateConnectionUseCase>(
    () => CreateConnectionUseCase(getIt<ConnectionRepository>()),
  );
  getIt.registerFactory<UpdateConnectionUseCase>(
    () => UpdateConnectionUseCase(getIt<ConnectionRepository>()),
  );
  getIt.registerFactory<DeleteConnectionUseCase>(
    () => DeleteConnectionUseCase(getIt<ConnectionRepository>()),
  );
  
  // === Topic UseCases ===
  getIt.registerFactory<GetAllTopicsUseCase>(
    () => GetAllTopicsUseCase(getIt<TopicRepository>()),
  );
  getIt.registerFactory<GetTopicByIdUseCase>(
    () => GetTopicByIdUseCase(getIt<TopicRepository>()),
  );
  getIt.registerFactory<CreateTopicUseCase>(
    () => CreateTopicUseCase(getIt<TopicRepository>()),
  );
  getIt.registerFactory<UpdateTopicUseCase>(
    () => UpdateTopicUseCase(getIt<TopicRepository>()),
  );
  getIt.registerFactory<DeleteTopicUseCase>(
    () => DeleteTopicUseCase(getIt<TopicRepository>()),
  );
  
  // === Message UseCases ===
  getIt.registerFactory<GetAllMessagesUseCase>(
    () => GetAllMessagesUseCase(getIt<MessageRepository>()),
  );
  getIt.registerFactory<GetMessageByIdUseCase>(
    () => GetMessageByIdUseCase(getIt<MessageRepository>()),
  );
  getIt.registerFactory<CreateMessageUseCase>(
    () => CreateMessageUseCase(getIt<MessageRepository>()),
  );
  getIt.registerFactory<UpdateMessageUseCase>(
    () => UpdateMessageUseCase(getIt<MessageRepository>()),
  );
  getIt.registerFactory<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(getIt<MessageRepository>()),
  );
  
  // === User Settings UseCases ===
  getIt.registerFactory<GetUserSettingsUseCase>(
    () => GetUserSettingsUseCase(getIt<UserSettingsRepository>()),
  );
  getIt.registerFactory<GetUserSettingsByIdUseCase>(
    () => GetUserSettingsByIdUseCase(getIt<UserSettingsRepository>()),
  );
  getIt.registerFactory<UpdateUserSettingsUseCase>(
    () => UpdateUserSettingsUseCase(getIt<UserSettingsRepository>()),
  );
  
  // === Dashboard UseCases ===
  getIt.registerFactory<GetAllDashboardsUseCase>(
    () => GetAllDashboardsUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<GetDashboardByIdUseCase>(
    () => GetDashboardByIdUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<CreateDashboardUseCase>(
    () => CreateDashboardUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<UpdateDashboardUseCase>(
    () => UpdateDashboardUseCase(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<DeleteDashboardUseCase>(
    () => DeleteDashboardUseCase(getIt<DashboardRepository>()),
  );
  
  // === Log Entry UseCases ===
  getIt.registerFactory<GetAllLogEntriesUseCase>(
    () => GetAllLogEntriesUseCase(getIt<LogRepository>()),
  );
  getIt.registerFactory<GetLogEntryByIdUseCase>(
    () => GetLogEntryByIdUseCase(getIt<LogRepository>()),
  );
  getIt.registerFactory<CreateLogEntryUseCase>(
    () => CreateLogEntryUseCase(getIt<LogRepository>()),
  );
  getIt.registerFactory<UpdateLogEntryUseCase>(
    () => UpdateLogEntryUseCase(getIt<LogRepository>()),
  );
  getIt.registerFactory<DeleteLogEntryUseCase>(
    () => DeleteLogEntryUseCase(getIt<LogRepository>()),
  );
  
  // ============================================================
  // PRESENTATION LAYER: ViewModels (Factories)
  // ============================================================
  
  // NOTE: ViewModels will be registered here as factories
  // Example pattern:
  // getIt.registerFactory<ProtocolListViewModel>(
  //   () => ProtocolListViewModel(
  //     getIt<ProtocolRepository>(),
  //     getIt<EventBus>(),
  //   ),
  // );
  
  // ============================================================
  // Test/Validation
  // ============================================================
  
  _validateDependencyInjection();
}

/// Validates that all critical dependencies are registered
/// Throws an exception if any required dependency is missing
void _validateDependencyInjection() {
  try {
    // Validate Core Layer
    assert(
      getIt.isRegistered<DatabaseService>(),
      'DatabaseService not registered',
    );
    
    // Validate Data Layer - LocalDataSources
    assert(
      getIt.isRegistered<ProtocolLocalDataSource>(),
      'ProtocolLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<CertificateLocalDataSource>(),
      'CertificateLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<ConnectionLocalDataSource>(),
      'ConnectionLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<TopicLocalDataSource>(),
      'TopicLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<MessageLocalDataSource>(),
      'MessageLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<UserSettingsLocalDataSource>(),
      'UserSettingsLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<DashboardLocalDataSource>(),
      'DashboardLocalDataSource not registered',
    );
    assert(
      getIt.isRegistered<LogLocalDataSource>(),
      'LogLocalDataSource not registered',
    );
    
    // Validate Data Layer - Repositories
    assert(
      getIt.isRegistered<ProtocolRepository>(),
      'ProtocolRepository not registered',
    );
    assert(
      getIt.isRegistered<CertificateRepository>(),
      'CertificateRepository not registered',
    );
    assert(
      getIt.isRegistered<ConnectionRepository>(),
      'ConnectionRepository not registered',
    );
    assert(
      getIt.isRegistered<TopicRepository>(),
      'TopicRepository not registered',
    );
    assert(
      getIt.isRegistered<MessageRepository>(),
      'MessageRepository not registered',
    );
    assert(
      getIt.isRegistered<UserSettingsRepository>(),
      'UserSettingsRepository not registered',
    );
    assert(
      getIt.isRegistered<DashboardRepository>(),
      'DashboardRepository not registered',
    );
    assert(
      getIt.isRegistered<LogRepository>(),
      'LogRepository not registered',
    );
    
    print('✓ Dependency Injection Setup Validated Successfully');
  } catch (e) {
    print('✗ Dependency Injection Validation Failed: $e');
    rethrow;
  }
}

/// Reset all dependencies (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
