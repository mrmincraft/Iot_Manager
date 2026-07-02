import '../../core/events/app_event.dart';
import '../entities/protocol.dart';

/// Event fired when a new protocol is added to the system
class ProtocolAddedEvent extends AppEvent {
  final Protocol protocol;

  ProtocolAddedEvent(this.protocol);
}

/// Event fired when a protocol is updated
class ProtocolUpdatedEvent extends AppEvent {
  final Protocol protocol;
  final Protocol? previousProtocol;

  ProtocolUpdatedEvent({
    required this.protocol,
    this.previousProtocol,
  });
}

/// Event fired when a protocol is deleted
class ProtocolDeletedEvent extends AppEvent {
  final String protocolId;
  final Protocol? deletedProtocol;

  ProtocolDeletedEvent({
    required this.protocolId,
    this.deletedProtocol,
  });
}

/// Event fired when all protocols are loaded
class ProtocolsLoadedEvent extends AppEvent {
  final List<Protocol> protocols;

  ProtocolsLoadedEvent(this.protocols);
}

/// Event fired when a protocol is retrieved by ID
class ProtocolRetrievedEvent extends AppEvent {
  final Protocol protocol;

  ProtocolRetrievedEvent(this.protocol);
}
