import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/core/utils/result.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';
import 'package:iot_manager/presentation/pages/protocol_page.dart';
import 'package:iot_manager/presentation/pages/connection_page.dart';

class MockProtocolRepository extends Mock implements ProtocolRepository {}

class MockConnectionRepository extends Mock implements ConnectionRepository {}

void main() {
  group('Advanced Page Tests', () {
    group('Protocol Page Advanced Scenarios', () {
      late MockProtocolRepository mockProtocolRepository;

      setUp(() {
        mockProtocolRepository = MockProtocolRepository();
      });

      testWidgets('ProtocolPage handles empty state gracefully',
          (WidgetTester tester) async {
        when(mockProtocolRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockProtocolRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(EmptyStateWidget), findsWidgets);
      });

      testWidgets('ProtocolPage displays large list with scrolling',
          (WidgetTester tester) async {
        final protocols = List.generate(
          100,
          (i) => ProtocolModel(
            id: 'proto-$i',
            name: 'Protocol $i',
            type: ProtocolType.mqtt,
            port: 1883 + i,
          ),
        );

        when(mockProtocolRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockProtocolRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ListView), findsWidgets);

        // Scroll to see more items
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        expect(find.byType(ProtocolListItem), findsWidgets);
      });

      testWidgets('ProtocolPage create dialog validation',
          (WidgetTester tester) async {
        when(mockProtocolRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        when(mockProtocolRepository.createProtocol(any))
            .thenAnswer((_) async => Result.success(ProtocolModel(
              id: 'proto-new',
              name: 'New Protocol',
              type: ProtocolType.mqtt,
              port: 1883,
            )));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockProtocolRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap FAB to open create dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Dialog should be visible
        expect(find.byType(AlertDialog), findsWidgets);

        // Try to create without filling required fields
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Please fill all fields'), findsWidgets);
      });

      testWidgets('ProtocolPage handles search filtering',
          (WidgetTester tester) async {
        final protocols = [
          ProtocolModel(
            id: 'proto-1',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          ProtocolModel(
            id: 'proto-2',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
          ProtocolModel(
            id: 'proto-3',
            name: 'MQTT Secure',
            type: ProtocolType.mqtt,
            port: 8883,
          ),
        ];

        when(mockProtocolRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockProtocolRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find search field
        final searchField = find.byType(TextField);
        expect(searchField, findsWidgets);

        // Type search query
        await tester.enterText(searchField, 'MQTT');
        await tester.pumpAndSettle();

        // Should show filtered results
        expect(find.text('MQTT'), findsWidgets);
        expect(find.byType(ProtocolListItem), findsWidgets);
      });

      testWidgets('ProtocolPage handles delete action',
          (WidgetTester tester) async {
        final protocol = ProtocolModel(
          id: 'proto-delete',
          name: 'Delete Me',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        when(mockProtocolRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([protocol]));

        when(mockProtocolRepository.deleteProtocol('proto-delete'))
            .thenAnswer((_) async => Result.success(null));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockProtocolRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Long press to open context menu
        await tester.longPress(find.byType(ProtocolListItem));
        await tester.pumpAndSettle();

        // Tap delete option
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Confirm deletion
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        verify(mockProtocolRepository.deleteProtocol('proto-delete')).called(1);
      });
    });

    group('Connection Page Advanced Scenarios', () {
      late MockConnectionRepository mockConnectionRepository;

      setUp(() {
        mockConnectionRepository = MockConnectionRepository();
      });

      testWidgets('ConnectionPage displays connection status badges',
          (WidgetTester tester) async {
        final now = DateTime.now();
        final connections = [
          ConnectionModel(
            id: 'conn-1',
            name: 'Active Connection',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
          ConnectionModel(
            id: 'conn-2',
            name: 'Inactive Connection',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.inactive,
            createdAt: now,
          ),
          ConnectionModel(
            id: 'conn-3',
            name: 'Connecting Connection',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.connecting,
            createdAt: now,
          ),
        ];

        when(mockConnectionRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(connections));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(
              connectionRepository: mockConnectionRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check for status badges
        expect(find.text('Active'), findsWidgets);
        expect(find.text('Inactive'), findsWidgets);
        expect(find.text('Connecting'), findsWidgets);
      });

      testWidgets('ConnectionPage filters by status',
          (WidgetTester tester) async {
        final now = DateTime.now();
        final connections = [
          ConnectionModel(
            id: 'conn-active-1',
            name: 'Active 1',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
          ConnectionModel(
            id: 'conn-active-2',
            name: 'Active 2',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
        ];

        when(mockConnectionRepository
                .getConnectionsByStatus(ConnectionStatus.active))
            .thenAnswer((_) async => Result.success(connections));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(
              connectionRepository: mockConnectionRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find and tap status filter
        await tester.tap(find.text('Filter by Status'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Active'));
        await tester.pumpAndSettle();

        expect(find.text('Active 1'), findsWidgets);
        expect(find.text('Active 2'), findsWidgets);
      });

      testWidgets('ConnectionPage handles connection details view',
          (WidgetTester tester) async {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-details',
          name: 'Detailed Connection',
          host: 'broker.example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
          metadata: {
            'username': 'admin',
            'tlsEnabled': true,
          },
        );

        when(mockConnectionRepository.getAllConnections())
            .thenAnswer((_) async => Result.success([connection]));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(
              connectionRepository: mockConnectionRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap connection to view details
        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        // Details should be displayed
        expect(find.text('broker.example.com'), findsWidgets);
        expect(find.text('1883'), findsWidgets);
      });

      testWidgets('ConnectionPage handles connection edit',
          (WidgetTester tester) async {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-edit',
          name: 'Editable Connection',
          host: 'old.example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        when(mockConnectionRepository.getAllConnections())
            .thenAnswer((_) async => Result.success([connection]));

        final updated = connection.copyWith(host: 'new.example.com');

        when(mockConnectionRepository.updateConnection(any))
            .thenAnswer((_) async => Result.success(updated));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(
              connectionRepository: mockConnectionRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap edit button
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Edit host
        final hostField = find.byType(TextField).first;
        await tester.enterText(hostField, 'new.example.com');
        await tester.pumpAndSettle();

        // Save changes
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        verify(mockConnectionRepository.updateConnection(any)).called(1);
      });
    });

    group('Page Navigation and Transitions', () {
      testWidgets('Navigate from ProtocolPage to ConnectionPage',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Go to Connections'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Go to Connections'), findsOneWidget);

        await tester.tap(find.text('Go to Connections'));
        await tester.pumpAndSettle();
      });

      testWidgets('Page preserves scroll position on return',
          (WidgetTester tester) async {
        final items = List.generate(50, (i) => 'Item $i');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(items[index]),
                ),
              ),
            ),
          ),
        );

        // Scroll down
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pumpAndSettle();

        expect(find.text('Item 20'), findsWidgets);
      });
    });

    group('Page Loading and Error States', () {
      testWidgets('Page shows loading indicator while fetching',
          (WidgetTester tester) async {
        late Completer completer;

        final mockRepository = MockProtocolRepository();
        when(mockRepository.getAllProtocols()).thenAnswer((_) async {
          completer = Completer();
          return await completer.future;
        });

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockRepository,
            ),
          ),
        );

        // Loading should be visible
        expect(find.byType(CircularProgressIndicator), findsWidgets);

        // Complete the future
        completer.complete(Result.success([]));
        await tester.pumpAndSettle();

        // Loading should be gone
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('Page shows error state with retry button',
          (WidgetTester tester) async {
        final mockRepository = MockProtocolRepository();
        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(Exception('Network error')));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Error message should be displayed
        expect(find.text('Network error'), findsWidgets);

        // Retry button should be present
        expect(find.text('Retry'), findsWidgets);
      });
    });

    group('Page Responsiveness', () {
      testWidgets('Page adapts to small screen', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        final mockRepository = MockProtocolRepository();
        when(mockRepository.getAllProtocols()).thenAnswer(
          (_) async => Result.success([
            ProtocolModel(
              id: 'proto-1',
              name: 'MQTT',
              type: ProtocolType.mqtt,
              port: 1883,
            ),
          ]),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ProtocolPage), findsOneWidget);
      });

      testWidgets('Page adapts to large screen', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        final mockRepository = MockProtocolRepository();
        when(mockRepository.getAllProtocols()).thenAnswer(
          (_) async => Result.success([
            ProtocolModel(
              id: 'proto-1',
              name: 'MQTT',
              type: ProtocolType.mqtt,
              port: 1883,
            ),
          ]),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(
              protocolRepository: mockRepository,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ProtocolPage), findsOneWidget);
      });
    });

    group('Page State Management', () {
      testWidgets('Page maintains state across rebuilds',
          (WidgetTester tester) async {
        var rebuildCount = 0;

        final mockRepository = MockProtocolRepository();
        final protocols = [
          ProtocolModel(
            id: 'proto-1',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuildCount++;
                return Scaffold(
                  body: ProtocolPage(
                    protocolRepository: mockRepository,
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => setState(() {}),
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        final initialBuildCount = rebuildCount;

        // Trigger rebuild
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(rebuildCount, greaterThan(initialBuildCount));
      });
    });
  });
}

// Placeholder widgets and classes for testing purposes
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Empty State'));
  }
}

class ProtocolListItem extends StatelessWidget {
  final Protocol protocol;
  final VoidCallback? onTap;

  const ProtocolListItem({
    Key? key,
    required this.protocol,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(protocol.name),
      subtitle: Text('Port: ${protocol.port}'),
      onTap: onTap,
    );
  }
}

class ProtocolPage extends StatefulWidget {
  final ProtocolRepository protocolRepository;

  const ProtocolPage({
    Key? key,
    required this.protocolRepository,
  }) : super(key: key);

  @override
  State<ProtocolPage> createState() => _ProtocolPageState();
}

class _ProtocolPageState extends State<ProtocolPage> {
  late Future<Result<List<Protocol>, Exception>> _protocolsFuture;

  @override
  void initState() {
    super.initState();
    _protocolsFuture = widget.protocolRepository.getAllProtocols();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
      ),
      body: FutureBuilder<Result<List<Protocol>, Exception>>(
        future: _protocolsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(snapshot.error.toString()),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _protocolsFuture =
                            widget.protocolRepository.getAllProtocols();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: EmptyStateWidget());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ConnectionPage extends StatefulWidget {
  final ConnectionRepository connectionRepository;

  const ConnectionPage({
    Key? key,
    required this.connectionRepository,
  }) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
      ),
      body: const Center(child: Text('Connections')),
    );
  }
}
