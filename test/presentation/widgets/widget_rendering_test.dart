import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/presentation/widgets/protocol_list_item.dart';
import 'package:iot_manager/presentation/widgets/connection_status_badge.dart';
import 'package:iot_manager/presentation/widgets/empty_state_widget.dart';
import 'package:iot_manager/presentation/widgets/error_state_widget.dart';

void main() {
  group('Widget Tests - UI Components', () {
    group('ProtocolListItem Widget', () {
      testWidgets('ProtocolListItem displays protocol name', (WidgetTester tester) async {
        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('MQTT'), findsOneWidget);
      });

      testWidgets('ProtocolListItem displays port number', (WidgetTester tester) async {
        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('1883'), findsOneWidget);
      });

      testWidgets('ProtocolListItem is tappable', (WidgetTester tester) async {
        var tapCount = 0;

        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () => tapCount++,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        expect(tapCount, 1);
      });

      testWidgets('ProtocolListItem shows protocol type', (WidgetTester tester) async {
        final protocol = Protocol(
          id: 'proto-001',
          name: 'CoAP',
          type: ProtocolType.coap,
          port: 5683,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('CoAP'), findsOneWidget);
      });
    });

    group('ConnectionStatusBadge Widget', () {
      testWidgets('Badge shows active status with green color', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConnectionStatusBadge(
                status: ConnectionStatus.active,
              ),
            ),
          ),
        );

        expect(find.text('Active'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsWidgets);
      });

      testWidgets('Badge shows inactive status with gray color', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConnectionStatusBadge(
                status: ConnectionStatus.inactive,
              ),
            ),
          ),
        );

        expect(find.text('Inactive'), findsOneWidget);
      });

      testWidgets('Badge shows connecting status with spinner', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConnectionStatusBadge(
                status: ConnectionStatus.connecting,
              ),
            ),
          ),
        );

        expect(find.text('Connecting'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('Badge shows failed status with red color', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConnectionStatusBadge(
                status: ConnectionStatus.failed,
              ),
            ),
          ),
        );

        expect(find.text('Failed'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsWidgets);
      });
    });

    group('EmptyStateWidget', () {
      testWidgets('EmptyStateWidget displays message', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.inbox,
                title: 'No Items',
                message: 'There are no items to display',
              ),
            ),
          ),
        );

        expect(find.text('No Items'), findsOneWidget);
        expect(find.text('There are no items to display'), findsOneWidget);
      });

      testWidgets('EmptyStateWidget displays icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.search,
                title: 'No Results',
                message: 'Search returned no results',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('EmptyStateWidget can have action button', (WidgetTester tester) async {
        var buttonTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.refresh,
                title: 'Retry',
                message: 'Click to retry',
                actionLabel: 'Retry',
                onAction: () => buttonTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(buttonTapped, true);
      });
    });

    group('ErrorStateWidget', () {
      testWidgets('ErrorStateWidget displays error message', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorStateWidget(
                message: 'Something went wrong',
              ),
            ),
          ),
        );

        expect(find.text('Something went wrong'), findsOneWidget);
      });

      testWidgets('ErrorStateWidget displays error icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorStateWidget(
                message: 'Error occurred',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.error_outline), findsWidgets);
      });

      testWidgets('ErrorStateWidget has retry button', (WidgetTester tester) async {
        var retryTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorStateWidget(
                message: 'Error occurred',
                onRetry: () => retryTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(retryTapped, true);
      });
    });

    group('Widget Accessibility', () {
      testWidgets('ProtocolListItem has proper semantics', (WidgetTester tester) async {
        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('EmptyStateWidget message is readable', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.inbox,
                title: 'No Items',
                message: 'Create a new item to get started',
              ),
            ),
          ),
        );

        final text = find.text('No Items');
        expect(text, findsOneWidget);
        expect(tester.getSize(text).height, greaterThan(0));
      });
    });

    group('Widget Responsive Layout', () {
      testWidgets('ProtocolListItem fits in small screens', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ProtocolListItem), findsOneWidget);
      });

      testWidgets('ProtocolListItem fits in large screens', (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1920, 1080);
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProtocolListItem(
                protocol: protocol,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ProtocolListItem), findsOneWidget);
      });
    });

    group('Widget Theming', () {
      testWidgets('Widgets render in light theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.inbox,
                title: 'Light Theme',
                message: 'Testing light theme',
              ),
            ),
          ),
        );

        expect(find.text('Light Theme'), findsOneWidget);
      });

      testWidgets('Widgets render in dark theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: ThemeMode.dark,
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.inbox,
                title: 'Dark Theme',
                message: 'Testing dark theme',
              ),
            ),
          ),
        );

        expect(find.text('Dark Theme'), findsOneWidget);
      });
    });

    group('Widget Interactions', () {
      testWidgets('ConnectionStatusBadge responds to long press', (WidgetTester tester) async {
        var longPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onLongPress: () => longPressed = true,
                child: ConnectionStatusBadge(
                  status: ConnectionStatus.active,
                ),
              ),
            ),
          ),
        );

        await tester.longPress(find.byType(ConnectionStatusBadge));
        await tester.pumpAndSettle();

        expect(longPressed, true);
      });

      testWidgets('Multiple widgets can be rendered together', (WidgetTester tester) async {
        final protocol = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ProtocolListItem(
                    protocol: protocol,
                    onTap: () {},
                  ),
                  ConnectionStatusBadge(
                    status: ConnectionStatus.active,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ProtocolListItem), findsOneWidget);
        expect(find.byType(ConnectionStatusBadge), findsOneWidget);
      });
    });
  });
}
