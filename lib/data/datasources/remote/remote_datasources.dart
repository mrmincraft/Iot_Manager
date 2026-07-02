import 'package:iot_manager/core/network/http_client_service.dart';
import 'package:iot_manager/core/network/network_exceptions.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/entities/topic.dart';
import 'package:iot_manager/domain/entities/message.dart';
import 'package:iot_manager/domain/entities/user_settings.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/domain/entities/log_entry.dart';
import 'package:iot_manager/data/dtos/certificate_dto.dart';
import 'package:iot_manager/data/dtos/topic_dto.dart';
import 'package:iot_manager/data/dtos/message_dto.dart';
import 'package:iot_manager/data/dtos/user_settings_dto.dart';
import 'package:iot_manager/data/dtos/dashboard_dto.dart';
import 'package:iot_manager/data/dtos/log_entry_dto.dart';

// Certificate Remote Data Source
abstract class CertificateRemoteDataSource {
  Future<Result<List<Certificate>, NetworkException>> getAllCertificates();
  Future<Result<Certificate, NetworkException>> getCertificateById(String id);
  Future<Result<Certificate, NetworkException>> createCertificate(Certificate certificate);
  Future<Result<Certificate, NetworkException>> updateCertificate(Certificate certificate);
  Future<Result<void, NetworkException>> deleteCertificate(String id);
  Future<Result<List<Certificate>, NetworkException>> getExpiringCertificates({int daysUntilExpiry});
}

