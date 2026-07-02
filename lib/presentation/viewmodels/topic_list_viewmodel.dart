import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/topic.dart';
import 'package:iot_manager/domain/events/topic_events.dart';
import 'package:iot_manager/domain/repositories/topic_repository.dart';
import 'package:iot_manager/domain/usecases/topic_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Topic management
class TopicListViewModel extends BaseViewModel {
  final TopicRepository _topicRepository;
  final EventBus _eventBus;
  final GetAllTopicsUseCase _getAllTopicsUseCase;
  final CreateTopicUseCase _createTopicUseCase;
  final UpdateTopicUseCase _updateTopicUseCase;
  final DeleteTopicUseCase _deleteTopicUseCase;

  /// Observable state
  final ValueNotifier<List<Topic>> topics = ValueNotifier([]);
  final ValueNotifier<Topic?> selectedTopic = ValueNotifier(null);
  final ValueNotifier<int> subscribedCount = ValueNotifier(0);

  TopicListViewModel({
    required TopicRepository topicRepository,
    required EventBus eventBus,
    required GetAllTopicsUseCase getAllTopicsUseCase,
    required CreateTopicUseCase createTopicUseCase,
    required UpdateTopicUseCase updateTopicUseCase,
    required DeleteTopicUseCase deleteTopicUseCase,
  })  : _topicRepository = topicRepository,
        _eventBus = eventBus,
        _getAllTopicsUseCase = getAllTopicsUseCase,
        _createTopicUseCase = createTopicUseCase,
        _updateTopicUseCase = updateTopicUseCase,
        _deleteTopicUseCase = deleteTopicUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<TopicsLoadedEvent>(_onTopicsLoaded);
    _eventBus.listen<TopicCreatedEvent>(_onTopicCreated);
    _eventBus.listen<TopicUpdatedEvent>(_onTopicUpdated);
    _eventBus.listen<TopicDeletedEvent>(_onTopicDeleted);
    _eventBus.listen<TopicSubscribedEvent>(_onTopicSubscribed);
    _eventBus.listen<TopicUnsubscribedEvent>(_onTopicUnsubscribed);
  }

  Future<void> loadTopics() async {
    isLoading.value = true;
    clearError();

    final result = await _topicRepository.getAllTopics();

    if (result.isSuccess) {
      // Event will be published
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> loadSubscribedTopics() async {
    isLoading.value = true;
    clearError();

    final result = await _topicRepository.getSubscribedTopics();

    if (result.isSuccess) {
      subscribedCount.value = result.value?.length ?? 0;
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> createTopic(Topic topic) async {
    isLoading.value = true;
    clearError();

    final result = await _topicRepository.createTopic(topic);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Topic created: ${topic.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> updateTopic(Topic topic) async {
    isLoading.value = true;
    clearError();

    final result = await _topicRepository.updateTopic(topic);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Topic updated: ${topic.name}');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> deleteTopic(String topicId) async {
    isLoading.value = true;
    clearError();

    final result = await _topicRepository.deleteTopic(topicId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void selectTopic(Topic topic) {
    selectedTopic.value = topic;
    notifyListeners();
  }

  void clearSelection() {
    selectedTopic.value = null;
    notifyListeners();
  }

  void _onTopicsLoaded(TopicsLoadedEvent event) {
    topics.value = event.topics;
    notifyListeners();
  }

  void _onTopicCreated(TopicCreatedEvent event) {
    if (!topics.value.any((t) => t.id == event.topic.id)) {
      topics.value = [...topics.value, event.topic];
      notifyListeners();
    }
  }

  void _onTopicUpdated(TopicUpdatedEvent event) {
    final index = topics.value.indexWhere((t) => t.id == event.topic.id);
    if (index != -1) {
      topics.value = [
        ...topics.value.sublist(0, index),
        event.topic,
        ...topics.value.sublist(index + 1),
      ];
      notifyListeners();
    }
  }

  void _onTopicDeleted(TopicDeletedEvent event) {
    topics.value = topics.value.where((t) => t.id != event.topicId).toList();
    if (selectedTopic.value?.id == event.topicId) {
      selectedTopic.value = null;
    }
    notifyListeners();
  }

  void _onTopicSubscribed(TopicSubscribedEvent event) {
    subscribedCount.value++;
    setSuccess('Subscribed to: ${event.topic}');
    notifyListeners();
  }

  void _onTopicUnsubscribed(TopicUnsubscribedEvent event) {
    subscribedCount.value--;
    setSuccess('Unsubscribed from: ${event.topic}');
    notifyListeners();
  }

  @override
  void initialize() {
    loadTopics();
    loadSubscribedTopics();
  }

  @override
  void dispose() {
    topics.dispose();
    selectedTopic.dispose();
    subscribedCount.dispose();
    super.dispose();
  }
}
