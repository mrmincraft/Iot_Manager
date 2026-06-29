import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/topic.dart';
import 'package:iot_manager/domain/repositories/topic_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL TOPICS
// ============================================================

/// Get All Topics Use Case
class GetAllTopicsUseCase extends UseCase<List<Topic>, NoParams> {
  final TopicRepository _topicRepository;

  GetAllTopicsUseCase(this._topicRepository);

  @override
  Future<Result<List<Topic>>> call(NoParams params) async {
    return _topicRepository.getAllTopics();
  }
}

// ============================================================
// GET TOPIC BY ID
// ============================================================

class GetTopicByIdParams {
  final String id;
  GetTopicByIdParams({required this.id});
}

/// Get Topic By ID Use Case
class GetTopicByIdUseCase extends UseCase<Topic, GetTopicByIdParams> {
  final TopicRepository _topicRepository;

  GetTopicByIdUseCase(this._topicRepository);

  @override
  Future<Result<Topic>> call(GetTopicByIdParams params) async {
    return _topicRepository.getTopicById(params.id);
  }
}

// ============================================================
// CREATE TOPIC
// ============================================================

class CreateTopicParams {
  final Topic topic;
  CreateTopicParams({required this.topic});
}

/// Create Topic Use Case
class CreateTopicUseCase extends UseCase<Topic, CreateTopicParams> {
  final TopicRepository _topicRepository;

  CreateTopicUseCase(this._topicRepository);

  @override
  Future<Result<Topic>> call(CreateTopicParams params) async {
    return _topicRepository.createTopic(params.topic);
  }
}

// ============================================================
// UPDATE TOPIC
// ============================================================

class UpdateTopicParams {
  final Topic topic;
  UpdateTopicParams({required this.topic});
}

/// Update Topic Use Case
class UpdateTopicUseCase extends UseCase<Topic, UpdateTopicParams> {
  final TopicRepository _topicRepository;

  UpdateTopicUseCase(this._topicRepository);

  @override
  Future<Result<Topic>> call(UpdateTopicParams params) async {
    return _topicRepository.updateTopic(params.topic);
  }
}

// ============================================================
// DELETE TOPIC
// ============================================================

class DeleteTopicParams {
  final String id;
  DeleteTopicParams({required this.id});
}

/// Delete Topic Use Case
class DeleteTopicUseCase extends UseCase<void, DeleteTopicParams> {
  final TopicRepository _topicRepository;

  DeleteTopicUseCase(this._topicRepository);

  @override
  Future<Result<void>> call(DeleteTopicParams params) async {
    return _topicRepository.deleteTopic(params.id);
  }
}