class CertificateRemoteDataSourceImpl implements CertificateRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/certificates';

  CertificateRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<Certificate>, NetworkException>> getAllCertificates() async {
    try {
      final result = await _httpClient.get<List<CertificateDTO>>(_baseEndpoint);
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Certificate, NetworkException>> getCertificateById(String id) async {
    try {
      final result = await _httpClient.get<CertificateDTO>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Certificate, NetworkException>> createCertificate(Certificate certificate) async {
    try {
      final dto = CertificateDTO.fromEntity(certificate);
      final result = await _httpClient.post<CertificateDTO>(_baseEndpoint, body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Certificate, NetworkException>> updateCertificate(Certificate certificate) async {
    try {
      final dto = CertificateDTO.fromEntity(certificate);
      final result = await _httpClient.put<CertificateDTO>('$_baseEndpoint/${certificate.id}', body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteCertificate(String id) async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<Certificate>, NetworkException>> getExpiringCertificates({int daysUntilExpiry = 30}) async {
    try {
      final result = await _httpClient.get<List<CertificateDTO>>(
        '$_baseEndpoint/expiring',
        queryParameters: {'days': daysUntilExpiry},
      );
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}

// Topic Remote Data Source
abstract class TopicRemoteDataSource {
  Future<Result<List<Topic>, NetworkException>> getAllTopics();
  Future<Result<Topic, NetworkException>> getTopicById(String id);
  Future<Result<Topic, NetworkException>> createTopic(Topic topic);
  Future<Result<Topic, NetworkException>> updateTopic(Topic topic);
  Future<Result<void, NetworkException>> deleteTopic(String id);
  Future<Result<List<Topic>, NetworkException>> getSubscribedTopics();
}

class TopicRemoteDataSourceImpl implements TopicRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/topics';

  TopicRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<Topic>, NetworkException>> getAllTopics() async {
    try {
      final result = await _httpClient.get<List<TopicDTO>>(_baseEndpoint);
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Topic, NetworkException>> getTopicById(String id) async {
    try {
      final result = await _httpClient.get<TopicDTO>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Topic, NetworkException>> createTopic(Topic topic) async {
    try {
      final dto = TopicDTO.fromEntity(topic);
      final result = await _httpClient.post<TopicDTO>(_baseEndpoint, body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Topic, NetworkException>> updateTopic(Topic topic) async {
    try {
      final dto = TopicDTO.fromEntity(topic);
      final result = await _httpClient.put<TopicDTO>('$_baseEndpoint/${topic.id}', body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteTopic(String id) async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<Topic>, NetworkException>> getSubscribedTopics() async {
    try {
      final result = await _httpClient.get<List<TopicDTO>>('$_baseEndpoint/subscribed');
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}

// Message Remote Data Source
abstract class MessageRemoteDataSource {
  Future<Result<List<Message>, NetworkException>> getAllMessages();
  Future<Result<Message, NetworkException>> getMessageById(String id);
  Future<Result<Message, NetworkException>> createMessage(Message message);
  Future<Result<Message, NetworkException>> updateMessage(Message message);
  Future<Result<void, NetworkException>> deleteMessage(String id);
  Future<Result<List<Message>, NetworkException>> getMessagesByConnection(String connectionId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/messages';

  MessageRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<Message>, NetworkException>> getAllMessages() async {
    try {
      final result = await _httpClient.get<List<MessageDTO>>(_baseEndpoint);
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Message, NetworkException>> getMessageById(String id) async {
    try {
      final result = await _httpClient.get<MessageDTO>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Message, NetworkException>> createMessage(Message message) async {
    try {
      final dto = MessageDTO.fromEntity(message);
      final result = await _httpClient.post<MessageDTO>(_baseEndpoint, body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Message, NetworkException>> updateMessage(Message message) async {
    try {
      final dto = MessageDTO.fromEntity(message);
      final result = await _httpClient.put<MessageDTO>('$_baseEndpoint/${message.id}', body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteMessage(String id) async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<Message>, NetworkException>> getMessagesByConnection(String connectionId) async {
    try {
      final result = await _httpClient.get<List<MessageDTO>>(_baseEndpoint, queryParameters: {'connectionId': connectionId});
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}

// User Settings Remote Data Source
abstract class UserSettingsRemoteDataSource {
  Future<Result<UserSettings, NetworkException>> getUserSettings(String userId);
  Future<Result<UserSettings, NetworkException>> updateUserSettings(UserSettings settings);
}

class UserSettingsRemoteDataSourceImpl implements UserSettingsRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/users';

  UserSettingsRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<UserSettings, NetworkException>> getUserSettings(String userId) async {
    try {
      final result = await _httpClient.get<UserSettingsDTO>('$_baseEndpoint/$userId/settings');
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<UserSettings, NetworkException>> updateUserSettings(UserSettings settings) async {
    try {
      final dto = UserSettingsDTO.fromEntity(settings);
      final result = await _httpClient.put<UserSettingsDTO>(
        '$_baseEndpoint/${settings.userId}/settings',
        body: dto.toJson(),
      );
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}

// Dashboard Remote Data Source
abstract class DashboardRemoteDataSource {
  Future<Result<List<Dashboard>, NetworkException>> getAllDashboards();
  Future<Result<Dashboard, NetworkException>> getDashboardById(String id);
  Future<Result<Dashboard, NetworkException>> createDashboard(Dashboard dashboard);
  Future<Result<Dashboard, NetworkException>> updateDashboard(Dashboard dashboard);
  Future<Result<void, NetworkException>> deleteDashboard(String id);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/dashboards';

  DashboardRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<Dashboard>, NetworkException>> getAllDashboards() async {
    try {
      final result = await _httpClient.get<List<DashboardDTO>>(_baseEndpoint);
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Dashboard, NetworkException>> getDashboardById(String id) async {
    try {
      final result = await _httpClient.get<DashboardDTO>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Dashboard, NetworkException>> createDashboard(Dashboard dashboard) async {
    try {
      final dto = DashboardDTO.fromEntity(dashboard);
      final result = await _httpClient.post<DashboardDTO>(_baseEndpoint, body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<Dashboard, NetworkException>> updateDashboard(Dashboard dashboard) async {
    try {
      final dto = DashboardDTO.fromEntity(dashboard);
      final result = await _httpClient.put<DashboardDTO>('$_baseEndpoint/${dashboard.id}', body: dto.toJson());
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteDashboard(String id) async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}

// Log Remote Data Source
abstract class LogRemoteDataSource {
  Future<Result<List<LogEntry>, NetworkException>> getAllLogs();
  Future<Result<LogEntry, NetworkException>> getLogById(String id);
  Future<Result<void, NetworkException>> deleteLog(String id);
  Future<Result<void, NetworkException>> clearAllLogs();
  Future<Result<List<LogEntry>, NetworkException>> getLogsBySeverity(LogSeverity severity);
}

class LogRemoteDataSourceImpl implements LogRemoteDataSource {
  final HttpClientService _httpClient;
  static const String _baseEndpoint = '/logs';

  LogRemoteDataSourceImpl({required HttpClientService httpClient})
      : _httpClient = httpClient;

  @override
  Future<Result<List<LogEntry>, NetworkException>> getAllLogs() async {
    try {
      final result = await _httpClient.get<List<LogEntryDTO>>(_baseEndpoint);
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<LogEntry, NetworkException>> getLogById(String id) async {
    try {
      final result = await _httpClient.get<LogEntryDTO>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(result.value!.toEntity());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> deleteLog(String id) async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/$id');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<void, NetworkException>> clearAllLogs() async {
    try {
      final result = await _httpClient.delete<void>('$_baseEndpoint/all');
      if (result.isSuccess) {
        return Result.success(null);
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<LogEntry>, NetworkException>> getLogsBySeverity(LogSeverity severity) async {
    try {
      final result = await _httpClient.get<List<LogEntryDTO>>(
        _baseEndpoint,
        queryParameters: {'severity': severity.toString()},
      );
      if (result.isSuccess) {
        return Result.success((result.value ?? []).map((dto) => dto.toEntity()).toList());
      }
      return Result.failure(result.error!);
    } on NetworkException catch (e) {
      return Result.failure(e);
    }
  }
}
