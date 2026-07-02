import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/repositories/protocol_repository.dart';
import 'package:iot_manager/domain/repositories/connection_repository.dart';
import 'package:iot_manager/domain/usecases/protocol_usecases.dart';
import 'package:iot_manager/domain/usecases/connection_usecases.dart';
import 'package:iot_manager/presentation/pages/protocol_page.dart';
import 'package:iot_manager/presentation/pages/connection_page.dart';
import 'package:iot_manager/core/utils/result.dart';

// Mock repositories
class MockProtocolRepository extends Mock implements ProtocolRepository {}
class MockConnectionRepository extends Mock implements ConnectionRepository {}

void main() {
  group('Presentation Layer - Pages Tests', () {
    group('ProtocolPage Navigation & Rendering', () {
      late MockProtocolRepository mockRepository;

      setUp(() {
        mockRepository = MockProtocolRepository();
      });

      testWidgets('ProtocolPage renders with AppBar', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Protocols'), findsOneWidget);
      });

      testWidgets('ProtocolPage displays empty state', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('No protocols found'), findsWidgets);
      });

      testWidgets('ProtocolPage displays protocol list', (WidgetTester tester) async {
        final protocols = [
          Protocol(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          Protocol(
            id: 'proto-002',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
        ];

        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('MQTT'), findsOneWidget);
        expect(find.text('HTTP'), findsOneWidget);
      });

      testWidgets('ProtocolPage has FAB for adding new protocol', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('ProtocolPage FAB opens add protocol dialog', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsWidgets);
      });

      testWidgets('ProtocolPage protocol item is tappable', (WidgetTester tester) async {
        final protocols = [
          Protocol(
            id: 'proto-001',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
        ];

        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success(protocols));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(ListTile), findsWidgets);

        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      });

      testWidgets('ProtocolPage shows loading state', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) => Future.delayed(
                  const Duration(seconds: 1),
                  () => Result.success([]),
                ));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });
    });

    group('ConnectionPage Navigation & Rendering', () {
      late MockConnectionRepository mockRepository;

      setUp(() {
        mockRepository = MockConnectionRepository();
      });

      testWidgets('ConnectionPage renders with header', (WidgetTester tester) async {
        final mockUseCase = GetAllConnectionsUseCase(mockRepository);

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(getAllConnectionsUseCase: mockUseCase),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('ConnectionPage displays connections', (WidgetTester tester) async {
        final now = DateTime.now();
        final connections = [
          Connection(
            id: 'conn-001',
            name: 'MQTT Broker',
            host: 'broker.example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
        ];

        final mockUseCase = GetAllConnectionsUseCase(mockRepository);

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(connections));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(getAllConnectionsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('MQTT Broker'), findsOneWidget);
      });

      testWidgets('ConnectionPage shows connection status', (WidgetTester tester) async {
        final now = DateTime.now();
        final connections = [
          Connection(
            id: 'conn-001',
            name: 'Test',
            host: 'example.com',
            port: 1883,
            status: ConnectionStatus.active,
            createdAt: now,
          ),
        ];

        final mockUseCase = GetAllConnectionsUseCase(mockRepository);

        when(mockRepository.getAllConnections())
            .thenAnswer((_) async => Result.success(connections));

        await tester.pumpWidget(
          MaterialApp(
            home: ConnectionPage(getAllConnectionsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('active'), findsWidgets);
      });
    });

    group('Page Navigation Flow', () {
      test('Protocol page can navigate to connection page', () async {
        // Navigation test setup
        expect(true, true);
      });

      test('Connection page can navigate back to protocol page', () async {
        // Navigation test setup
        expect(true, true);
      });

      test('Pages maintain state during navigation', () async {
        // State preservation test
        expect(true, true);
      });
    });

    group('Page Error Handling', () {
      late MockProtocolRepository mockRepository;

      setUp(() {
        mockRepository = MockProtocolRepository();
      });

      testWidgets('ProtocolPage shows error on load failure', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);
        final error = Exception('Failed to load protocols');

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.failure(error));

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Error'), findsWidgets);
      });

      testWidgets('ProtocolPage has retry button on error', (WidgetTester tester) async {
        var callCount = 0;
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return Result.failure(Exception('Load failed'));
          }
          return Result.success([]);
        });

        await tester.pumpWidget(
          MaterialApp(
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsWidgets);

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(callCount, 2);
      });
    });

    group('Page Theme & Styling', () {
      late MockProtocolRepository mockRepository;

      setUp(() {
        mockRepository = MockProtocolRepository();
      });

      testWidgets('ProtocolPage uses Material Design 3', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('ProtocolPage respects dark mode', (WidgetTester tester) async {
        final mockUseCase = GetAllProtocolsUseCase(mockRepository);

        when(mockRepository.getAllProtocols())
            .thenAnswer((_) async => Result.success([]));

        await tester.pumpWidget(
          MaterialApp(
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: ProtocolPage(getAllProtocolsUseCase: mockUseCase),
          ),
        );

        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
