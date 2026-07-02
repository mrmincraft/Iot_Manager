import 'package:flutter/foundation.dart';
import 'package:iot_manager/core/events/event_bus.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/message.dart';
import 'package:iot_manager/domain/events/message_events.dart';
import 'package:iot_manager/domain/repositories/message_repository.dart';
import 'package:iot_manager/domain/usecases/message_usecases.dart';
import 'package:iot_manager/presentation/viewmodels/base_viewmodel.dart';

/// ViewModel for Message management
class MessageListViewModel extends BaseViewModel {
  final MessageRepository _messageRepository;
  final EventBus _eventBus;
  final GetAllMessagesUseCase _getAllMessagesUseCase;
  final CreateMessageUseCase _createMessageUseCase;
  final UpdateMessageUseCase _updateMessageUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;

  /// Observable state
  final ValueNotifier<List<Message>> messages = ValueNotifier([]);
  final ValueNotifier<Message?> selectedMessage = ValueNotifier(null);
  final ValueNotifier<int> incomingCount = ValueNotifier(0);
  final ValueNotifier<int> outgoingCount = ValueNotifier(0);
  final ValueNotifier<int> failedCount = ValueNotifier(0);

  MessageListViewModel({
    required MessageRepository messageRepository,
    required EventBus eventBus,
    required GetAllMessagesUseCase getAllMessagesUseCase,
    required CreateMessageUseCase createMessageUseCase,
    required UpdateMessageUseCase updateMessageUseCase,
    required DeleteMessageUseCase deleteMessageUseCase,
  })  : _messageRepository = messageRepository,
        _eventBus = eventBus,
        _getAllMessagesUseCase = getAllMessagesUseCase,
        _createMessageUseCase = createMessageUseCase,
        _updateMessageUseCase = updateMessageUseCase,
        _deleteMessageUseCase = deleteMessageUseCase {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _eventBus.listen<MessagesLoadedEvent>(_onMessagesLoaded);
    _eventBus.listen<MessageReceivedEvent>(_onMessageReceived);
    _eventBus.listen<MessageSentEvent>(_onMessageSent);
    _eventBus.listen<MessageSendFailedEvent>(_onMessageSendFailed);
    _eventBus.listen<MessageUpdatedEvent>(_onMessageUpdated);
    _eventBus.listen<MessageDeletedEvent>(_onMessageDeleted);
    _eventBus.listen<MessagesClearedEvent>(_onMessagesCleared);
  }

  Future<void> loadMessages() async {
    isLoading.value = true;
    clearError();

    final result = await _messageRepository.getAllMessages();

    if (result.isSuccess) {
      _updateCounts();
    } else {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> sendMessage(Message message) async {
    isLoading.value = true;
    clearError();

    final result = await _messageRepository.createMessage(message);

    if (result.isFailure) {
      handleException(result.error!);
    } else {
      setSuccess('Message sent');
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> deleteMessage(String messageId) async {
    isLoading.value = true;
    clearError();

    final result = await _messageRepository.deleteMessage(messageId);

    if (result.isFailure) {
      handleException(result.error!);
    }

    isLoading.value = false;
    notifyListeners();
  }

  Future<void> clearMessages(String connectionId) async {
    isLoading.value = true;
    clearError();

    final allMessages = messages.value.where((m) => m.connectionId == connectionId).toList();
    
    for (final msg in allMessages) {
      await _messageRepository.deleteMessage(msg.id);
    }

    isLoading.value = false;
    notifyListeners();
  }

  void selectMessage(Message message) {
    selectedMessage.value = message;
    notifyListeners();
  }

  void clearSelection() {
    selectedMessage.value = null;
    notifyListeners();
  }

  void _onMessagesLoaded(MessagesLoadedEvent event) {
    messages.value = event.messages;
    _updateCounts();
    notifyListeners();
  }

  void _onMessageReceived(MessageReceivedEvent event) {
    if (!messages.value.any((m) => m.id == event.message.id)) {
      messages.value = [event.message, ...messages.value];
      incomingCount.value++;
      notifyListeners();
    }
  }

  void _onMessageSent(MessageSentEvent event) {
    if (!messages.value.any((m) => m.id == event.message.id)) {
      messages.value = [event.message, ...messages.value];
      outgoingCount.value++;
      notifyListeners();
    }
  }

  void _onMessageSendFailed(MessageSendFailedEvent event) {
    failedCount.value++;
    setError('Message send failed: ${event.error}');
    notifyListeners();
  }

  void _onMessageUpdated(MessageUpdatedEvent event) {
    final index = messages.value.indexWhere((m) => m.id == event.message.id);
    if (index != -1) {
      messages.value = [
        ...messages.value.sublist(0, index),
        event.message,
        ...messages.value.sublist(index + 1),
      ];
      notifyListeners();
    }
  }

  void _onMessageDeleted(MessageDeletedEvent event) {
    messages.value = messages.value.where((m) => m.id != event.messageId).toList();
    if (selectedMessage.value?.id == event.messageId) {
      selectedMessage.value = null;
    }
    _updateCounts();
    notifyListeners();
  }

  void _onMessagesCleared(MessagesClearedEvent event) {
    messages.value = messages.value.where((m) => m.connectionId != event.connectionId).toList();
    _updateCounts();
    setSuccess('${event.clearedCount} messages cleared');
    notifyListeners();
  }

  void _updateCounts() {
    incomingCount.value = messages.value.where((m) => m.direction == MessageDirection.incoming).length;
    outgoingCount.value = messages.value.where((m) => m.direction == MessageDirection.outgoing).length;
  }

  @override
  void initialize() {
    loadMessages();
  }

  @override
  void dispose() {
    messages.dispose();
    selectedMessage.dispose();
    incomingCount.dispose();
    outgoingCount.dispose();
    failedCount.dispose();
    super.dispose();
  }
}
