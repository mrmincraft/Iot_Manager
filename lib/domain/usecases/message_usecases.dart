import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/domain/entities/message.dart';
import 'package:iot_manager/domain/repositories/message_repository.dart';
import 'package:iot_manager/domain/usecases/usecase.dart';

// ============================================================
// GET ALL MESSAGES
// ============================================================

/// Get All Messages Use Case
class GetAllMessagesUseCase extends UseCase<List<Message>, NoParams> {
  final MessageRepository _messageRepository;

  GetAllMessagesUseCase(this._messageRepository);

  @override
  Future<Result<List<Message>>> call(NoParams params) async {
    return _messageRepository.getAllMessages();
  }
}

// ============================================================
// GET MESSAGE BY ID
// ============================================================

class GetMessageByIdParams {
  final String id;
  GetMessageByIdParams({required this.id});
}

/// Get Message By ID Use Case
class GetMessageByIdUseCase extends UseCase<Message, GetMessageByIdParams> {
  final MessageRepository _messageRepository;

  GetMessageByIdUseCase(this._messageRepository);

  @override
  Future<Result<Message>> call(GetMessageByIdParams params) async {
    return _messageRepository.getMessageById(params.id);
  }
}

// ============================================================
// CREATE MESSAGE
// ============================================================

class CreateMessageParams {
  final Message message;
  CreateMessageParams({required this.message});
}

/// Create Message Use Case
class CreateMessageUseCase extends UseCase<Message, CreateMessageParams> {
  final MessageRepository _messageRepository;

  CreateMessageUseCase(this._messageRepository);

  @override
  Future<Result<Message>> call(CreateMessageParams params) async {
    return _messageRepository.createMessage(params.message);
  }
}

// ============================================================
// UPDATE MESSAGE
// ============================================================

class UpdateMessageParams {
  final Message message;
  UpdateMessageParams({required this.message});
}

/// Update Message Use Case
class UpdateMessageUseCase extends UseCase<Message, UpdateMessageParams> {
  final MessageRepository _messageRepository;

  UpdateMessageUseCase(this._messageRepository);

  @override
  Future<Result<Message>> call(UpdateMessageParams params) async {
    return _messageRepository.updateMessage(params.message);
  }
}

// ============================================================
// DELETE MESSAGE
// ============================================================

class DeleteMessageParams {
  final String id;
  DeleteMessageParams({required this.id});
}

/// Delete Message Use Case
class DeleteMessageUseCase extends UseCase<void, DeleteMessageParams> {
  final MessageRepository _messageRepository;

  DeleteMessageUseCase(this._messageRepository);

  @override
  Future<Result<void>> call(DeleteMessageParams params) async {
    return _messageRepository.deleteMessage(params.id);
  }
}
